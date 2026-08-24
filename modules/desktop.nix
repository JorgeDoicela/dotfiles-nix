{ config, pkgs, ... }:

{
  # Paquetes declarativos del entorno de escritorio Hyprland
  home.packages = with pkgs; [
    waybar
    rofi
    swaynotificationcenter
    wlogout
    hypridle
    hyprlock
    nwg-dock-hyprland
    grim
    slurp
    swappy
    wl-clipboard
    cliphist
    brightnessctl
    playerctl
    pamixer
    pavucontrol
    libnotify
    gsimplecal
    networkmanagerapplet
    libinput-gestures
  ];

  # Servicio de usuario Systemd para garantizar que SwayNC siempre esté activo en DBus
  services.swaync = {
    enable = true;
  };

  # Enlaces declarativos comunes de Hyprland
  xdg.configFile."hypr/hyprland.conf".source = ../raw_configs/hypr/hyprland.conf;
  xdg.configFile."hypr/hypridle.conf".source = ../raw_configs/hypr/hypridle.conf;
  xdg.configFile."hypr/hyprlock.conf".source = ../raw_configs/hypr/hyprlock.conf;
  xdg.configFile."hypr/hyprpaper.conf".source = ../raw_configs/hypr/hyprpaper.conf;
  xdg.configFile."hypr/keybindings.conf".source = ../raw_configs/hypr/keybindings.conf;
  xdg.configFile."hypr/performance.conf".source = ../raw_configs/hypr/performance.conf;
  xdg.configFile."hypr/userprefs.conf".source = ../raw_configs/hypr/userprefs.conf;
  xdg.configFile."hypr/windowrules.conf".source = ../raw_configs/hypr/windowrules.conf;
  xdg.configFile."hypr/wallpaper.png".source = ../raw_configs/hypr/wallpaper.png;
  xdg.configFile."hypr/wallpaper_real.png".source = ../raw_configs/hypr/wallpaper_real.png;
  xdg.configFile."hypr/start_waybar.sh".source = ../raw_configs/hypr/start_waybar.sh;
  xdg.configFile."hypr/start_nwg_dock.sh".source = ../raw_configs/hypr/start_nwg_dock.sh;
  xdg.configFile."hypr/toggle_sunset.sh".source = ../raw_configs/hypr/toggle_sunset.sh;
  xdg.configFile."hypr/scripts".source = ../raw_configs/hypr/scripts;

  # Enlaces declarativos comunes de Waybar (Estilos parametrizados y perfiles auxiliares)
  xdg.configFile."waybar/style.css".text =
    builtins.replaceStrings [ "font-size: 13px;" ] [ "font-size: ${config.mySystem.waybarFontSize};" ]
      (builtins.readFile ../raw_configs/waybar/style.css);
  xdg.configFile."waybar/theme.css".source = ../raw_configs/waybar/theme.css;
  xdg.configFile."waybar/config_low.json".source = ../raw_configs/waybar/config_low.json;
  xdg.configFile."waybar/config_vertical.json".source = ../raw_configs/waybar/config_vertical.json;

  # Enlace declarativo de Rofi parametrizado por host
  xdg.configFile."rofi/theme.rasi".source = ../raw_configs/rofi/theme.rasi;
  xdg.configFile."rofi/config.rasi".text =
    builtins.replaceStrings
      [ "font:                       \"JetBrainsMono Nerd Font 10\";"
        "width:                       600px;"
        "height:                      350px;"
      ]
      [ "font:                       \"JetBrainsMono Nerd Font ${config.mySystem.rofiFontSize}\";"
        "width:                       ${config.mySystem.rofiWidth};"
        "height:                      ${config.mySystem.rofiHeight};"
      ]
      (builtins.readFile ../raw_configs/rofi/config.rasi);

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
