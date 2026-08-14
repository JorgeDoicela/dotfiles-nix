{ config, pkgs, ... }:

{
  home.username = "jorge";
  home.homeDirectory = "/home/jorge";
  home.stateVersion = "24.05";

  # Habilitar la gestión propia de Home Manager
  programs.home-manager.enable = true;

  # Variables de entorno globales del sistema de usuario (Wayland / Qt / Electron)
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  # Importar módulos modulares de configuración
  imports = [
    ./modules/style.nix
    ./modules/desktop.nix
    ./modules/apps.nix
    ./modules/shell.nix
    ./modules/scripts.nix
  ];

  # Paquetes útiles de sistema instalados de forma declarativa mediante Nix
  home.packages = with pkgs; [
    catppuccin-gtk
    tela-circle-icon-theme
    bibata-cursors
    font-awesome
    nerd-fonts.jetbrains-mono
    nixfmt # Formateador oficial de código Nix
  ];
}
