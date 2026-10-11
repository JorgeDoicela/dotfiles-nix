{ config, pkgs, ... }:

{
  # Parámetros declarativos de escala de UI para jorge-secundaria (Pantalla 768p compacta)
  mySystem = {
    fontSize = 9;
    cursorSize = 20;
    waybarFontSize = "11px";
    rofiFontSize = "8.5";
    rofiWidth = "440px";
    rofiHeight = "270px";
    browserScale = "0.8";
    hyprActiveBorder = "rgba(ffffffb5)"; # Borde blanco atenuado (~71% alfa) para igualar el peso visual de 1080p
    hyprRounding = 10;                  # Redondeo adaptado proporcionalmente a 768p (10px vs 14px en 1080p)
    rofiLauncherPadding = "40px 80px 30px 308px"; # 80px base + 228px compensación franja rota eDP-1
    rofiLauncherColumns = 5;
    rofiLauncherLines = 3;
    rofiLauncherIconSize = "48px";
    rofiBooksPadding = "30px 60px 20px 288px"; # 60px base + 228px compensación franja rota eDP-1
    rofiBooksLines = 7;
  };

  # Configuración declarativa de hardware específica para jorge-secundaria (Dual Display)
  xdg.configFile."hypr/monitors.conf".source = ./monitors.conf;
  xdg.configFile."waybar/config.json".source = ./config.json;
}
