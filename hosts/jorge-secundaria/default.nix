{ config, pkgs, ... }:

{
  # Parámetros declarativos de escala de UI para jorge-secundaria
  mySystem = {
    fontSize = 9;
    waybarFontSize = "11.5px";
  };

  # Configuración declarativa de hardware específica para jorge-secundaria (Dual Display)
  xdg.configFile."hypr/monitors.conf".source = ./monitors.conf;
  xdg.configFile."waybar/config.json".source = ./config.json;
}
