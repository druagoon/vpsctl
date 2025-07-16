#######################################
# Checks if a value exists in an array.
# Arguments:
#   $1: Value to search for.
#   Array elements.
# Returns:
#   0 if the value is found in the array, 1 otherwise.
#######################################
std::array::contains() {
    local val="$1"
    shift
    local arr=("$@")
    for item in "${arr[@]}"; do
        [[ "${item}" == "${val}" ]] && return 0
    done
    return 1
}
