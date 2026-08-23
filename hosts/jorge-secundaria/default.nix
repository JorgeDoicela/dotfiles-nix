{ config, pkgs, ... }:

{
  # Parámetros declarativos de escala de UI para jorge-secundaria (Pantalla 768p compacta)
  mySystem = {
    fontSize = 9;
    cursorSize = 20;
    waybarFontSize = "11px";
    vscodeZoomLevel = -0.6;
    rofiFontSize = "8.5";
    rofiWidth = "440px";
    rofiHeight = "270px";
    browserScale = "0.85";
  };

  # Configuración declarativa de hardware específica para jorge-secundaria (Dual Display)
  xdg.configFile."hypr/monitors.conf".source = ./monitors.conf;
  xdg.configFile."waybar/config.json".source = ./config.json;
}
