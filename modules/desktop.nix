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

  # Enlace declarativo de Rofi
  xdg.configFile."rofi".source = ../raw_configs/rofi;

  # Enlace declarativo de nwg-dock-hyprland
  xdg.configFile."nwg-dock-hyprland".source = ../raw_configs/nwg-dock-hyprland;

  # Enlace declarativo de SwayNC
  xdg.configFile."swaync".source = ../raw_configs/swaync;

  # Enlace declarativo de gsimplecal
  xdg.configFile."gsimplecal".source = ../raw_configs/gsimplecal;

  # Enlace declarativo de wlogout
  xdg.configFile."wlogout".source = ../raw_configs/wlogout;

  # Enlace declarativo de libinput-gestures
  xdg.configFile."libinput-gestures.conf".source = ../raw_configs/libinput-gestures.conf;

  # Enlace declarativo de portales XDG
  xdg.configFile."xdg-desktop-portal/portals.conf".source = ../raw_configs/xdg-desktop-portal/portals.conf;
}
