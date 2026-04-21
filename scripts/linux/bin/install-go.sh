#!/usr/bin/env bash
set -e -u -o pipefail

GO_DIR="$HOME/.local/go"

ARCH=$(uname -m)
case "$ARCH" in
  x86_64)  ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

GO_VERSION=$(curl -s "https://go.dev/VERSION?m=text" | head -1)
GO_DOWNLOAD_URL="https://go.dev/dl/${GO_VERSION}.linux-${ARCH}.tar.gz"

echo "Installing Go ${GO_VERSION} to $GO_DIR"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
archive="$tmpdir/${GO_VERSION}.linux-${ARCH}.tar.gz"

rm -rf "$GO_DIR"
mkdir -p "$GO_DIR"

curl -fsSL -o "$archive" "$GO_DOWNLOAD_URL"
hash=$(curl -fsSL "https://go.dev/dl/?mode=json" \
  | jq -r --arg v "$GO_VERSION" --arg fn "${GO_VERSION}.linux-${ARCH}.tar.gz" \
      '.[] | select(.version == $v) | .files[] | select(.filename == $fn) | .sha256')

actualHash=$(sha256sum "$archive" | awk '{print $1}')
if [ "$hash" != "$actualHash" ]; then
  echo "ERROR: SHA256 mismatch for $archive" >&2
  echo "Expected: $hash" >&2
  echo "Actual:   $actualHash" >&2
  exit 1
fi

tar -xz -C "$GO_DIR" --strip-components=1 -f "$archive"

"$GO_DIR/bin/go" version
