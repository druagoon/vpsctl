_argc_before() {
    if std::bool::is_true "${argc_debug:-}"; then
        set -x
    fi
}
