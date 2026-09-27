#!/usr/bin/env bash
# Script para iniciar Waybar de forma dinámica según la orientación y hardware disponible

# Matar cualquier instancia previa de forma limpia (soporta binarios nativos y Nix wrappers .waybar-wrapped)
pkill -x waybar 2>/dev/null || true
pkill -x ".waybar-wrapped" 2>/dev/null || true
while pgrep -x waybar >/dev/null 2>&1 || pgrep -x ".waybar-wrapped" >/dev/null 2>&1; do
    sleep 0.05
done

# Detectar orientación actual del monitor principal
TRANSFORM=$(hyprctl monitors -j 2>/dev/null | jq -r '.[0].transform // 0' 2>/dev/null || echo 0)

# Seleccionar archivo de configuración según orientación
if [ "$TRANSFORM" -eq 1 ] || [ "$TRANSFORM" -eq 3 ]; then
    CONFIG_FILE="$HOME/.config/waybar/config_vertical.json"
else
    # Archivo primario gestionado declarativamente por Home Manager para cada host
    CONFIG_FILE="$HOME/.config/waybar/config.json"
fi

# Iniciar Waybar de forma permanente
exec waybar -c "$CONFIG_FILE" -s "$HOME/.config/waybar/style.css"
