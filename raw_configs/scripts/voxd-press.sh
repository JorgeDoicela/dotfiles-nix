#!/usr/bin/env bash
export YDOTOOL_SOCKET="${YDOTOOL_SOCKET:-$HOME/.ydotool_socket}"
SOCK="$HOME/.config/voxd/voxd.sock"
STATE="${XDG_CACHE_HOME:-$HOME/.cache}/voxd-recording"

# Cancelar cualquier apagado programado si se presiona de nuevo
pkill -f "sleep 4.*systemctl.*stop voxd-daemon" 2>/dev/null || true

# Asegurar que el demonio y el socket existan
if ! systemctl --user is-active --quiet voxd-daemon || [[ ! -S "$SOCK" ]]; then
  notify-send -a VOXD "VOXD" "Cargando Whisper en RAM..." -t 1500
  systemctl --user start voxd-daemon ydotoold
  for i in {1..40}; do
    [[ -S "$SOCK" ]] && break
    sleep 0.1
  done
fi

# Iniciar grabación (Trigger 1)
if [[ ! -f "$STATE" ]]; then
  : > "$STATE"
  notify-send -a VOXD "VOXD" "Grabando (suelta para enviar)..." -t 3000
  voxd --trigger-record
fi
