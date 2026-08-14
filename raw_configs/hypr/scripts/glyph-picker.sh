#!/usr/bin/env bash

# Selector de Glifos (Nerd Font Icons) autónomo usando Rofi y wl-copy

pkill -x rofi && exit 0

GLYPHS="  Arch Linux\n  Arch Logo\n  Neovim / Vim\n  Buscar / Lupa\n  Lanzador / Cohete\n  Carpeta / Folder\n  Ventana\n  Teclado\n  Luna / Noche\n  Sol / Día\n  Wifi / Red\n  Bluetooth\n  Batería llena\n  Batería vacía\n󰂄 Batería cargando\n🔊 Volumen alto\n🔇 Silencio\n  Micrófono\n  Mosaico / Tiling\n󰙔  Seguridad / Escudo\n  Telegram / Enviar\n  GitHub\n󰚌  IA / Cerebro\n  Editar / Lápiz\n  Ajustes / Engranaje\n󰈙  Documento\n󰋋  Auriculares\n󰎆  Música / Nota\n󰏘  Paleta / Pintar"

SELECTED=$(echo -e "$GLYPHS" | rofi -dmenu -p "🔎 Icono" -theme ~/.config/rofi/config.rasi)

if [ -n "$SELECTED" ]; then
    GLYPH_CHAR=$(echo "$SELECTED" | awk '{print $1}')
    echo -n "$GLYPH_CHAR" | wl-copy
    notify-send "Glifo" "Copiado al portapapeles: $GLYPH_CHAR" -i dialog-information
fi
