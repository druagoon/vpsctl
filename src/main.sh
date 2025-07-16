#!/usr/bin/env bash

# @describe Set up a VPS with basic security and configuration.
# @meta version 1.0.0
# @meta require-tools sed
# @meta inherit-flag-options
# @flag -D --debug Enable debug mode

set -e
set -o pipefail

# @include lib/std/array.sh
# @include lib/std/bool.sh
# @include lib/std/cmd.sh
# @include lib/std/string.sh
# @include lib/std/os.sh
# @include lib/std/env.sh
# @include lib/std/fs.sh
# @include lib/std/colors.sh
# @include lib/std/message.sh
# @include lib/std/path.sh
# @include lib/std/tips.sh

# @include hooks.sh
