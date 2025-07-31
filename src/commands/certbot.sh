# @cmd Setup Certbot for SSL certificates
# @option    --domain                   Specify the domain for which to obtain the SSL certificate
certbot() {
    std::tips::info "Setting up Certbot for SSL"

    read -r -p "Please ensure your domain is pointed to this server? (Y/n) " answer
    if std::bool::is_false "${answer:-y}"; then
        error "Operation cancelled"
        exit 1
    fi

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
    if std::cmd::exists "${source}"; then
        warn "Certbot already installed at ${source}"
    else
        /opt/certbot/bin/pip install certbot
        ln -sfv "${source}" "${certbot}"
    fi

    std::tips::title "Obtaining SSL certificate"
    local domain="${argc_domain:-}"
    if [[ -n "${domain}" ]]; then
        if ${certbot} certificates | grep -qF "${domain}"; then
            warn "Certificate already exists for domain: ${domain}"
        else
            ${certbot} certonly --standalone -d "${domain}"
            echo "Certificate obtained for domain: ${domain}"
        fi
    else
        ${certbot} certonly --standalone
    fi

    std::tips::title "Automatic certificate renewal"
    local cron_job="0 0 1 * * ${certbot} renew -q"
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
