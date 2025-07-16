#######################################
# Ensure that one or more directories exist, creating them if necessary.
# Arguments:
#   $@: Directories to ensure.
# Returns:
#   None
#######################################
std::path::dir::ensure() {
    for dir in "$@"; do
        if [[ ! -d "${dir}" ]]; then
            mkdir -p "${dir}"
        fi
    done
}

#######################################
# Ensure that one or more files exist, creating them if necessary.
# Arguments:
#   $@: Files to ensure.
# Returns:
#   None
#######################################
std::path::file::ensure() {
    for file in "$@"; do
        if [[ ! -e "${file}" ]]; then
            touch "${file}"
        fi
    done
}

#######################################
# Ensure that one or more files exist, creating their parent directories if necessary.
# Arguments:
#   $@: Files to ensure.
# Returns:
#   None
#######################################
std::path::file::ensure_dir() {
    for file in "$@"; do
        if [[ ! -e "${file}" ]]; then
            local dir="$(dirname "${file}")"
            std::path::dir::ensure "${dir}"
            touch "${file}"
        fi
    done
}
