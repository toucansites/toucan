#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git -C "${CURRENT_SCRIPT_DIR}" rev-parse --show-toplevel)"
  
read -ra PATHS_TO_CHECK <<< "$( \
  git -C "${REPO_ROOT}" ls-files -z \
  "Package.swift" \
  | xargs -0 \
)"

for FILE_PATH in "${PATHS_TO_CHECK[@]}"; do
echo $FILE_PATH
    if [[ $(grep ".package(path:" "${FILE_PATH}"|wc -l) -ne 0 ]] ; then
        fatal "❌ The '${FILE_PATH}' file contains local Swift package reference(s)."
    fi
done 

log "✅ Found 0 local Swift package dependency references."
