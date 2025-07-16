#######################################
# Checks if the given argument represents a boolean "true" value.
# Arguments:
#   $1: Value to check (case-insensitive). Accepts: true, yes, y, on, 1.
# Returns:
#   0 if the value is considered true, 1 otherwise.
#######################################
std::bool::is_true() {
    case "${1@L}" in
        true | yes | y | on | 1)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

#######################################
# Checks if the given argument represents a boolean "false" value.
# Arguments:
#   $1: Value to check (case-insensitive). Accepts: false, no, n, off, 0, "".
# Returns:
#   0 if the value is considered false, 1 otherwise.
#######################################
std::bool::is_false() {
    case "${1@L}" in
        false | no | n | off | 0 | "")
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
