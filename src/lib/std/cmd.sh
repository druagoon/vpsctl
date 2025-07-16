#######################################
# Check if a command exists in PATH.
# Arguments:
#   $1: Command name to check.
# Returns:
#   0 if command exists, non-zero otherwise.
#######################################
std::cmd::exists() {
    command -v "$1" >/dev/null 2>&1
}
