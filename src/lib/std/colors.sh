## Color functions
##
## Usage:
## Use any of the functions below to color or format a portion of a string.
##
##   echo "before $(std::color::red this is red) after"
##   echo "before $(std::color::green_bold this is green_bold) after"
##
## Color output will be disabled if `NO_COLOR` environment variable is set
## in compliance with https://no-color.org/
##
std::color::display() {
    local color="$1"
    shift
    if [[ -z ${NO_COLOR+x} ]]; then
        printf "${color}%b\e[0m\n" "$*"
    else
        printf "%b\n" "$*"
    fi
}

std::color::red() { std::color::display "\e[31m" "$*"; }
std::color::green() { std::color::display "\e[32m" "$*"; }
std::color::yellow() { std::color::display "\e[33m" "$*"; }
std::color::blue() { std::color::display "\e[34m" "$*"; }
std::color::magenta() { std::color::display "\e[35m" "$*"; }
std::color::cyan() { std::color::display "\e[36m" "$*"; }
std::color::bold() { std::color::display "\e[1m" "$*"; }
std::color::underlined() { std::color::display "\e[4m" "$*"; }
std::color::red_bold() { std::color::display "\e[1;31m" "$*"; }
std::color::green_bold() { std::color::display "\e[1;32m" "$*"; }
std::color::yellow_bold() { std::color::display "\e[1;33m" "$*"; }
std::color::blue_bold() { std::color::display "\e[1;34m" "$*"; }
std::color::magenta_bold() { std::color::display "\e[1;35m" "$*"; }
std::color::cyan_bold() { std::color::display "\e[1;36m" "$*"; }
std::color::red_underlined() { std::color::display "\e[4;31m" "$*"; }
std::color::green_underlined() { std::color::display "\e[4;32m" "$*"; }
std::color::yellow_underlined() { std::color::display "\e[4;33m" "$*"; }
std::color::blue_underlined() { std::color::display "\e[4;34m" "$*"; }
std::color::magenta_underlined() { std::color::display "\e[4;35m" "$*"; }
std::color::cyan_underlined() { std::color::display "\e[4;36m" "$*"; }
