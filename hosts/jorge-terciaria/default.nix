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
    cursorSensitivity = "0.35"; # Ligero incremento de respuesta (+0.10) para un movimiento sutilmente más ágil
    scrollFactor = "0.27";      # Punto medio fino calibrado para el touchpad
  };

  # Configuración declarativa de hardware específica para jorge-terciaria
  xdg.configFile."hypr/monitors.conf".source = ./monitors.conf;
  xdg.configFile."waybar/config.json".source = ./config.json;
}

