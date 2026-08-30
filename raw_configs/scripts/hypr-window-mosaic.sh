#!/usr/bin/env bash
# Coloca la ventana activa en posiciones tipo mosaico (mitades, esquinas, centro).
set -euo pipefail

pos="${1:-center}"

# Obtener dimensiones del monitor actualmente enfocado
read -r MX MY MW MH < <(
	hyprctl monitors -j | jq -r '(.[] | select(.focused == true) // .[0]) | "\(.x) \(.y) \(.width) \(.height)"'
)

G=16

case "$pos" in
left)
	X=$((MX + G))
	Y=$((MY + G + 36))
	W=$(((MW - G * 3) / 2))
	H=$((MH - G * 2 - 40))
	;;
right)
	X=$((MX + (MW + G) / 2))
	Y=$((MY + G + 36))
	W=$(((MW - G * 3) / 2))
	H=$((MH - G * 2 - 40))
	;;
top)
	X=$((MX + G))
	Y=$((MY + G + 36))
	W=$((MW - G * 2))
	H=$(((MH - G * 3) / 2))
	;;
bottom)
	X=$((MX + G))
	Y=$((MY + (MH + G) / 2))
	W=$((MW - G * 2))
	H=$(((MH - G * 3) / 2))
	;;
br)
	# Esquinita inferior derecha (Picture in Picture)
	W=$((MW * 35 / 100))
	H=$((MH * 35 / 100))
	X=$((MX + MW - W - G))
	Y=$((MY + MH - H - G))
	;;
center)
	# Centro de la pantalla (60% x 60%)
	W=$((MW * 60 / 100))
	H=$((MH * 60 / 100))
	X=$((MX + (MW - W) / 2))
	Y=$((MY + (MH - H) / 2))
	;;
tile)
	hyprctl dispatch togglefloating
	exit 0
	;;
*)
	echo "Uso: $0 {left|right|top|bottom|br|center|tile}" >&2
	exit 1
	;;
esac

floating="$(hyprctl activewindow -j | jq -r '.floating')"
if [[ "$floating" != "true" ]]; then
	hyprctl dispatch togglefloating
fi

# Aplicar redimensionado y movimiento exacto con los dispatchers nativos de Hyprland
hyprctl dispatch resizeactive exact "$W" "$H"
hyprctl dispatch moveactive exact "$X" "$Y"
