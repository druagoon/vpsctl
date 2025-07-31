# @cmd Create a new user
# @flag    --sudo                   Grant sudo permissions
# @arg name=ops                     Name of the user to create
user() {
    std::tips::info "Creating a new user"

    local username="${argc_name:-ops}"
    std::tips::title "Creating user $(std::color::green "${username}")"
    if id "${username}" &>/dev/null; then
        warn "User ${username} already exists."
    else
        adduser "${username}"
    fi

    if std::bool::is_true "${argc_sudo:-}"; then
        # std::tips::title "Adding user $(std::color::green "${username}") to $(std::color::green sudo) group"
        # if id -nG "${username}" | grep -qw sudo; then
        #     warn "User ${username} is already in sudo group."
        # else
        #     usermod -aG sudo "${username}"
        # fi

        std::tips::title "Configuring sudo permissions for user $(std::color::green "${username}")"
        local sudo_file="/etc/sudoers.d/${username}"
        local entry="${username} ALL=(ALL) NOPASSWD: ALL"
        if std::fs::file::has_line "${sudo_file}" "${entry}"; then
            warn "Sudo entry for $(std::color::green "${username}") already exists in ${sudo_file}."
        else
            echo "${entry}" | tee "${sudo_file}" >/dev/null
            chmod 0640 "${sudo_file}"
        fi

        std::tips::title "Showing sudo file ${sudo_file}"
        cat "${sudo_file}"
    fi
}
