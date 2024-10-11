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
install .build/release/toucan-cli /usr/local/bin/toucan
