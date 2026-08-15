#!/usr/bin/env bash
# Script para iniciar Waybar de forma dinámica según el hardware disponible

# Matar cualquier instancia previa para garantizar exactamente 1 única barra
killall -9 waybar 2>/dev/null
sleep 0.2

# Detectar memoria RAM en MB
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')

# Seleccionar archivo de configuración según RAM
if [ "$TOTAL_RAM" -lt 5000 ]; then
    echo "[Waybar] Perfil de bajo rendimiento (low)"
    CONFIG_FILE="$HOME/.config/waybar/config_low.json"
else
    echo "[Waybar] Perfil estándar (high)"
    CONFIG_FILE="$HOME/.config/waybar/config.json"
fi

# Iniciar Waybar desacoplado por completo de la sesión de terminal
nohup waybar -c "$CONFIG_FILE" -s "$HOME/.config/waybar/style.css" >/dev/null 2>&1 &


