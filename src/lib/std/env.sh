#######################################
# Check if a directory is in the PATH environment variable.
# Globals:
#   PATH
# Arguments:
#   $1: Directory to check.
# Returns:
#   0 if directory is in PATH, non-zero otherwise.
#######################################
std::env::path::is_contains() {
    [[ ":${PATH}:" == *":$1:"* ]]
}

#######################################
# Prepend one or more directories to the PATH if not already present.
# Globals:
#   PATH
# Arguments:
#   $@: Directories to prepend.
# Returns:
#   None
#######################################
std::env::path::prepend() {
    for p in "$@"; do
        if ! std::env::path::is_contains "${p}"; then
            export PATH="${p}:${PATH}"
        fi
    done
}

#######################################
# Append one or more directories to the PATH if not already present.
# Globals:
#   PATH
# Arguments:
#   $@: Directories to append.
# Returns:
#   None
#######################################
std::env::path::append() {
    for p in "$@"; do
        if ! std::env::path::is_contains "${p}"; then
            export PATH="${PATH}:${p}"
        fi
    done
}
