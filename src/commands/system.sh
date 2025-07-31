# @cmd Update system packages and install necessary tools
system() {
    std::tips::info "Updating system packages and installing necessary tools"

    std::tips::title "Updating system"
    apt update
    apt upgrade
    apt dist-upgrade
    apt autoremove
    apt clean
    echo "System packages updated successfully."

    std::tips::title "Installing necessary system packages"
    apt update
    apt install -y \
        curl \
        gawk \
        git \
        jq \
        vim \
        htop \
        ufw \
        fail2ban \
        sudo
    echo "Packages installed successfully."
}
