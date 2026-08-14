#!/usr/bin/env bash
# Script para gestionar el arranque del Dock de nwg-dock-hyprland de forma autónoma.

# Matar instancias previas
killall nwg-dock-hyprland 2>/dev/null
sleep 0.2

# Iniciar el Dock oficial de Hyprland
nwg-dock-hyprland -i 48 -d -mb 6 -nolauncher >/dev/null 2>&1 &
disown

echo "[Dock] nwg-dock-hyprland iniciado de forma autónoma."
