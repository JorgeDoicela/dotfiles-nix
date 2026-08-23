#!/usr/bin/env bash
# Selector de libros de estudio curados con Rofi para Hyprland

LIBROS_DIR="$HOME/Documentos/Libros cristianos"

opciones=(
    "📖 Biblia de estudio Diario Vivir (NTV)"
    "📖 Biblia de estudio MacArthur"
    "📚 Auxiliar Bíblico Portavoz - Willmington"
    "🕊 Conociendo al Dios vivo - Paul Washer"
    "⛪ Institución de la Religión (Tomo 1) - Calvino"
    "⛪ Institución de la Religión (Tomo 2) - Calvino"
)

# Calcular estilo de bordes según Hyprland
hypr_border=$(hyprctl -j getoption decoration:rounding 2>/dev/null | jq -r '.int // 10' 2>/dev/null || echo 10)
hypr_width=$(hyprctl -j getoption general:border_size 2>/dev/null | jq -r '.int // 2' 2>/dev/null || echo 2)
wind_border=$((hypr_border * 3))
[ "$hypr_border" -eq 0 ] && elem_border="10" || elem_border=$((hypr_border * 2))
r_override="window {border: ${hypr_width}px; border-radius: ${wind_border}px;} element {border-radius: ${elem_border}px;}"

# Mostrar la lista curada en Rofi
seleccion=$(printf '%s\n' "${opciones[@]}" | rofi \
    -dmenu \
    -i \
    -p "󰗚 Colección de Estudio" \
    -theme "$HOME/.config/rofi/config.rasi" \
    -theme-str "$r_override" \
    -theme-str "window {width: 40em;}" \
    -theme-str "inputbar entry { placeholder: \"Buscar libro de estudio...\"; }")

if [ -z "$seleccion" ]; then
    exit 0
fi

# Mapeo directo y robusto por coincidencia de patrones
case "$seleccion" in
    *"Diario Vivir"*) archivo="Biblia de estudio Diario vivir (NTV).pdf" ;;
    *"MacArthur"*) archivo="Biblia de estudio de John F. MacArthur (Versión Escaneada).pdf" ;;
    *"Willmington"*) archivo="Auxiliar bíblico Portavoz - Harold L. Willmington.pdf" ;;
    *"Paul Washer"*) archivo="Conociendo al Dios vivo (RVR) - Paul D. Washer.pdf" ;;
    *"Calvino"*"Tomo 1"*) archivo="Institución de la religión (Tomo 1) - Juan Calvino.pdf" ;;
    *"Calvino"*"Tomo 2"*) archivo="Institución de la religión (Tomo 2) - Juan Calvino.pdf" ;;
    *) archivo="" ;;
esac

if [ -n "$archivo" ]; then
    ruta_completa="$LIBROS_DIR/$archivo"
    if [ -f "$ruta_completa" ]; then
        if command -v sioyek >/dev/null 2>&1; then
            setsid sioyek "$ruta_completa" >/dev/null 2>&1 &
        else
            setsid xdg-open "$ruta_completa" >/dev/null 2>&1 &
        fi
    else
        notify-send -a "Biblioteca" "Error" "No se encuentra el archivo:\n$archivo"
    fi
fi
