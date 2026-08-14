#!/usr/bin/env bash
# Script independiente para lanzar wlogout (Debian/Hyprland)

if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

# Parámetros y valores por defecto
[ -n "$1" ] && wlogoutStyle="$1"
wlogoutStyle=${wlogoutStyle:-1}
confDir="$HOME/.config"
wLayout="$confDir/wlogout/layout_$wlogoutStyle"
wlTmplt="$confDir/wlogout/style_$wlogoutStyle.css"

if [ ! -f "$wLayout" ] || [ ! -f "$wlTmplt" ]; then
    wlogoutStyle=1
    wLayout="$confDir/wlogout/layout_$wlogoutStyle"
    wlTmplt="$confDir/wlogout/style_$wlogoutStyle.css"
fi

# Obtener dimensiones del monitor enfocado para escalar wlogout
x_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width' 2>/dev/null || echo 1920)
y_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height' 2>/dev/null || echo 1080)
hypr_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//' 2>/dev/null || echo 100)
[ -z "$hypr_scale" ] && hypr_scale=100

case "$wlogoutStyle" in
    1)
        wlColms=6
        export mgn=$((y_mon * 28 / hypr_scale))
        export hvr=$((y_mon * 23 / hypr_scale))
        ;;
    2)
        wlColms=2
        export x_mgn=$((x_mon * 35 / hypr_scale))
        export y_mgn=$((y_mon * 25 / hypr_scale))
        export x_hvr=$((x_mon * 32 / hypr_scale))
        export y_hvr=$((y_mon * 20 / hypr_scale))
        ;;
esac

export fntSize=$((y_mon * 2 / 100))
export BtnCol="white" # Color predeterminado para los botones/iconos

# Borde por defecto para redondear botones
hypr_border=10
export active_rad=$((hypr_border * 5))
export button_rad=$((hypr_border * 8))

# Generar archivo CSS temporal usando envsubst
wlStyle="$(envsubst < "$wlTmplt")"

# Lanzar wlogout
wlogout -b "$wlColms" -c 0 -r 0 -m 0 --layout "$wLayout" --css <(echo "$wlStyle") --protocol layer-shell

