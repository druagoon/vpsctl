vpsctl_firewall_is_ipv4_sets() {
    [[ "$1" == *-v4 ]]
}

vpsctl_firewall_is_ipv6_sets() {
    [[ "$1" == *-v6 ]]
}

vpsctl_firewall_is_blacklist_sets() {
    [[ "$1" == *-blacklist-v4 || "$1" == *-blacklist-v6 ]]
}

vpsctl_firewall_create_sets() {
    local name="$1"
    local url="$2"
    if [[ -z "${name}" || -z "${url}" ]]; then
        error "Missing name or url"
        exit 1
    fi

    local family
    if vpsctl_firewall_is_ipv4_sets "${name}"; then
        family="inet"
    elif vpsctl_firewall_is_ipv6_sets "${name}"; then
        family="inet6"
    else
        error "Invalid ipset name: ${name}. Needs to end with -v4 or -v6."
        exit 1
    fi

    # ipset destroy "${name}" 2>/dev/null || true
    ipset create "${name}" hash:net family ${family} -exist
    ipset flush "${name}"
    curl -fsSL "${url}" | sed "s/^/add ${name} /" | ipset restore
}

# @cmd Setup the UFW firewall
# @meta require-tools ufw,ipset
# @flag    --only-update-ipset-sets                 Only update ipset sets, do not modify UFW rules
firewall() {
    std::tips::info "Setting up UFW firewall"

    local -A ip_sets=(
        ["geoip-cn-v4"]="https://github.com/druagoon/geoip2cn/raw/download/countries/ipv4/cn.zone"
        ["geoip-cn-v6"]="https://github.com/druagoon/geoip2cn/raw/download/countries/ipv6/cn.zone"
        ["geoip-cn-blacklist-v4"]="https://github.com/druagoon/geoip2cn/raw/download/domains/ipv4/aggregated.zone"
        ["geoip-cn-blacklist-v6"]="https://github.com/druagoon/geoip2cn/raw/download/domains/ipv6/aggregated.zone"
    )

    for name in "${!ip_sets[@]}"; do
        std::tips::title "Creating ipset sets $(std::color::green ${name})"
        vpsctl_firewall_create_sets "${name}" "${ip_sets[${name}]}"
    done

    std::path::dir::ensure /etc/ipset/sets
    local ipset_save_file="/etc/ipset/sets/cn.conf"
    std::tips::title "Saving ipset sets to ${ipset_save_file}"
    ipset save >"${ipset_save_file}"

    if std::bool::is_true "${argc_only_update_ipset_sets:-0}"; then
        warn "Only updating ipset sets, skipping UFW rules and service creation."
        exit 0
    fi

    std::tips::title "Setting up automatic ipset sets update"
    local cron_job="0 2 * * * /usr/local/bin/vpsctl firewall --only-update-ipset-sets &>>/tmp/vpsctl-firewall-cron.log"
    if crontab -l 2>/dev/null | grep -qxF "${cron_job}"; then
        warn "Update ipset sets job already exists in crontab"
    else
        (
            crontab -l 2>/dev/null
            echo "${cron_job}"
        ) | crontab -
        echo "Update ipset sets job added to crontab"
    fi
    std::tips::title "Current crontab entries"
    crontab -l

    std::tips::title "Creating systemd service for ipset-restore"
    std::path::dir::ensure /etc/ipset/services
    local ipset_restore_service="/etc/ipset/services/ipset-restore.service"
    cat >"${ipset_restore_service}" <<EOF
[Unit]
Description=Restore ipset sets
Before=network-pre.target
Wants=network-pre.target
DefaultDependencies=no

[Service]
Type=oneshot
ExecStart=/sbin/ipset restore <${ipset_save_file}
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    std::tips::title "Linking systemd service for ipset-restore"
    systemctl link "${ipset_restore_service}"

    std::tips::title "Enabling and restarting ipset-restore service"
    systemctl daemon-reload
    systemctl enable ipset-restore.service
    # systemctl restart ipset-restore.service

    local ufw_ipv4_before_rules="/etc/ufw/before.rules"
    local ufw_ipv4_before_input="ufw-before-input"
    local ufw_ipv6_before_rules="/etc/ufw/before6.rules"
    local ufw_ipv6_before_input="ufw6-before-input"
    std::tips::title "Adding ipset rules to UFW"
    for name in "${!ip_sets[@]}"; do
        if vpsctl_firewall_is_ipv4_sets "${name}"; then
            local ufw_before_input="${ufw_ipv4_before_input}"
            local ufw_before_rules="${ufw_ipv4_before_rules}"
        else
            local ufw_before_input="${ufw_ipv6_before_input}"
            local ufw_before_rules="${ufw_ipv6_before_rules}"
        fi
        if vpsctl_firewall_is_blacklist_sets "${name}"; then
            local rule="-A ${ufw_before_input} -m set --match-set ${name} src -j DROP"
        else
            local rule="-A ${ufw_before_input} -m set ! --match-set ${name} src -j DROP"
        fi
        if ! grep -qxF -- "${rule}" "${ufw_before_rules}"; then
            sed -i "/^COMMIT/i ${rule}" "${ufw_before_rules}"
            echo "The rule '${rule}' added to ${ufw_before_rules}"
        else
            warn "The rule '${rule}' already exist in ${ufw_before_rules}, skipping insertion."
        fi
    done

    std::tips::title "Checking and enabling UFW IPv6 support"
    local ufw_default_conf="/etc/default/ufw"
    if grep -qx -- "IPV6=no" "${ufw_default_conf}"; then
        sed -i 's/^IPV6=no/IPV6=yes/' "${ufw_default_conf}"
    fi

    std::tips::title "Configuring UFW default rules"
    ufw default deny incoming
    ufw default allow outgoing

    std::tips::title "Allowing http(s) && ssh services"
    ufw allow http
    ufw allow https
    # ufw allow ssh
    ufw allow 9443/tcp
    ufw allow 9922/tcp

    std::tips::title "Enabling UFW"
    ufw enable

    std::tips::title "Restarting UFW service to apply changes"
    systemctl restart ufw

    std::tips::title "Checking UFW status"
    sleep 2
    ufw status verbose
}
