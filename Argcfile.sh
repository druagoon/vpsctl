#!/usr/bin/env bash

# @describe Manage `vps` project
# @meta version 1.0.0
# @meta inherit-flag-options
# @flag -D --debug Enable debug mode

set -eo pipefail

# @cmd TOML files tools
# @meta require-tools taplo
toml() {
    return
}

# @cmd Format all TOML files
toml::format() {
    taplo format
}

# @cmd Check all TOML files
toml::check() {
    taplo format --check
}

# Hooks
_argc_before() {
    if [[ "${argc_debug}" == "1" ]]; then
        set -x
    fi
}

# See more details at https://github.com/sigoden/argc
eval "$(argc --argc-eval "$0" "$@")"
