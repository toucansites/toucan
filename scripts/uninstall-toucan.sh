#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

sudo rm -f /usr/local/bin/toucan
sudo rm -f /usr/local/bin/toucan-generate
sudo rm -f /usr/local/bin/toucan-init
sudo rm -f /usr/local/bin/toucan-serve
sudo rm -f /usr/local/bin/toucan-watch
