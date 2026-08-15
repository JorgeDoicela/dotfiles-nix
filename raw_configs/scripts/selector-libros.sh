#!/usr/bin/env bash
# Selector estricto de libros de estudio curados con Rofi para Hyprland (Portátil y Profesional)

LIBROS_DIR="$HOME/Documentos/Libros cristianos"

# Diccionario de libros específicos (Título que se muestra en Rofi | Nombre del archivo físico)
declare -A coleccion
coleccion["📖 Biblia de estudio Diario Vivir (NTV)"]="Biblia de estudio Diario vivir (NTV).pdf"
coleccion["📖 Biblia de estudio MacArthur"]="Biblia de estudio de John F. MacArthur (Versión Escaneada).pdf"
coleccion["📚 Auxiliar Bíblico Portavoz - Willmington"]="Auxiliar bíblico Portavoz - Harold L. Willmington.pdf"
coleccion["🕊 Conociendo al Dios vivo - Paul Washer"]="Conociendo al Dios vivo (RVR) - Paul D. Washer.pdf"
coleccion["⛪ Institución de la Religión (Tomo 1) - Calvino"]="Institución de la religión (Tomo 1) - Juan Calvino.pdf"
coleccion["⛪ Institución de la Religión (Tomo 2) - Calvino"]="Institución de la religión (Tomo 2) - Juan Calvino.pdf"
coleccion["👪 Teología de la Familia"]="Teologia de la Familia.pdf"

# Generar la lista de títulos de forma ordenada
lista_titulos=""
for titulo in "${!coleccion[@]}"; do
    lista_titulos+="$titulo\n"
done

# Calcular bordes igual que rofilaunch.sh del sistema
hypr_border=$(hyprctl -j getoption decoration:rounding 2>/dev/null | jq -r '.int // 10')
hypr_width=$(hyprctl -j getoption general:border_size 2>/dev/null | jq -r '.int // 2')
wind_border=$((hypr_border * 3))
[ "$hypr_border" -eq 0 ] && elem_border="10" || elem_border=$((hypr_border * 2))
r_override="window {border: ${hypr_width}px; border-radius: ${wind_border}px;} element {border-radius: ${elem_border}px;}"

# Mostrar la lista descriptiva en Rofi usando el tema del sistema (clipboard = dmenu con wallbash)
seleccion=$(echo -e "$lista_titulos" | sed '/^$/d' | sort | rofi \
    -dmenu \
    -i \
    -p "󰗚 Colección de Estudio" \
    -theme "~/.config/rofi/config.rasi" \
    -theme-str "$r_override" \
    -theme-str "window {width: 38em;}" \
    -theme-str "inputbar entry { placeholder: \"Buscar libro...\"; }")

# Abrir el libro seleccionado con tu visor por defecto (Sioyek/Zathura)
if [ -n "$seleccion" ]; then
    archivo="${coleccion[$seleccion]}"
    ruta_completa="$LIBROS_DIR/$archivo"
    
    if [ -f "$ruta_completa" ]; then
        xdg-open "$ruta_completa" &
    else
        notify-send -a "Biblioteca" -t 4000 "Error" "No se encuentra el archivo:\n$archivo"
    fi
fi
