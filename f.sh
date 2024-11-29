#!/bin/sh -e

# Colores de fondo y texto
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

# Función para verificar si un comando existe
has() {
	command -v "$1" >/dev/null 2>&1
}

# Detectar el sistema operativo
os() {
	. /etc/os-release
	printf "%s" "$PRETTY_NAME"
}

# Detectar el shell en uso
shell() {
	printf "%s" "$(basename "$SHELL")"
}

# Detectar el gestor de ventanas
wm() {
	# Intentar obtener el gestor de ventanas desde DESKTOP_SESSION
	[ -n "$wm" ] || wm="$DESKTOP_SESSION"

	# Para gestores de ventanas EWMH
	if [ -z "$wm" ] && [ -n "$DISPLAY" ] && has xprop; then
		id=$(xprop -root -notype _NET_SUPPORTING_WM_CHECK | awk '{print $NF}')
		[ -n "$id" ] && wm=$(xprop -id "$id" -notype -f _NET_WM_NAME 8t | awk -F\" '/_NET_WM_NAME/ {print $2}')
	fi

	# Para gestores de ventanas no EWMH
	if [ -z "$wm" ] || [ "$wm" = "LG3D" ]; then
		wm=$(ps -e | grep -m 1 -o \
			-e "sway" \
			-e "kiwmi" \
			-e "wayfire" \
			-e "sowm" \
			-e "catwm" \
			-e "fvwm" \
			-e "dwm" \
			-e "2bwm" \
			-e "monsterwm" \
			-e "tinywm" \
			-e "xmonad")
	fi

	printf "%s" "$wm"
}

# Obtener el tiempo de actividad del sistema
uptimesys() {
	uptime -p | sed 's/^up //'
}

# Contar los paquetes instalados
pkg() {
	case "$(uname -s)" in
		Linux*)
			if has xbps-query; then xbps-query -l | wc -l
			elif has pacman; then pacman -Qq | wc -l
			elif has dpkg; then dpkg-query -f '.\n' -W | wc -l
			elif has rpm; then rpm -qa | wc -l
			elif has apk; then apk info | wc -l
			else echo 0
			fi
			;;
		Darwin*)
			if has brew; then ls /usr/local/Cellar/* | wc -l
			elif has pkgin; then pkgin list | wc -l
			else echo 0
			fi
			;;
		FreeBSD*|DragonFly*)
			pkg info | wc -l
			;;
		OpenBSD*)
			find /var/db/pkg -type d -mindepth 1 -maxdepth 1 | wc -l
			;;
		*)
			echo "Unsupported OS" >&2
			return 1
			;;
	esac
}

# Imprimir información del sistema con dibujo ASCII
print_info() {
	printf "
	 ${bg_yellow}${text_black} os ${text_default}${bg_default} $(os)
${bg_default}(\ /)    ${bg_green}${text_black} kr ${text_default}${bg_default} $(shell)
${bg_default}( . .)   ${bg_cyan}${text_black} sh ${text_default}${bg_default} $(wm)
${bg_default}c(${bg_magenta}${text_black}\"${text_default}${bg_default})(${bg_magenta}${text_black}\"${text_default}${bg_default})  ${bg_blue}${text_black} wm ${text_default}${bg_default} $(uptimesys)
\n"
}

# Ejecutar
print_info
