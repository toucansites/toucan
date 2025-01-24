#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

if [ ! -d "/usr/local/bin" ]; then
    echo "Creating directory /usr/local/bin"
    mkdir -p "/usr/local/bin"
    echo "/usr/local/bin directory created"
fi

swift build -c release
install .build/release/toucan /usr/local/bin/toucan
install .build/release/toucan-generate /usr/local/bin/toucan-generate
install .build/release/toucan-init /usr/local/bin/toucan-init
install .build/release/toucan-serve /usr/local/bin/toucan-serve
install .build/release/toucan-watch /usr/local/bin/toucan-watch
