#!/usr/bin/env bash
# ==============================================================================
# ORQUESTADOR DE CAPTURAS DE PANTALLA NATIVO PARA WAYLAND / HYPRLAND
# ==============================================================================
# Filosofía Unix: grim + slurp + swappy + wl-clipboard
# Cero demonios residentes, 100% nativo Wayland, consumo 0 en reposo.
#
# Uso:
#   screenshot.sh [modo] [accion]
#
# Modos:
#   area     : Selección interactiva con el ratón (slurp)
#   window   : Detección automática de la ventana activa (hyprctl activewindow)
#   output   : Monitor actualmente enfocado
#   screen   : Todos los monitores / escritorio completo
#
# Acciones:
#   edit     : Abre el editor visual interactivo swappy (anotaciones, flechas, blur)
#   copy     : Copia directo al portapapeles en silencio (rápido para chats/PRs)
#   save     : Guarda en ~/Imágenes/Capturas/ y copia simultáneamente al portapapeles
# ==============================================================================

set -euo pipefail
IFS=$'\n\t'

# Directorio de guardado estructurado
SAVE_DIR="${XDG_PICTURES_DIR:-$HOME/Imágenes}/Capturas"
mkdir -p "$SAVE_DIR"

MODE="${1:-area}"
ACTION="${2:-edit}"
DELAY="${3:-0}"

# Temporizador opcional (útil para capturar menús desplegables o tooltips)
if [[ "$DELAY" =~ ^[0-9]+$ ]] && [ "$DELAY" -gt 0 ]; then
    sleep "$DELAY"
fi

# 1. Obtener la geometría o selector de captura
GEOM=""
OUTPUT_TARGET=""

case "$MODE" in
    area)
        # Selección interactiva de área con colores acordes al tema WhiteSur / Dark
        GEOM=$(slurp -b "#1a1b2680" -c "#ffffff" -s "#ffffff15" -w 2 2>/dev/null) || exit 0
        if [ -z "$GEOM" ]; then
            exit 0
        fi
        ;;
    window)
        # Consultar la ventana activa en Hyprland vía hyprctl JSON
        ACTIVE_WIN=$(hyprctl activewindow -j 2>/dev/null || echo "{}")
        AT=$(echo "$ACTIVE_WIN" | jq -r '.at // empty')
        SIZE=$(echo "$ACTIVE_WIN" | jq -r '.size // empty')

        if [ -n "$AT" ] && [ -n "$SIZE" ] && [ "$AT" != "null" ]; then
            X=$(echo "$ACTIVE_WIN" | jq -r '.at[0]')
            Y=$(echo "$ACTIVE_WIN" | jq -r '.at[1]')
            W=$(echo "$ACTIVE_WIN" | jq -r '.size[0]')
            H=$(echo "$ACTIVE_WIN" | jq -r '.size[1]')
            GEOM="${X},${Y} ${W}x${H}"
        else
            # Si no hay ventana enfocada, fallback a selección manual
            GEOM=$(slurp -b "#1a1b2680" -c "#ffffff" -s "#ffffff15" -w 2 2>/dev/null) || exit 0
            if [ -z "$GEOM" ]; then
                exit 0
            fi
        fi
        ;;
    output)
        # Captura exclusiva del monitor actualmente enfocado
        OUTPUT_TARGET=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused == true) | .name // empty')
        ;;
    screen|all)
        # Pantalla completa (sin recorte)
        ;;
    *)
        echo "Modo no reconocido: $MODE. Opciones: area, window, output, screen" >&2
        exit 1
        ;;
esac

# 2. Ejecutar la captura según la acción solicitada
case "$ACTION" in
    edit)
        TMP_FILE=$(mktemp /tmp/scr-edit-XXXXXX.png)
        trap 'rm -f "$TMP_FILE"' EXIT

        if [ "$MODE" = "output" ] && [ -n "$OUTPUT_TARGET" ]; then
            grim -o "$OUTPUT_TARGET" "$TMP_FILE"
        elif [ "$MODE" = "screen" ] || [ "$MODE" = "all" ]; then
            grim "$TMP_FILE"
        else
            grim -g "$GEOM" "$TMP_FILE"
        fi

        # Iniciar Swappy para anotaciones y blur
        swappy -f "$TMP_FILE"
        ;;

    copy)
        TMP_FILE=$(mktemp /tmp/scr-copy-XXXXXX.png)
        trap 'rm -f "$TMP_FILE"' EXIT

        if [ "$MODE" = "output" ] && [ -n "$OUTPUT_TARGET" ]; then
            grim -o "$OUTPUT_TARGET" "$TMP_FILE"
        elif [ "$MODE" = "screen" ] || [ "$MODE" = "all" ]; then
            grim "$TMP_FILE"
        else
            grim -g "$GEOM" "$TMP_FILE"
        fi

        wl-copy -t image/png < "$TMP_FILE"
        notify-send -a "Captura de Pantalla" -i "$TMP_FILE" \
            "Captura copiada al portapapeles" \
            "Lista para pegar (Ctrl+V)"
        ;;

    save)
        TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
        FILENAME="Captura_${TIMESTAMP}.png"
        FILEPATH="${SAVE_DIR}/${FILENAME}"

        if [ "$MODE" = "output" ] && [ -n "$OUTPUT_TARGET" ]; then
            grim -o "$OUTPUT_TARGET" "$FILEPATH"
        elif [ "$MODE" = "screen" ] || [ "$MODE" = "all" ]; then
            grim "$FILEPATH"
        else
            grim -g "$GEOM" "$FILEPATH"
        fi

        # Copiar también al portapapeles para máxima comodidad
        wl-copy -t image/png < "$FILEPATH"
        notify-send -a "Captura de Pantalla" -i "$FILEPATH" \
            "Captura guardada y copiada" \
            "Guardada en: ${FILENAME}"
        ;;

    *)
        echo "Acción no reconocida: $ACTION. Opciones: edit, copy, save" >&2
        exit 1
        ;;
esac
