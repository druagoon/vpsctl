# @cmd Configure and start Fail2Ban
# @flag   -f --force                    Force overwrite existing configuration files
# @flag    --restart                    Restart Fail2Ban service
fail2ban() {
    std::tips::info "Setting up Fail2Ban"

    local force="${argc_force:-0}"
    local daemon_reload=0

    local jail_local="/etc/fail2ban/jail.local"
    std::tips::title "Creating ${jail_local}"
    if [[ ! -s "${jail_local}" ]] || std::bool::is_true "${force}"; then
        daemon_reload=1
        local -a ip_whitelist=(127.0.0.1/8 ::1)
        local ssh_client_ip="$(detect_ssh_client_ip)"
        if [[ -n "${ssh_client_ip}" ]]; then
            ip_whitelist+=("${ssh_client_ip}")
            echo "Adding your IP address $(std::color::green "${ssh_client_ip}") to the whitelist"
        fi
        local ignore_ips="${ip_whitelist[*]}"
        cat >"${jail_local}" <<EOF
[DEFAULT]
ignoreip = ${ignore_ips}
EOF
    else
        warn "Fail2Ban local configuration already exists at ${jail_local}"
    fi
    std::tips::title "Showing ${jail_local}"
    cat "${jail_local}"

    local jail_sshd="/etc/fail2ban/jail.d/sshd.conf"
    std::tips::title "Creating ${jail_sshd}"
    if [[ ! -s "${jail_sshd}" ]] || std::bool::is_true "${force}"; then
        daemon_reload=1
        std::tips::title "Creating ${jail_sshd}"
        cat >"${jail_sshd}" <<EOF
[sshd]
enabled = true
port = 9922
filter = sshd
backend = systemd
findtime = 15m
maxretry = 3
bantime = 6h
bantime.increment = true
bantime.factor = 1
bantime.multipliers = 1 2 4 8 16 32 64
EOF
    else
        warn "Fail2Ban sshd configuration already exists at ${jail_sshd}"
    fi

    std::tips::title "Showing ${jail_sshd}"
    cat "${jail_sshd}"

    if ! systemctl is-enabled fail2ban --quiet 2>/dev/null; then
        std::tips::title "Enabling Fail2Ban service"
        systemctl enable fail2ban
    fi

    if std::bool::is_true "${daemon_reload}"; then
        std::tips::title "Reloading systemd daemon"
        systemctl daemon-reload
    fi

    local restart="${argc_restart:-0}"
    if std::bool::is_true "${restart}"; then
        std::tips::title "Restarting Fail2Ban service"
        systemctl restart fail2ban
    fi

    std::tips::title "Checking Fail2Ban status"
    if std::bool::is_true "${restart}"; then
        sleep 2
    fi
    fail2ban-client status
    fail2ban-client status sshd
}
