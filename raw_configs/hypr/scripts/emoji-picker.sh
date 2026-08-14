#!/usr/bin/env bash

# Selector de Emojis autónomo usando Rofi y wl-copy

pkill -x rofi && exit 0

EMOJIS="😀 Sonrisa\n😂 Risa con llanto\n😊 Sonrisa feliz\n🔥 Fuego\n🚀 Cohete\n👍 Me gusta\n🎉 Fiesta\n🤔 Pensando\n⚠️ Advertencia\n💡 Idea\n✨ Brillos\n💻 Programación / PC\n🔒 Seguridad / Candado\n❤️ Corazón\n👀 Ojos\n🌟 Estrella\n📦 Paquete\n⚙️ Ajustes\n🛠️ Herramientas\n💬 Mensaje\n📅 Calendario\n📈 Gráfico\n🎨 Arte / Diseño\n✍️ Escribir\n⚡ Rayo / Rápido\n☕ Café\n🍕 Pizza\n🌍 Mundo\n🔍 Buscar"

SELECTED=$(echo -e "$EMOJIS" | rofi -dmenu -p "🔎 Emoji" -theme ~/.config/rofi/config.rasi)

if [ -n "$SELECTED" ]; then
    EMOJI_CHAR=$(echo "$SELECTED" | awk '{print $1}')
    echo -n "$EMOJI_CHAR" | wl-copy
    notify-send "Emoji" "Copiado al portapapeles: $EMOJI_CHAR" -i dialog-information
fi
