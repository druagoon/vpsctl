# @cmd SSH Guard
#
# Monitor SSH logs and blocks IPs that exceed a specified threshold of failed login attempts,
# while respecting a whitelist of IPs that should not be blocked.
#
# @flag   -n --dry-run                      Perform a dry run without blocking IPs
# @flag   -a --all                          Process all times logs
# @option    --since=today <DATE>           Specify the start time for log processing
# @option    --until <DATE>                 Specify the end time for log processing
# @option    --log-file <PATH>              Specify the log file to record blocked IPs
# @option    --threshold=3 <NUMBER>         Set the threshold for blocking
# @option    --whitelist-file <PATH>        Specify the file containing whitelisted IPs
ssh-guard() {
    std::tips::info "Running SSH Guard"

    local log_file="${argc_log_file:-/opt/vpsctl/log/ssh-block.log}"
    local dry_run="${argc_dry_run:-0}"
    if std::bool::is_true "${dry_run}"; then
        warn "Dry run mode enabled. No IPs will be blocked."
    fi
    local threshold="${argc_threshold:-3}"
    local whitelist_file="${argc_whitelist_file:-/opt/vpsctl/etc/ssh-guard/whitelist.txt}"

    local -a opts=()
    local is_all="${argc_all:-0}"
    local since="${argc_since:-today}"
    local until="${argc_until:-}"
    if std::bool::is_false "${is_all}"; then
        opts+=("--since" "${since}")
        if [[ -n "${until}" ]]; then
            opts+=("--until" "${until}")
        fi
    fi

    local log_dir="$(dirname "${log_file}")"
    if [[ ! -d "${log_dir}" ]]; then
        mkdir -p "${log_dir}"
    fi
    local whitelist_dir="$(dirname "${whitelist_file}")"
    if [[ ! -d "${whitelist_dir}" ]]; then
        mkdir -p "${whitelist_dir}"
    fi

    local time_now="$(date --rfc-3339=seconds | sed 's/ /T/')"

    # 1. Collect all IPs that appeared in SSH logs (all types of logs)
    local all_ips="$(journalctl -u ssh "${opts[@]}" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')"

    # 2. Get IPs that successfully logged in via public key authentication
    # local accepted_ips="$(journalctl -u ssh "${opts[@]}" | grep 'Accepted publickey' | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sort -u)"
    # local accepted_ips="$(journalctl -u ssh "${opts[@]}" | grep -P 'sshd\[\d+\]: Accepted publickey for \S+ from (([0-9]{1,3}\.){3}[0-9]{1,3}) port \d+ ssh2' | sed -nE 's/.*from (([0-9]{1,3}\.){3}[0-9]{1,3}) port.*/\1/p' | sort -u)"
    local accepted_ips="$(journalctl -u ssh "${opts[@]}" | gawk '/sshd\[.*\]: Accepted publickey for \S+ from ([0-9]{1,3}\.){3}[0-9]{1,3} port [0-9]+ ssh2/ { for (i=1; i<=NF; i++) { if ($i == "from") print $(i+1) } }' | sort -u)"

    # 3. Load whitelist IPs (can be empty)
    if [ -f "${whitelist_file}" ]; then
        local whitelist="$(cat "${whitelist_file}")"
    else
        local whitelist=""
    fi

    # 4. Filter out IPs that have successfully logged in via public key + whitelist IPs
    local filtered_ips=$(echo "${all_ips}" | grep -v -F -f <(echo "${accepted_ips}") | grep -v -F -f <(echo "${whitelist}"))

    # 5. Count remaining IPs and select those exceeding the threshold
    local bad_ips="$(echo "${filtered_ips}" | sort | uniq -c | sort -nr | awk -v threshold="${threshold}" '$1 >= threshold {print $2, $1}')"

    # 6. Blocking logic
    while read -r ip count; do
        if [ -z "${ip}" ]; then continue; fi

        # Whitelist check again (for safety)
        if echo "${whitelist}" | grep -qx "${ip}"; then
            local line="${time_now}  SKIPPED ${ip} (in whitelist)  [${count} times]"
            if std::bool::is_true "${dry_run}"; then
                echo "${line}"
            else
                echo "${line}" | tee -a "${log_file}"
            fi
            continue
        fi

        # Check if blocked
        if ! is_ip_denied "${ip}"; then
            local line="${time_now}  BLOCKED ${ip}  [${count} times]"
            if std::bool::is_true "${dry_run}"; then
                echo "${line}"
            else
                ufw deny from "${ip}" comment "ssh-guard: auto-block ${count} hits"
                echo "${line}" | tee -a "${log_file}"
            fi
        else
            local line="${time_now}  SKIPPED ${ip} (already denied)  [${count} times]"
            if std::bool::is_true "${dry_run}"; then
                echo "${line}"
            else
                echo "${line}" | tee -a "${log_file}"
            fi
        fi
    done <<<"${bad_ips}"
}
