#!/usr/bin/env bash
export YDOTOOL_SOCKET="${YDOTOOL_SOCKET:-$HOME/.ydotool_socket}"
SOCK="$HOME/.config/voxd/voxd.sock"
STATE="${XDG_CACHE_HOME:-$HOME/.cache}/voxd-recording"

if [[ -f "$STATE" ]]; then
  rm -f "$STATE"
  notify-send -a VOXD "VOXD" "Transcribiendo y liberando RAM..." -t 2000
  
  # Trigger 2: detener grabación, transcribir y escribir texto
  voxd --trigger-record
  
  # En segundo plano, esperar 4 segundos a que termine de escribir y apagar voxd-daemon para liberar la RAM
  (
    sleep 4
    systemctl --user stop voxd-daemon
  ) &
fi
