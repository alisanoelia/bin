#!/bin/bash
# Script para buscar interactivamente paquetes instalados en Void Linux usando fzf.

# 1. Lista todos los paquetes con 'xbps-query -l'.
# 2. Envía la lista a 'fzf' para la selección interactiva.
# 3. Usa la opción '--preview' de fzf para mostrar información detallada del paquete
#    que se está seleccionando en tiempo real.
#    - El comando dentro de preview extrae el nombre del paquete (la segunda columna)
#      y ejecuta 'xbps-query -R' sobre él.
# 4. Opciones '--height' y '--layout' para una mejor presentación.
# 5. El paquete seleccionado se guarda en la variable 'selected_line'.

selected_line=$(xbps-query -l | fzf --preview="xbps-query -R \$(echo {} | awk '{print \$2}')" --height=40% --layout=reverse)

# Si el usuario presionó Esc o Ctrl-C, fzf no devuelve nada.
if [ -z "$selected_line" ]; then
    echo "No se seleccionó ningún paquete."
    exit 0
fi

# Extrae solo el nombre del paquete de la línea seleccionada (ej: 'ii <paquete> ...')
pkg_name=$(echo "$selected_line" | awk '{print $2}')

# Opcional: Muestra un mensaje final con el paquete que elegiste.
echo "Paquete seleccionado: $pkg_name"

# Aquí podrías añadir más acciones, como desinstalar, reinstalar, etc.
# Por ejemplo, para desinstalar, podrías añadir:
# sudo xbps-remove "$pkg_name"