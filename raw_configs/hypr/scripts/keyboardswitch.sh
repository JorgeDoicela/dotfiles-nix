#!/usr/bin/env bash
# Script autónomo para cambiar la distribución de teclado en Hyprland.

# Cambiar al siguiente layout
hyprctl switchxkblayout all next

# Obtener distribución activa usando jq de forma robusta
layMain=$(hyprctl -j devices | jq -r '.keyboards[] | select(.main == true) | .active_keymap' 2>/dev/null)

# En caso de que jq no encuentre el principal, obtener el primero de la lista
if [ -z "$layMain" ] || [ "$layMain" = "null" ]; then
    layMain=$(hyprctl -j devices | jq -r '.keyboards[0].active_keymap' 2>/dev/null)
fi

# Enviar notificación simple
notify-send -a "Sistema" -r 91190 -t 800 -i input-keyboard "Distribución de Teclado" "$layMain"
