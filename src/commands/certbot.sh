# @cmd Setup Certbot for SSL certificates
# @option    --domain                   Specify the domain for which to obtain the SSL certificate
certbot() {
    std::tips::info "Setting up Certbot for SSL"

    local operator_home="${HOME}"
    if [[ -n "${SUDO_USER:-}" ]]; then
        operator_home="$(eval echo "~${SUDO_USER}")"
    fi

    local credentials_file="${operator_home}/.secrets/certbot/cloudflare.ini"
    read -r -p "Please ensure the domain uses Cloudflare DNS and ${credentials_file} exists? (Y/n) " answer
    if std::bool::is_false "${answer:-y}"; then
        error "Operation cancelled"
        exit 1
    fi

    if [[ ! -f "${credentials_file}" ]]; then
        error "Missing Cloudflare credentials file: ${credentials_file}"
        return 1
    fi

    chmod 600 "${credentials_file}"

    std::tips::title "Installing dependencies"
    apt install -y python3 python3-dev python3-venv libaugeas-dev gcc

    std::tips::title "Creating a virtual environment"
    if [[ -d /opt/certbot ]]; then
        warn "Virtual environment already exists at /opt/certbot"
    else
        python3 -m venv /opt/certbot/
        /opt/certbot/bin/pip install --upgrade pip
    fi

    std::tips::title "Installing certbot in the virtual environment"
    local source="/opt/certbot/bin/certbot"
    local certbot="/usr/bin/certbot"
    if std::cmd::exists "${source}" \
        && /opt/certbot/bin/pip show certbot >/dev/null 2>&1 \
        && /opt/certbot/bin/pip show certbot-dns-cloudflare >/dev/null 2>&1; then
        warn "Certbot and Cloudflare DNS plugin already installed at ${source}"
    else
        /opt/certbot/bin/pip install certbot certbot-dns-cloudflare
        ln -sfv "${source}" "${certbot}"
    fi

    std::tips::title "Obtaining SSL certificate"
    local domain="${argc_domain:-}"
    if [[ -n "${domain}" ]]; then
        if ${certbot} certificates | grep -qF "${domain}"; then
            warn "Certificate already exists for domain: ${domain}"
        else
            ${certbot} certonly \
                --dns-cloudflare \
                --dns-cloudflare-credentials "${credentials_file}" \
                -d "${domain}"
            echo "Certificate obtained for domain: ${domain}"
        fi
    else
        ${certbot} certonly \
            --dns-cloudflare \
            --dns-cloudflare-credentials "${credentials_file}"
    fi

    std::tips::title "Automatic certificate renewal"
    local cron_job="0 0 1 * * ${certbot} renew >>/tmp/certbot-renew.log 2>&1"
    if crontab -l 2>/dev/null | grep -qxF "${cron_job}"; then
        warn "Certbot renewal job already exists in crontab"
    else
        (
            crontab -l 2>/dev/null
            echo "${cron_job}"
        ) | crontab -
        echo "Certbot renewal job added to crontab"
    fi
    std::tips::title "Current crontab entries"
    crontab -l

    # if ! grep -qxF "${cron_job}" /etc/crontab; then
    #     echo "Adding Certbot renewal job to crontab"
    #     echo "${cron_job}" | tee -a /etc/crontab >/dev/null
    # else
    #     echo "Certbot renewal job already exists in /etc/crontab"
    # fi
    # std::tips::title "Current crontab entries:"
    # cat /etc/crontab
}
