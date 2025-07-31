# @cmd Setup gost for reverse proxy
# @option    --domain!                                  Specify the domain for gost listener
# @option    --web-password! <PASSWORD>                 Password for web handler
# @option    --socks-password! <PASSWORD>               Password for socks handler
gost() {
    std::tips::info "Setting up gost for reverse proxy"

    std::tips::title "Installing gost"
    if std::cmd::exists /usr/local/bin/gost; then
        warn "gost is already installed"
    else
        bash <(curl -fsSL https://github.com/go-gost/gost/raw/master/install.sh)
    fi

    local domain="${argc_domain:-}"
    local web_password="${argc_web_password:-}"
    local socks_password="${argc_socks_password:-}"

    if [[ -d /opt/gost/etc ]]; then
        mkdir -p /opt/gost/etc
    fi

    std::tips::title "Creating gost configuration"
    local gost_config="/opt/gost/etc/gost.yaml"
    cat >"${gost_config}" <<EOF
services:
  - name: web
    addr: 0.0.0.0:443
    handler:
      type: http2
      auth:
        username: web
        password: "${web_password}"
      metadata:
        knock: www.google.com
        probeResist: code:403
    listener:
      type: http2
  - name: socks
    addr: 0.0.0.0:9443
    handler:
      type: socks5
      metadata:
        notls: true
      auth:
        username: sk
        password: "${socks_password}"
    listener:
      type: tls
tls:
    certFile: /etc/letsencrypt/live/${domain}/fullchain.pem
    keyFile: /etc/letsencrypt/live/${domain}/privkey.pem
log:
  output: stderr
  level: info
  format: json
  rotation:
    maxSize: 100
    maxAge: 10
    maxBackups: 3
    localTime: false
    compress: false
EOF

    std::tips::title "Creating gost systemd service"
    local gost_systemd="/opt/gost/etc/gost.service"
    cat >"${gost_systemd}" <<EOF
[Unit]
Description=GO Simple Tunnel
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/gost -C /opt/gost/etc/gost.yaml
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    std::tips::title "Linking systemd service for gost"
    systemctl link "${gost_systemd}"

    std::tips::title "Enabling and restarting gost service"
    systemctl daemon-reload
    systemctl enable gost
    systemctl restart gost

    std::tips::title "Checking gost service status"
    sleep 2
    systemctl status gost
}
