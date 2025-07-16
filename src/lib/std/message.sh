std::message::format() {
    local prefix="$1"
    shift
    local format="$1"
    shift
    printf "${prefix}: ${format}\n" "$@"
}

std::message::info() {
    local msg="$(std::message::format "INFO" "$@")"
    std::color::green "${msg}"
}

std::message::warning() {
    local msg="$(std::message::format "WARNING" "$@")"
    std::color::yellow "${msg}"
}

std::message::error() {
    local msg="$(std::message::format "ERROR" "$@")"
    std::color::red "${msg}" >&2
}

std::message::fatal() {
    std::message::error "$@"
    exit 1
}
