#!/usr/bin/env bash
# Script para gestionar el arranque del Dock de nwg-dock-hyprland de forma autónoma.
# Usa setsid para crear una sesión de proceso completamente independiente del shell padre.

# Matar instancias previas
killall nwg-dock-hyprland 2>/dev/null
sleep 0.2

# Iniciar en una sesión de proceso propia, desacoplado de cualquier terminal
setsid nwg-dock-hyprland -i 48 -d -mb 6 -nolauncher >/dev/null 2>&1 &

echo "[Dock] nwg-dock-hyprland iniciado de forma autónoma."
