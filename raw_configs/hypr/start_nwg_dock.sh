#!/usr/bin/env bash
# Script para gestionar el arranque del Dock de nwg-dock-hyprland de forma autónoma.
# Sin dependencias de servicios systemd inestables.

# Matar instancias previas
killall nwg-dock-hyprland 2>/dev/null
sleep 0.2

# Iniciar directamente en segundo plano y desacoplar del proceso padre
nwg-dock-hyprland -i 40 -d -mb 8 -nolauncher >/dev/null 2>&1 &
disown

echo "[Dock] nwg-dock-hyprland iniciado de forma autónoma."
