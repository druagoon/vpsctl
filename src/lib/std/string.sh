#######################################
# Remove leading and trailing whitespace from a string.
# Arguments:
#   $1: String to process.
# Outputs:
#   Writes stripped string to stdout.
#######################################
std::string::strip_whitespace() {
    sed -e 's/^[[:blank:]]*//' -e 's/[[:blank:]]*$//' <<<"$1"
}

#######################################
# Remove leading whitespace from a string.
# Arguments:
#   $1: String to process.
# Outputs:
#   Writes left-stripped string to stdout.
#######################################
std::string::lstrip_whitespace() {
    sed -e 's/^[[:blank:]]*//' <<<"$1"
}

#######################################
# Remove trailing whitespace from a string.
# Arguments:
#   $1: String to process.
# Outputs:
#   Writes right-stripped string to stdout.
#######################################
std::string::rstrip_whitespace() {
    sed -e 's/[[:blank:]]*$//' <<<"$1"
}
