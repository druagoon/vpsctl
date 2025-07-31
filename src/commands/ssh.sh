# @cmd Setup ssh daemon and configure security
# @flag    --restart                    Restart the SSH service after configuration
ssh() {
    std::tips::info "Setting up SSH daemon and configuring security"

    local vps_sshd_config="/etc/ssh/sshd_config.d/999-vps.conf"
    std::tips::title "Creating ${vps_sshd_config}"
    if [[ ! -s "${vps_sshd_config}" ]]; then
        cat >"${vps_sshd_config}" <<EOF
PasswordAuthentication no
PermitRootLogin no
Port 9922
EOF
        if std::bool::is_true "${argc_restart:-}"; then
            std::tips::title "Restarting SSH service"
            systemctl restart ssh
        fi
    else
        warn "SSH configuration already exists at ${vps_sshd_config}"
    fi
}
