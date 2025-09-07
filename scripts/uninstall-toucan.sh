#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

INSTALL_DIR="${1:-/usr/local/bin}"

for binary in toucan toucan-generate toucan-init toucan-serve toucan-watch; do
  sudo rm -f "${INSTALL_DIR}/${binary}"
done
