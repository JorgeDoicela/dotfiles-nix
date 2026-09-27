#!/usr/bin/env bash
# Telemetría y estado detallado de la batería para Waybar / Hyprland
set -euo pipefail

BAT_DEV=$(upower -e 2>/dev/null | grep -E 'BAT|battery' | head -n 1 || true)

if [ -z "$BAT_DEV" ]; then
    notify-send -a "Batería" -i battery "Estado de Energía" "No se detectó batería en el sistema (Alimentación AC fija)." -t 3000
    exit 0
fi

INFO=$(upower -i "$BAT_DEV")
PERCENT=$(echo "$INFO" | awk '/percentage:/{print $2}')
STATE=$(echo "$INFO" | awk '/state:/{print $2}')
TIME=$(echo "$INFO" | awk -F': *' '/time to (empty|full):/{print $2}')
CAPACITY=$(echo "$INFO" | awk '/capacity:/{print $2}')
RATE=$(echo "$INFO" | awk -F': *' '/energy-rate:/{print $2}')
MODEL=$(echo "$INFO" | awk -F': *' '/model:/{print $2}')

# Traducción de estados comunes
case "$STATE" in
    charging)        ESTADO_ES="Cargando" ; ICON="battery-charging" ;;
    discharging)     ESTADO_ES="Descargando" ; ICON="battery" ;;
    fully-charged)   ESTADO_ES="Carga completa" ; ICON="battery-full" ;;
    pending-charge)  ESTADO_ES="Conectado (En espera)" ; ICON="battery-charging" ;;
    *)               ESTADO_ES="$STATE" ; ICON="battery" ;;
esac

[ -z "$TIME" ] && TIME="Calculando tiempo..."
[ -z "$RATE" ] && RATE="N/A"
[ -z "$CAPACITY" ] && CAPACITY="100%"
[ -z "$MODEL" ] && MODEL="Batería interna"

DETALLE="• Nivel: $PERCENT ($ESTADO_ES)
• Tiempo: $TIME
• Consumo: $RATE
• Salud / Capacidad: $CAPACITY
• Modelo: $MODEL"

notify-send -a "Batería" -i "$ICON" "Telemetría de Batería" "$DETALLE" -t 4500 -h string:x-canonical-private-synchronous:battery-stat
