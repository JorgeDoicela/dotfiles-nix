{ config, pkgs, ... }:

{
  home.username = "jorge";
  home.homeDirectory = "/home/jorge";
  home.stateVersion = "24.05";

  # Habilitar la gestión propia de Home Manager
  programs.home-manager.enable = true;

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
  ];
}
