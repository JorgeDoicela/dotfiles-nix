{ config, pkgs, ... }:

{
  # Orquestador nativo de capturas de pantalla (Wayland / Hyprland)
  home.file.".local/bin/screenshot" = {
    source = ../raw_configs/hypr/scripts/screenshot.sh;
    executable = true;
  };

  home.file.".local/bin/lockscreen-splash.sh" = {
    source = ../raw_configs/scripts/lockscreen-splash.sh;
    executable = true;
  };

  home.file.".local/bin/hypr-window-mosaic.sh" = {
    source = ../raw_configs/scripts/hypr-window-mosaic.sh;
    executable = true;
  };

  home.file.".local/bin/sincro" = {
    source = ../raw_configs/scripts/sincro;
    executable = true;
  };

  home.file.".local/bin/selector-libros.sh" = {
    source = ../raw_configs/scripts/selector-libros.sh;
    executable = true;
  };

  home.file.".local/bin/check-kbd-backlight-boot.sh" = {
    source = ../raw_configs/scripts/check-kbd-backlight-boot.sh;
    executable = true;
  };

  home.file.".local/bin/set-kbd-backlight-half.sh" = {
    source = ../raw_configs/scripts/set-kbd-backlight-half.sh;
    executable = true;
  };

  home.file.".local/bin/setup-voxd.sh" = {
    source = ../raw_configs/scripts/setup-voxd.sh;
    executable = true;
  };

  home.file.".local/bin/voxd-daemon.py" = {
    source = ../raw_configs/scripts/voxd-daemon.py;
    executable = true;
  };

  home.file.".local/bin/voxd-press.sh" = {
    source = ../raw_configs/scripts/voxd-press.sh;
    executable = true;
  };

  home.file.".local/bin/voxd-release.sh" = {
    source = ../raw_configs/scripts/voxd-release.sh;
    executable = true;
  };

  home.file.".local/bin/voxd-toggle" = {
    source = ../raw_configs/scripts/voxd-toggle;
    executable = true;
  };

  home.file.".local/bin/whisper-fast-jorge" = {
    source = ../raw_configs/scripts/whisper-fast-jorge;
    executable = true;
  };

  home.file.".local/bin/hypr-rotate" = {
    source = ../raw_configs/scripts/hypr-rotate;
    executable = true;
  };

  # Control de energía y rendimiento GPU AMD (declarativo para atajos de teclado)
  home.file.".local/bin/gpu-performance" = {
    source = ../setup/amdgpu/amdgpu-performance;
    executable = true;
  };

  home.file.".local/bin/gpu-powersave" = {
    source = ../setup/amdgpu/amdgpu-powersave;
    executable = true;
  };

  # Wrapper universal para Brave en Linux (lee automáticamente ~/.config/brave-flags.conf)
  home.file.".local/bin/brave-browser" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      FLAGS=()
      if [ -f "$HOME/.config/brave-flags.conf" ]; then
          while IFS= read -r line || [ -n "$line" ]; do
              [[ "$line" =~ ^[[:space:]]*# ]] && continue
              [[ -z "$line" ]] && continue
              FLAGS+=("$line")
          done < "$HOME/.config/brave-flags.conf"
      fi
      exec /usr/bin/brave-browser-stable "''${FLAGS[@]}" "$@"
    '';
  };

  # Wrapper declarativo para Zoom nativo de Debian
  # 1. Aplica patron Raise or Launch en Hyprland si ya existe ventana activa sin argumentos.
  # 2. Si se pasa un argumento de reunion (zoommtg://) o no existe ventana, despacha a Zoom.
  # 3. Purga variables de tema Qt del sistema para prevenir pantallas negras con el Qt 6 empaquetado.
  home.file.".local/bin/zoom" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      if [ "$#" -eq 0 ] && command -v hyprctl >/dev/null 2>&1 && hyprctl clients -j 2>/dev/null | ${pkgs.jq}/bin/jq -e '.[] | select(.class == "zoom")' >/dev/null 2>&1; then
          hyprctl dispatch focuswindow class:^zoom$ >/dev/null 2>&1
          exit 0
      fi

      exec env -u QT_STYLE_OVERRIDE -u QT_QPA_PLATFORMTHEME -u QT_PLUGIN_PATH /usr/bin/zoom "$@"
    '';
  };

  # Wrapper declarativo para ZapZap (WhatsApp) desplegado vía Flatpak
  home.file.".local/bin/zapzap" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      exec /usr/bin/flatpak run com.rtosta.zapzap "$@"
    '';
  };
}
