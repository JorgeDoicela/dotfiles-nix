{ config, pkgs, ... }:

{
  # Paquetes declarativos de aplicaciones de usuario
  home.packages = with pkgs; [
    alacritty
    neovim
    yazi
    sioyek
    fastfetch
    lsd
    rclone
    jq
    socat
    flameshot
  ];

  # Alacritty (Terminal declarativo con Tokyo Night parametrizado por host)
  programs.alacritty = {
    enable = true;
    settings = {
      general.live_config_reload = true;
      scrolling = {
        history = 10000;
        multiplier = 3;
      };
      window = {
        padding = {
          x = if config.mySystem.fontSize < 10 then 10 else 14;
          y = if config.mySystem.fontSize < 10 then 10 else 14;
        };
        dynamic_title = true;
        opacity = 0.82;
        blur = true;
      };
      font = {
        normal = { family = "JetBrainsMono Nerd Font Mono"; style = "Regular"; };
        bold   = { family = "JetBrainsMono Nerd Font Mono"; style = "Bold"; };
        italic = { family = "JetBrainsMono Nerd Font Mono"; style = "Italic"; };
        size   = config.mySystem.fontSize;
      };
      colors = {
        primary = {
          background = "#1a1b26";
          foreground = "#f5f5f7";
        };
        normal = {
          black   = "#2c2c2e";
          red     = "#ff453a";
          green   = "#30d158";
          yellow  = "#ff9f0a";
          blue    = "#ffffff";
          magenta = "#e5e5ea";
          cyan    = "#8e8e93";
          white   = "#e5e5ea";
        };
        bright = {
          black   = "#3a3a3c";
          red     = "#ff6961";
          green   = "#32d74b";
          yellow  = "#ffd60a";
          blue    = "#ffffff";
          magenta = "#ffffff";
          cyan    = "#ffffff";
          white   = "#ffffff";
        };
        selection = {
          background = "#ffffff";
          foreground = "#000000";
        };
        cursor = {
          cursor = "#ffffff";
          text   = "#000000";
        };
      };
      cursor = {
        style = { shape = "Beam"; blinking = "On"; };
        vi_mode_style = { shape = "Block"; };
      };
    };
  };

  # Flameshot (Capturas de pantalla)
  xdg.configFile."flameshot/flameshot.ini".source = ../raw_configs/flameshot/flameshot.ini;

  # VS Code (Settings y Keybindings)
  xdg.configFile."Code/User/settings.json".source = ../raw_configs/vscode/settings.json;
  xdg.configFile."Code/User/keybindings.json".source = ../raw_configs/vscode/keybindings.json;

  # LSD (Ls mejorado)
  xdg.configFile."lsd".source = ../raw_configs/lsd;

  # Fastfetch
  xdg.configFile."fastfetch".source = ../raw_configs/fastfetch;

  # Neovim (LazyVim / Lua Config)
  xdg.configFile."nvim".source = ../raw_configs/nvim;

  # Yazi (Navegador de archivos terminal)
  xdg.configFile."yazi".source = ../raw_configs/yazi;

  # Sioyek (Visor PDF de estudio)
  xdg.configFile."sioyek".source = ../raw_configs/sioyek;

  # Flags de Aceleración Gráfica y Wayland
  xdg.configFile."brave-flags.conf".source = ../raw_configs/brave-flags.conf;
  xdg.configFile."electron-flags.conf".source = ../raw_configs/electron-flags.conf;
  xdg.configFile."code-flags.conf".source = ../raw_configs/code-flags.conf;

  # Asociaciones de archivos por defecto
  xdg.configFile."mimeapps.list".source = ../raw_configs/mimeapps.list;
}
