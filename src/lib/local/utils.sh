#######################################
# Remove trailing newline from a string.
# Arguments:
#   $1: String to process.
# Outputs:
#   Writes string without trailing newline to stdout.
#######################################
chomp() { printf "%s" "${1/"$'\n'"/}"; }

#######################################
# Print a warning message in yellow to stderr.
# Arguments:
#   $1: Warning message.
# Outputs:
#   Writes formatted warning to stderr.
#######################################
warn() {
    printf "$(std::color::yellow Warning): %s\n" "$(chomp "$1")" >&2
}

#######################################
# Print an error message in red to stderr.
# Arguments:
#   $1: Error message.
# Outputs:
#   Writes formatted error to stderr.
#######################################
error() {
    printf "$(std::color::red Error): %s\n" "$(chomp "$1")" >&2
}

#######################################
# Check if an IP address is denied by UFW.
# Arguments:
#   $1: IP address to check.
# Returns:
#   0 if IP is denied, non-zero otherwise.
#######################################
is_ip_denied() {
    local ip="$1"
    ufw status | awk -v ip="${ip}" '$2 == "DENY" && $3 == ip' | grep -q .
}

#######################################
# Detect the SSH client IP address.
# Globals:
#   SSH_CONNECTION
#   SUDO_USER
# Arguments:
#   None
# Outputs:
#   Writes detected SSH client IP to stdout.
#######################################
detect_ssh_client_ip() {
    # Get the current executing user (could be root if using sudo)
    local current_user="$(whoami)"
    # Get the original login user (if script is run via sudo)
    local real_user="${SUDO_USER:-"${current_user}"}"
    # Try to get SSH connection info from environment
    # If SSH_CONNECTION is empty, try to find client IP via login record
    if [[ -n "${SSH_CONNECTION}" ]]; then
        # Extract client IP from SSH_CONNECTION
        local ssh_ip="$(echo "${SSH_CONNECTION}" | awk '{print $1}')"
    else
        # Use 'who' to get the client's IP for the real login user
        local ssh_ip="$(who am i | grep "^${real_user}\b" | awk '{print $5}' | tr -d '()')"
    fi

    # Print information
    # echo "Current user       : ${current_user}"
    # echo "Original login user: ${real_user}"
    # echo "SSH client IP      : ${ssh_ip:-Not detected (non-SSH session?)}"
    echo "${ssh_ip:-}"
}
