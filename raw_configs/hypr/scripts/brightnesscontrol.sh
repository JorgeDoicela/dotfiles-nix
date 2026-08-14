#!/usr/bin/env bash
# Script autónomo para controlar el brillo de pantalla en Hyprland (Debian)

step=${BRIGHTNESS_STEPS:-5}
step="${2:-$step}"
isNotify=true

print_usage() {
    cat <<EOF
Uso: $(basename "$0") <action> [step]
Acciones:
    i     Subir brillo
    d     Bajar brillo
    q     Modo silencioso (sin notificaciones)
EOF
    exit 1
}

get_brightness() {
    # Obtiene el porcentaje de brillo usando brightnessctl
    brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%'
}

notify_brightness() {
    [ "$isNotify" = "false" ] && return
    local val
    val=$(get_brightness)
    local icon="display-brightness"
    
    # Barra de progreso visual simple
    local bar
    bar=$(seq -s "■" $((val / 10)) 2>/dev/null | sed 's/[0-9]//g')
    
    notify-send -a "Brillo" -r 7 -t 1500 -i "$icon" "$val%  $bar"
}

case $1 in
    i)
        brightnessctl set +"$step"% >/dev/null 2>&1
        notify_brightness
        ;;
    d)
        brightnessctl set "$step"%- >/dev/null 2>&1
        notify_brightness
        ;;
    q)
        isNotify=false
        ;;
    *)
        print_usage
        ;;
esac
