#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }


rm /usr/local/bin/toucan
rm /usr/local/bin/toucan-generate
rm /usr/local/bin/toucan-init
rm /usr/local/bin/toucan-serve
rm /usr/local/bin/toucan-watch
