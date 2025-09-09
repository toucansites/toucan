#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

swift build -c release

INSTALL_DIR="${1:-/usr/local/bin}"

if [ ! -d "$INSTALL_DIR" ]; then
    sudo mkdir -p "$INSTALL_DIR"
fi

for binary in toucan toucan-generate toucan-init toucan-serve toucan-watch; do
  sudo install .build/release/${binary} "${INSTALL_DIR}/${binary}"
done
