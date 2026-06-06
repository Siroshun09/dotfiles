#!/usr/bin/env bash
set -euo pipefail

# Manage Claude skills/agents in a project-level (./.claude/<type>) or
# user-level (~/.claude/<type>) location.
#
#   copy   - copy new or changed items from a source directory
#   remove - interactively delete installed items
#
#   skills - subdirectories containing a SKILL.md file
#   agents - *.md files

usage() {
  cat >&2 <<EOF
Usage:
  $(basename "$0") copy   [options] <skills|agents> <source-dir>
  $(basename "$0") remove [options] <skills|agents>

Actions:
  copy    Copy new or changed skills/agents from <source-dir> into .claude.
          Only items that are new or whose contents differ are offered.
  remove  Interactively select and delete installed skills/agents.

Types:
  skills  subdirectories that contain a SKILL.md file
  agents  *.md files

Options:
  -p, --project   Target ./.claude/<type> (current directory)
  -u, --user      Target ~/.claude/<type> (user level)
  -h, --help      Show this help

If neither -p nor -u is given, the target is chosen interactively.
EOF
  exit "${1:-1}"
}

# --- argument parsing -------------------------------------------------------
ACTION=""
TYPE=""
SRC=""
DEST_MODE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--project) DEST_MODE="project" ;;
    -u|--user)    DEST_MODE="user" ;;
    -h|--help)    usage 0 ;;
    -*)           echo "Error: unknown option '$1'" >&2; usage ;;
    *)
      if [[ -z "${ACTION}" ]]; then
        ACTION="$1"
      elif [[ -z "${TYPE}" ]]; then
        TYPE="$1"
      elif [[ -z "${SRC}" ]]; then
        SRC="$1"
      else
        echo "Error: unexpected argument '$1'" >&2; usage
      fi
      ;;
  esac
  shift
done

case "${ACTION}" in
  copy|remove) ;;
  "")  echo "Error: action (copy|remove) is required" >&2; usage ;;
  *)   echo "Error: invalid action '${ACTION}' (expected copy|remove)" >&2; usage ;;
esac

case "${TYPE}" in
  skills) FIND_NAME="SKILL.md"; SUBDIR="skills" ;;
  agents) FIND_NAME="*.md";     SUBDIR="agents" ;;
  "")     echo "Error: type (skills|agents) is required" >&2; usage ;;
  *)      echo "Error: invalid type '${TYPE}' (expected skills|agents)" >&2; usage ;;
esac

# --- shared helpers ---------------------------------------------------------

# Populate item_paths[] and item_names[] from the items found under $1.
#   skills: the parent directory of every SKILL.md
#   agents: every *.md file
# Line-based reading keeps paths with spaces intact (paths with newlines are
# not supported, which is fine for skill/agent paths).
collect_items() {
  item_paths=()
  item_names=()
  local f item
  while IFS= read -r f; do
    if [[ "${TYPE}" == "skills" ]]; then
      item="$(dirname "${f}")"
    else
      item="${f}"
    fi
    item_paths+=("${item}")
    item_names+=("$(basename "${item}")")
  done < <(find "$1" -type f -name "${FIND_NAME}" | sort)
}

# Parse the global `selection` string against a count ($1) into indices[].
# 'a'/'A' selects all; otherwise space-separated 1-based numbers.
build_indices() {
  local count="$1" token i
  indices=()
  if [[ "${selection}" == "a" || "${selection}" == "A" ]]; then
    i=0
    while [[ $i -lt ${count} ]]; do
      indices+=("$i")
      i=$((i + 1))
    done
    return 0
  fi
  for token in ${selection}; do
    if ! [[ "${token}" =~ ^[0-9]+$ ]]; then
      echo "Error: invalid selection '${token}'" >&2
      return 1
    fi
    if [[ "${token}" -lt 1 || "${token}" -gt ${count} ]]; then
      echo "Error: selection out of range: ${token}" >&2
      return 1
    fi
    indices+=("$((token - 1))")
  done
}

# Resolve DEST from DEST_MODE, prompting interactively if unset.
resolve_dest() {
  if [[ -z "${DEST_MODE}" ]]; then
    echo "Target:"
    echo "  1) project (./.claude/${SUBDIR})"
    echo "  2) user    (~/.claude/${SUBDIR})"
    read -r -p "Select [1/2]: " choice
    case "${choice}" in
      1) DEST_MODE="project" ;;
      2) DEST_MODE="user" ;;
      *) echo "Error: invalid selection '${choice}'" >&2; exit 1 ;;
    esac
  fi
  case "${DEST_MODE}" in
    project) DEST="${PWD}/.claude/${SUBDIR}" ;;
    user)    DEST="${HOME}/.claude/${SUBDIR}" ;;
  esac
}

# --- copy -------------------------------------------------------------------
do_copy() {
  if [[ -z "${SRC}" ]]; then
    echo "Error: source directory is required" >&2
    usage
  fi
  if [[ ! -d "${SRC}" ]]; then
    echo "Error: source directory not found: ${SRC}" >&2
    exit 1
  fi

  resolve_dest

  collect_items "${SRC}"
  if [[ ${#item_paths[@]} -eq 0 ]]; then
    echo "Error: no ${TYPE} found under: ${SRC}" >&2
    exit 1
  fi

  # Classify each item against the destination:
  #   new      - not present at the destination
  #   differs  - present but the contents differ (offered for overwrite)
  #   up todate - present and identical (skipped)
  local sel_paths=() sel_names=() sel_status=() uptodate=()
  local i name src_path dst_path
  i=0
  while [[ $i -lt ${#item_paths[@]} ]]; do
    name="${item_names[$i]}"
    src_path="${item_paths[$i]}"
    dst_path="${DEST}/${name}"
    if [[ ! -e "${dst_path}" ]]; then
      sel_paths+=("${src_path}"); sel_names+=("${name}"); sel_status+=("new")
    elif diff -rq "${src_path}" "${dst_path}" >/dev/null 2>&1; then
      uptodate+=("${name}")
    else
      sel_paths+=("${src_path}"); sel_names+=("${name}"); sel_status+=("differs")
    fi
    i=$((i + 1))
  done

  if [[ ${#uptodate[@]} -gt 0 ]]; then
    echo "Up to date (skipped): ${uptodate[*]}"
  fi
  if [[ ${#sel_paths[@]} -eq 0 ]]; then
    echo "No ${TYPE} to copy."
    exit 0
  fi

  echo
  echo "${TYPE} available to copy into ${DEST}:"
  i=0
  while [[ $i -lt ${#sel_names[@]} ]]; do
    printf "  %d) %-24s [%s]\n" "$((i + 1))" "${sel_names[$i]}" "${sel_status[$i]}"
    i=$((i + 1))
  done
  echo
  echo "Enter numbers separated by spaces (e.g. '1 3'), 'a' for all, or empty to cancel."
  echo "Selecting a 'differs' item overwrites the existing one at the destination."
  read -r -p "Select: " selection

  if [[ -z "${selection}" ]]; then
    echo "Cancelled."
    exit 0
  fi
  build_indices "${#sel_paths[@]}" || exit 1

  mkdir -p "${DEST}"
  local idx status
  for idx in "${indices[@]}"; do
    src_path="${sel_paths[$idx]}"
    name="${sel_names[$idx]}"
    status="${sel_status[$idx]}"
    dst_path="${DEST}/${name}"
    # For a differing item, remove the existing copy first so that files
    # deleted from the source are not left behind at the destination.
    if [[ "${status}" == "differs" ]]; then
      rm -rf "${dst_path}"
    fi
    cp -R "${src_path}" "${dst_path}"
    echo "Copied (${status}): ${name} -> ${dst_path}"
  done
}

# --- remove -----------------------------------------------------------------
do_remove() {
  resolve_dest

  if [[ ! -d "${DEST}" ]]; then
    echo "Error: ${SUBDIR} directory not found: ${DEST}" >&2
    exit 1
  fi

  collect_items "${DEST}"
  if [[ ${#item_paths[@]} -eq 0 ]]; then
    echo "No ${TYPE} found under: ${DEST}"
    exit 0
  fi

  echo
  echo "${TYPE} installed in ${DEST}:"
  local i
  i=0
  while [[ $i -lt ${#item_names[@]} ]]; do
    printf "  %d) %s\n" "$((i + 1))" "${item_names[$i]}"
    i=$((i + 1))
  done
  echo
  echo "Enter numbers separated by spaces (e.g. '1 3'), 'a' for all, or empty to cancel."
  read -r -p "Select ${TYPE} to remove: " selection

  if [[ -z "${selection}" ]]; then
    echo "Cancelled."
    exit 0
  fi
  build_indices "${#item_paths[@]}" || exit 1

  # Confirm before deleting (this is destructive).
  echo
  echo "The following ${TYPE} will be permanently deleted:"
  local idx
  for idx in "${indices[@]}"; do
    echo "  - ${item_names[$idx]} (${item_paths[$idx]})"
  done
  read -r -p "Proceed? [y/N]: " confirm
  case "${confirm}" in
    y|Y|yes|YES) ;;
    *) echo "Cancelled."; exit 0 ;;
  esac

  for idx in "${indices[@]}"; do
    rm -rf "${item_paths[$idx]}"
    echo "Removed: ${item_names[$idx]}"
  done
}

case "${ACTION}" in
  copy)   do_copy ;;
  remove) do_remove ;;
esac
