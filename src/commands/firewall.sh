vpsctl_firewall_download_nftables_conf() {
    local url="${VPSCTL_FIREWALL_CONFIG_URL:-https://raw.githubusercontent.com/druagoon/geoip2cn/download/nftables.conf}"
    local target_file="$1"

    if [[ -z "${target_file}" ]]; then
        error "Missing target file"
        return 1
    fi

    std::tips::title "Downloading remote nftables.conf"
    if ! curl -fsSL "${url}" -o "${target_file}"; then
        error "Failed to download nftables config from ${url}"
        return 1
    fi

    if [[ ! -s "${target_file}" ]]; then
        error "Downloaded nftables config is empty"
        return 1
    fi

    std::tips::title "Validating nftables.conf"
    if ! nft -c -f "${target_file}" >/dev/null 2>&1; then
        error "Downloaded nftables config failed nft validation"
        return 1
    fi
}

vpsctl_firewall_install_nftables_conf() {
    local tmp_file
    tmp_file="$(mktemp /tmp/vpsctl-nftables.XXXXXX.conf)" || {
        error "Failed to create temporary file"
        return 1
    }

    if ! vpsctl_firewall_download_nftables_conf "${tmp_file}"; then
        rm -f "${tmp_file}"
        return 1
    fi

    std::tips::title "Installing /etc/nftables.conf"
    if ! cp "${tmp_file}" /etc/nftables.conf; then
        rm -f "${tmp_file}"
        error "Failed to write /etc/nftables.conf"
        return 1
    fi

    rm -f "${tmp_file}"
}

vpsctl_firewall_apply_nftables_conf() {
    std::tips::title "Applying nftables rules"
    if ! nft -f /etc/nftables.conf; then
        error "Failed to apply /etc/nftables.conf"
        return 1
    fi

    if ! nft list set inet vps blocked_ips >/dev/null 2>&1; then
        error "Remote nftables config must define inet vps blocked_ips for ssh-guard"
        return 1
    fi
}

# @cmd Setup the nftables firewall
# @meta require-tools nft,curl
# @flag    --refresh-config                   Refresh /etc/nftables.conf from remote source
firewall() {
    std::tips::info "Setting up nftables firewall"

    if [[ "${argc_refresh_config:-0}" == "1" ]]; then
        if ! vpsctl_firewall_install_nftables_conf; then
            return 1
        fi
        if ! vpsctl_firewall_apply_nftables_conf; then
            return 1
        fi
        systemctl reload-or-restart nftables
        std::tips::info "Remote nftables.conf refreshed"
        exit 0
    fi

    # 1. Download, validate, and install nftables configuration
    if ! vpsctl_firewall_install_nftables_conf; then
        return 1
    fi

    # 2. Apply initial configuration
    if ! vpsctl_firewall_apply_nftables_conf; then
        return 1
    fi

    # 3. Enable and start nftables service
    std::tips::title "Enabling and starting nftables service"
    systemctl enable nftables
    systemctl restart nftables

    # 4. Setup cron job for updates
    std::tips::title "Setting up automatic nftables refresh"
    local cron_job="0 2 * * * /usr/local/bin/vpsctl firewall --refresh-config &>>/tmp/vpsctl-firewall-cron.log"
    # Remove old cron job if it exists
    crontab -l 2>/dev/null | grep -v "vpsctl firewall --refresh-config" | crontab -
    # Add new cron job
    if ! crontab -l 2>/dev/null | grep -qxF "${cron_job}"; then
        (
            crontab -l 2>/dev/null
            echo "${cron_job}"
        ) | crontab -
        echo "Update job added to crontab"
    fi

    std::tips::title "Checking nftables status"
    nft list ruleset | head -n 20
    systemctl status nftables --no-pager
}
