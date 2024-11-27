#!/bin/sh -e

bg_black='\033[40m'
bg_red='\033[41m'
bg_green='\033[42m'
bg_yellow='\033[43m'
bg_blue='\033[44m'
bg_magenta='\033[45m'
bg_cyan='\033[46m'
bg_white='\033[47m'
bg_default='\033[49m'

text_black='\033[30m'
text_default='\033[39m'

has() {
    command -v "$1" >/dev/null 2>&1
}

os() {
	. /etc/os-release
	printf "%s" "$PRETTY_NAME"
}

shell() {
	printf "%s" "$(basename "$SHELL")"
}

wm() {
    id=$(xprop -root -notype _NET_SUPPORTING_WM_CHECK)
    id=${id##* }
    wm=$(xprop -id "$id" -notype -len 100 -f _NET_WM_NAME 8t)
    wm=${wm##*WM_NAME = \"}
    wm=${wm%%\"*}
    printf "%s" "$wm"
}

uptimesys() {
		printf "$(uptime -p | sed 's/up //')"
}

pkg() {
    os=$(uname -s)
    packages=$(
        case $os in
            (Linux*)
                has xbps-query && xbps-query -l
                has pacman-key && pacman -Qq
                has dpkg       && dpkg-query -f '.\n' -W
                has rpm        && rpm -qa
                has apk        && apk info
                ;;
            (Darwin*)
                has brew       && printf '%s\n' /usr/local/Cellar/*
                has pkgin      && pkgin list
                ;;
            (FreeBSD*|DragonFly*)
                pkg info
                ;;
            (OpenBSD*)
                printf '%s\n' /var/db/pkg/*/
                ;;
            (*)
                printf "Unsupported OS: %s\n" "$os" >&2
                return 1
                ;;
        esac | wc -l
    )

    packages=$(printf "$packages" | xargs)

    printf "%s" "$packages"
}

printf "
${bg_yellow}${text_black} os ${text_default}${bg_default} $(os)
${bg_cyan}${text_black} sh ${text_default}${bg_default} $(shell)
${bg_magenta}${text_black} wm ${text_default}${bg_default} $(wm)
${bg_blue}${text_black} up ${text_default}${bg_default} $(uptimesys)
${bg_red}${text_black} pk ${text_default}${bg_default} $(pkg)

"
