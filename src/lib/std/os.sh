#######################################
# Check if the operating system is Linux.
# Arguments:
#   None
# Returns:
#   0 if OS is Linux, non-zero otherwise.
#######################################
std::os::is_linux() {
    [[ "$(uname)" == "Linux" ]]
}

#######################################
# Check if the operating system is macOS (Darwin).
# Arguments:
#   None
# Returns:
#   0 if OS is macOS, non-zero otherwise.
#######################################
std::os::is_macos() {
    [[ "$(uname)" == "Darwin" ]]
}

#######################################
# Check if the system architecture is ARM64 or AARCH64.
# Arguments:
#   None
# Returns:
#   0 if architecture is arm64 or aarch64, non-zero otherwise.
#######################################
std::os::is_arm64() {
    local arch="$(uname -m)"
    [[ "${arch}" == "arm64" || "${arch}" == "aarch64" ]]
}
