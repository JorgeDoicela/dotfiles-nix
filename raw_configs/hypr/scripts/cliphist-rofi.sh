#!/usr/bin/env bash

# Script local simple y rápido de portapapeles con cliphist y rofi

# 1. Comprobar si se solicita limpiar el portapapeles
if [ "$1" = "-c" ]; then
    cliphist wipe
    notify-send "Portapapeles" "Historial de portapapeles limpiado" -i dialog-information
    exit 0
fi

# 2. Mostrar menú de selección
SELECTION=$(cliphist list | rofi -dmenu -p "📋 " -theme ~/.config/rofi/config.rasi)

# 3. Decodificar y copiar la selección si no está vacía
if [ -n "$SELECTION" ]; then
    echo "$SELECTION" | cliphist decode | wl-copy
fi
