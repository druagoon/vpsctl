#######################################
# Checks if a file contains a specific line.
# Arguments:
#   $1: Path to the file to search.
#   $2: Line to search for in the file.
# Returns:
#   0 if the line is found in the file, 1 otherwise.
# Usage:
#   std::fs::file::has_line "/path/to/file" "search_line"
#######################################
std::fs::file::has_line() {
    local file="$1"
    local line="$2"
    if [[ -f "${file}" ]]; then
        grep -qxF -- "${line}" "${file}"
        return $?
    fi
    return 1
}
