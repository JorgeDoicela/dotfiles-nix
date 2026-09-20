#!/usr/bin/env bash
# ==============================================================================
# ALTERNAR FILTRO DE LUZ AZUL NATIVO (WLSUNSET VIA SYSTEMD)
# ==============================================================================
set -euo pipefail

# Si el servicio wlsunset o el proceso están activos, detenerlo
if systemctl --user is-active --quiet wlsunset.service 2>/dev/null || pgrep -f "wlsunset" >/dev/null 2>&1; then
    systemctl --user stop wlsunset.service 2>/dev/null || true
    pkill -f "wlsunset" 2>/dev/null || true
    notify-send -a "Filtro de Luz" -i "display-brightness-symbolic" \
        "Filtro de luz azul desactivado" "Modo normal diurno (6500K)"
else
    # Si no está activo, intentar arrancarlo vía systemd
    if systemctl --user start wlsunset.service 2>/dev/null; then
        notify-send -a "Filtro de Luz" -i "night-light-symbolic" \
            "Filtro de luz azul activado" "Modo cálido nocturno (3500K)"
    else
        # Fallback de ejecución directa por si el servicio aún no se ha recargado
        pkill -f "wlsunset" 2>/dev/null || true
        nohup wlsunset -t 3500 -T 3500 -g 0.9 >/dev/null 2>&1 &
        notify-send -a "Filtro de Luz" -i "night-light-symbolic" \
            "Filtro de luz azul forzado" "Modo cálido activo (3500K)"
    fi
fi
