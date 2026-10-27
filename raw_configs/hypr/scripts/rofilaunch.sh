#!/usr/bin/env bash
# ==============================================================================
# LANZADOR ROFI REACTIVO AL MONITOR (WHITESUR LAUNCHPAD GRID)
# ==============================================================================
# Detecta dinámicamente si el monitor enfocado tiene margen reservado en el borde
# izquierdo (ej. compensación física por franja dañada en eDP-1) y adapta el padding
# para mantener simetría en monitores externos sin solaparse con áreas rotas.
# ==============================================================================
set -euo pipefail

if pgrep -x "rofi" >/dev/null 2>&1; then
    pkill -x "rofi"
    exit 0
fi

# Consultar margen izquierdo reservado del monitor actualmente enfocado
RES_L=$(hyprctl monitors -j 2>/dev/null | jq -r '(.[] | select(.focused == true) // .[0]) | .reserved[0] // 0' 2>/dev/null || echo 0)
[[ "$RES_L" =~ ^[0-9]+$ ]] || RES_L=0

ROFI_ARGS=("-show" "drun" "-theme" "$HOME/.config/rofi/launcher.rasi")

# Si el monitor tiene un margen izquierdo reservado (ej. eDP-1 con 228px), ajustar el padding del mainbox
if [ "$RES_L" -gt 0 ]; then
    PAD_L=$((80 + RES_L))
    ROFI_ARGS+=("-theme-str" "mainbox { padding: 40px 80px 30px ${PAD_L}px; }")
fi

exec rofi "${ROFI_ARGS[@]}" "$@"
