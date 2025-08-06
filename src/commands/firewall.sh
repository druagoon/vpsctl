# @cmd Setup the UFW firewall
# @meta require-tools ufw,ipset
firewall() {
    std::tips::info "Setting up UFW firewall"

    std::tips::title "Configuring UFW default rules"
    ufw default deny incoming
    ufw default allow outgoing

    std::tips::title "Allowing http(s) && ssh services"
    ufw allow http
    ufw allow https
    # ufw allow ssh
    ufw allow 9443/tcp
    ufw allow 9922/tcp

    local ipv4_name="geoip-v4-cn"
    local ipv4_url="https://www.ipdeny.com/ipblocks/data/aggregated/cn-aggregated.zone"
    std::tips::title "Creating ipset $(std::color::green ${ipv4_name})"
    # ipset destroy "${ipv4_name}" 2>/dev/null || true
    ipset create "${ipv4_name}" hash:net family inet -exist
    ipset flush "${ipv4_name}"
    curl -fsSL "${ipv4_url}" | sed "s/^/add ${ipv4_name} /" | ipset restore

    local ipv6_name="geoip-v6-cn"
    local ipv6_url="https://www.ipdeny.com/ipv6/ipaddresses/aggregated/cn-aggregated.zone"
    std::tips::title "Creating ipset $(std::color::green ${ipv6_name})"
    # ipset destroy "${ipv6_name}" 2>/dev/null || true
    ipset create "${ipv6_name}" hash:net family inet6 -exist
    ipset flush "${ipv6_name}"
    curl -fsSL "${ipv6_url}" | sed "s/^/add ${ipv6_name} /" | ipset restore

    std::path::dir::ensure /etc/ipset/sets /etc/ipset/services
    local ipset_save_file="/etc/ipset/sets/cn.conf"
    std::tips::title "Saving ipset sets to ${ipset_save_file}"
    ipset save >"${ipset_save_file}"

    std::tips::title "Creating systemd service for ipset-restore"
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

    std::tips::title "Adding ipset ipv4 rules to UFW"
    local ufw_before_rules="/etc/ufw/before.rules"
    local ipv4_rule="-A ufw-before-input -m set ! --match-set ${ipv4_name} src -j DROP"
    if ! grep -qxF -- "${ipv4_rule}" "${ufw_before_rules}"; then
        sed -i "/^COMMIT/i ${ipv4_rule}" "${ufw_before_rules}"
        echo "IPv4 rules added to ${ufw_before_rules}"
    else
        warn "IPv4 rules already exist in ${ufw_before_rules}, skipping insertion."
    fi

    std::tips::title "Adding ipset ipv6 rules to UFW"
    local ufw_before6_rules="/etc/ufw/before6.rules"
    local ipv6_rule="-A ufw6-before-input -m set ! --match-set ${ipv6_name} src -j DROP"
    if ! grep -qxF -- "${ipv6_rule}" "${ufw_before6_rules}"; then
        sed -i "/^COMMIT/i ${ipv6_rule}" "${ufw_before6_rules}"
        echo "IPv6 rules added to ${ufw_before6_rules}"
    else
        warn "IPv6 rules already exist in ${ufw_before6_rules}, skipping insertion."
    fi

    std::tips::title "Checking and enabling UFW IPv6 support"
    local ufw_default_conf="/etc/default/ufw"
    if grep -qx -- "IPV6=no" "${ufw_default_conf}"; then
        sed -i 's/^IPV6=no/IPV6=yes/' "${ufw_default_conf}"
    fi

    std::tips::title "Restarting UFW service to apply changes"
    # ufw disable && ufw enable
    systemctl restart ufw

    std::tips::title "Checking UFW status"
    sleep 2
    ufw status verbose
}
