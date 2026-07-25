#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage:"
  echo "  $(basename "$0") <file.json> [file.json ...]"
  echo ""
  echo "Sorts the keys of each JSON file recursively and overwrites it in place."
  exit 1
}

if [[ $# -eq 0 ]]; then
  usage
fi

if ! command -v jq > /dev/null 2>&1; then
  echo "Error: jq is not installed" >&2
  exit 1
fi

tmp="$(mktemp)"
trap 'rm -f "${tmp}"' EXIT

for file in "$@"; do
  if [[ ! -f "${file}" ]]; then
    echo "Error: file not found: ${file}" >&2
    exit 1
  fi

  if ! jq -S . "${file}" > "${tmp}"; then
    echo "Error: failed to parse JSON: ${file}" >&2
    exit 1
  fi

  # Write through the existing file to keep its permissions and owner.
  cat "${tmp}" > "${file}"

  echo "Sorted ${file}"
done
