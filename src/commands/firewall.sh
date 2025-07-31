# @cmd Setup the UFW firewall
firewall() {
    std::tips::info "Setting up UFW firewall"

    ufw default deny incoming
    ufw default allow outgoing
    ufw allow http
    ufw allow https
    # ufw allow ssh
    ufw allow 9443/tcp
    ufw allow 9922/tcp
    ufw enable
    echo "UFW firewall configured and enabled."

    std::tips::title "Checking UFW status"
    ufw status verbose
}
