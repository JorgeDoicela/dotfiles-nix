{ config, pkgs, ... }:

{
  # Configuración declarativa de hardware específica para jorge-secundaria (Dual Display)
  xdg.configFile."hypr/monitors.conf".source = ./monitors.conf;
  xdg.configFile."waybar/config.json".source = ./config.json;
}
