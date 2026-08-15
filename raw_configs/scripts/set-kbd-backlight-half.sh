#!/bin/sh
LOG="$HOME/.local/state/kbd-backlight.log"
mkdir -p "$(dirname "$LOG")"

log() {
    printf '%s %s\n' "$(date -Iseconds)" "$1" >> "$LOG"
}

for i in $(seq 1 30); do
    if out=$(brightnessctl --device='dell::kbd_backlight' set 1 2>&1); then
        log "OK intento=$i brillo=1 (50%) — $out"
        exit 0
    fi
    sleep 1
done

log "ERROR: no se pudo encender el teclado tras 30 intentos"
exit 1
