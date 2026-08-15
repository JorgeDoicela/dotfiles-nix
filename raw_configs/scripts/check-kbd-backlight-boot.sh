#!/bin/sh
LOG="$HOME/.local/state/kbd-backlight.log"
BRIGHT=$(cat /sys/class/leds/dell::kbd_backlight/brightness 2>/dev/null)
MAX=$(cat /sys/class/leds/dell::kbd_backlight/max_brightness 2>/dev/null)
SAVED=$(cat /var/lib/systemd/backlight/platform-dell-laptop:leds:dell::kbd_backlight 2>/dev/null)

echo "Brillo actual : $BRIGHT / $MAX"
echo "Estado systemd: $SAVED"
echo "Servicio      : $(systemctl --user is-active kbd-backlight.service 2>/dev/null)"
echo ""
echo "Últimas entradas del log:"
if [ -f "$LOG" ]; then
    tail -5 "$LOG"
else
    echo "(sin log aún — reinicia la laptop para generarlo)"
fi
echo ""
if [ "$BRIGHT" = "1" ]; then
    echo "RESULTADO: Teclado encendido al 50%"
    exit 0
else
    echo "RESULTADO: Teclado NO está al 50% (esperado: 1)"
    exit 1
fi
