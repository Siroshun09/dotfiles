#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LICENSES_DIR="${SCRIPT_DIR}/../../../licenses"

if [[ ! -d "${LICENSES_DIR}" ]]; then
  echo "Error: licenses directory not found: ${LICENSES_DIR}" >&2
  exit 1
fi

usage() {
  echo "Usage:"
  echo "  $(basename "$0") apache <owner>"
  echo "  $(basename "$0") gpl <program> <author>"
  exit 1
}

# Escape special characters in sed replacement strings (using | as delimiter).
escape_sed() {
  printf '%s\n' "$1" | sed 's/[&\\|]/\\&/g'
}

YEAR="$(date +%Y)"
LICENSE_TYPE="${1:-}"

case "${LICENSE_TYPE}" in
  apache)
    OWNER="${2:-}"
    if [[ -z "${OWNER}" ]]; then
      echo "Error: owner is required for apache license" >&2
      usage
    fi
    sed \
      -e "s|\[yyyy\]|${YEAR}|g" \
      -e "s|\[name of copyright owner\]|$(escape_sed "${OWNER}")|g" \
      "${LICENSES_DIR}/apache-license-v2.txt" > LICENSE
    ;;
  gpl)
    PROGRAM="${2:-}"
    AUTHOR="${3:-}"
    if [[ -z "${PROGRAM}" || -z "${AUTHOR}" ]]; then
      echo "Error: program and author are required for gpl license" >&2
      usage
    fi
    sed \
      -e "s|<year>|${YEAR}|g" \
      -e "s|<name of author>|$(escape_sed "${AUTHOR}")|g" \
      -e "s|<program>|$(escape_sed "${PROGRAM}")|g" \
      "${LICENSES_DIR}/gpl-3.0.txt" > LICENSE
    ;;
  *)
    echo "Error: unknown license type '${LICENSE_TYPE}'" >&2
    usage
    ;;
esac

echo "Created LICENSE (${LICENSE_TYPE})"
