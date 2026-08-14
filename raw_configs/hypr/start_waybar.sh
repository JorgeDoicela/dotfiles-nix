#!/usr/bin/env bash
# Script para iniciar Waybar de forma dinámica según el hardware disponible

# Matar instancias previas
killall waybar 2>/dev/null

# Pequeño delay de estabilización
sleep 0.2

# Detectar memoria RAM en MB
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')

# Configurar el enlace simbólico dinámico al archivo JSON correcto
if [ "$TOTAL_RAM" -lt 5000 ]; then
    echo "[Waybar] Perfil de bajo rendimiento (low)"
    ln -sf "$HOME/.config/waybar/config_low.json" "$HOME/.config/waybar/config"
else
    echo "[Waybar] Perfil estándar (high)"
    ln -sf "$HOME/.config/waybar/config.json" "$HOME/.config/waybar/config"
fi

# Iniciar Waybar directamente y desacoplar el proceso
waybar -c "$HOME/.config/waybar/config" -s "$HOME/.config/waybar/style.css" >/dev/null 2>&1 &
disown


