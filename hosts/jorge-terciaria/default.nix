{ config, pkgs, ... }:

{
  # Parámetros declarativos de escala de UI para jorge-terciaria (Pantalla 1080p estándar)
  mySystem = {
    fontSize = 11;
    cursorSize = 24;
    waybarFontSize = "13px";
    rofiFontSize = "10";
    rofiWidth = "600px";
    rofiHeight = "350px";
    browserScale = "1";
  };

  # Configuración declarativa de hardware específica para jorge-terciaria
  xdg.configFile."hypr/monitors.conf".source = ./monitors.conf;
  xdg.configFile."waybar/config.json".source = ./config.json;
}

