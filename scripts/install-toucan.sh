#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

swift build -c release

if [ ! -d "/usr/local/bin" ]; then
    sudo mkdir -p "/usr/local/bin"
fi

sudo install .build/release/toucan /usr/local/bin/toucan
sudo install .build/release/toucan-generate /usr/local/bin/toucan-generate
sudo install .build/release/toucan-init /usr/local/bin/toucan-init
sudo install .build/release/toucan-serve /usr/local/bin/toucan-serve
sudo install .build/release/toucan-watch /usr/local/bin/toucan-watch
