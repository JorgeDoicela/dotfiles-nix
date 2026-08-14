{ config, pkgs, ... }:

{
  # Servicio de usuario Systemd para garantizar que SwayNC siempre esté activo en DBus
  services.swaync = {
    enable = true;
  };

  # Enlace declarativo de configuraciones de Hyprland
  xdg.configFile."hypr".source = ../raw_configs/hypr;

  # Enlace declarativo de Waybar
  xdg.configFile."waybar".source = ../raw_configs/waybar;

  # Enlace declarativo de Rofi (con el tema estático de Catppuccin Mocha)
  xdg.configFile."rofi".source = ../raw_configs/rofi;

  # Enlace declarativo de SwayNC
  xdg.configFile."swaync".source = ../raw_configs/swaync;
}
