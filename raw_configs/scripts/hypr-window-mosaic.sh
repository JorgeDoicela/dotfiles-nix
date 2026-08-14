#!/usr/bin/env bash
# Coloca la ventana activa en posiciones tipo mosaico (mitades, esquinas, centro).
set -euo pipefail

pos="${1:-center}"

read -r MX MY MW MH < <(
	hyprctl monitors -j | jq -r '.[0] | "\(.x) \(.y) \(.width) \(.height)"'
)

G=10

case "$pos" in
left)
	X=$((MX + G))
	Y=$((MY + G))
	W=$(((MW - G * 3) / 2))
	H=$((MH - G * 2))
	;;
right)
	X=$((MX + (MW + G) / 2))
	Y=$((MY + G))
	W=$(((MW - G * 3) / 2))
	H=$((MH - G * 2))
	;;
top)
	X=$((MX + G))
	Y=$((MY + G))
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
	X=$((MX + MW * 2 / 3))
	Y=$((MY + MH * 2 / 3))
	W=$((MW / 3 - G))
	H=$((MH / 3 - G))
	;;
center)
	X=$((MX + MW / 4))
	Y=$((MY + MH / 4))
	W=$((MW / 2))
	H=$((MH / 2))
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

hyprctl dispatch resizewindow "exact $W $H"
hyprctl dispatch movewindow "exact $X $Y"
