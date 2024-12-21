#!/bin/bash
# Definición de colores
bold=$(tput bold)
normal=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
blue=$(tput setaf 4)
yellow=$(tput setaf 3)
cyan=$(tput setaf 6)
magenta=$(tput setaf 5)
white=$(tput setaf 7)
black=$(tput setaf 0)
bg_blue=$(tput setab 4)
bg_black=$(tput setab 0)
dim=$(tput dim)
# Variable para rastrear si estamos dentro de un bloque de código

clear
in_code_block=false
code_fence_pattern="^\`\`\`"
color_text() {
    local text="$1"
    local formatted_text="$text"
    # Verificar si es el inicio o fin de un bloque de código
    if [[ "$text" =~ $code_fence_pattern ]]; then
        if [ "$in_code_block" = false ]; then
            in_code_block=true
            # Colorear los ``` y el lenguaje si está especificado
            formatted_text=$(echo -n "$formatted_text" | sed -E "s/(\`\`\`)([[:alnum:]]*)/${bold}${red}\1${red}\2${normal}/")
            echo -e "$formatted_text"
            return
        else
            in_code_block=false
            # Colorear los ``` de cierre
            formatted_text=$(echo -n "$formatted_text" | sed -E "s/(\`\`\`)/${bold}${red}\1${normal}/")
            echo -e "$formatted_text"
            return
        fi
    fi
    if [ "$in_code_block" = true ]; then
        # Estamos dentro de un bloque de código
        # Agregar fondo negro tenue
        formatted_text="${dim}${bg_black} $formatted_text ${normal}"
        echo -e "$formatted_text"
        return
    fi
    # Procesamiento normal del texto fuera de bloques de código
    # Colorear código inline
    formatted_text=$(echo -n "$formatted_text" | sed -E "s/\`([^\`]+)\`/${bold}${bg_blue}${black}\1${normal}/g")
    # Colorear negrita
    formatted_text=$(echo -n "$formatted_text" | sed -E "s/\*\*([^\*]+)\*\*/${bold}\1${normal}/g")
    # Colorear itálica
    formatted_text=$(echo -n "$formatted_text" | sed -E "s/\*([^\*]+)\*/${bold}${white}\1${normal}/g")
    # Colorear los encabezados de diferentes niveles
    if [[ "$text" =~ ^##### ]]; then
        formatted_text=$(echo -n "$formatted_text" | sed -E "s/^#####.*/${magenta}&${normal}/")
    elif [[ "$text" =~ ^#### ]]; then
        formatted_text=$(echo -n "$formatted_text" | sed -E "s/^####.*/${yellow}&${normal}/")
    elif [[ "$text" =~ ^### ]]; then
        formatted_text=$(echo -n "$formatted_text" | sed -E "s/^###.*/${cyan}&${normal}/")
    elif [[ "$text" =~ ^## ]]; then
        formatted_text=$(echo -n "$formatted_text" | sed -E "s/^##.*/${blue}&${normal}/")
    elif [[ "$text" =~ ^# ]]; then
        formatted_text=$(echo -n "$formatted_text" | sed -E "s/^#.*/${bold}${green}&${normal}/")
    elif [[ "$text" =~ ^[[:space:]]*- ]]; then
        formatted_text=$(echo -n "$formatted_text" | sed -E "s/^([[:space:]]*)(-[[:space:]])(.*)/${bold}${yellow}\1\2${normal}\3/")
    elif [[ "$text" =~ ^[[:space:]]*[0-9]+\. ]]; then
        formatted_text=$(echo -n "$formatted_text" | sed -E "s/^([[:space:]]*)([0-9]+\.[[:space:]])(.*)/${bold}${yellow}\1\2${normal}\3/")
    elif [[ "$text" =~ ^[[:space:]]*\> ]]; then
        formatted_text=$(echo -n "$formatted_text" | sed -E "s/^([[:space:]]*>)(.*)/${bold}${cyan}\1${normal}\2/")
    elif [[ "$text" =~ \[.*\]\(.*\) ]]; then
        formatted_text=$(echo -n "$formatted_text" | sed -E "s/(\[.*\])(\(.*\))/${bold}${red}\1\2${normal}/")
    fi
    echo -e "$formatted_text"
}
# Verifica si se proporciona un archivo
if [ -z "$1" ]; then
    echo "Uso: $0 <archivo.md>"
    exit 1
fi
file="$1"
if [ ! -f "$file" ]; then
    echo "El archivo $file no existe."
    exit 1
fi
# Lee el archivo línea por línea
while IFS= read -r line; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    color_text "$line"
done < "$file"
