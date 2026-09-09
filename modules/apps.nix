{ config, pkgs, ... }:

{
  # Paquetes declarativos de aplicaciones de usuario
  home.packages = with pkgs; [
    neovim
    yazi
    fastfetch
    lsd
    rclone
    jq
    socat
    flameshot

    # Entorno de desarrollo JavaScript / TypeScript declarativo
    nodejs_22
    pnpm
  ];

  # Alacritty (Terminal declarativo tipado nativo de Home Manager)
  programs.alacritty = {
    enable = true;
    package = null; # Delega al binario nativo de Debian para compatibilidad con Mesa/EGL en Wayland
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

  # Flags de Aceleración Gráfica, Wayland y Escala parametrizada por host
  xdg.configFile."brave-flags.conf".text =
    (builtins.readFile ../raw_configs/brave-flags.conf)
    + (if config.mySystem.browserScale != "1" then "\n--force-device-scale-factor=${config.mySystem.browserScale}\n" else "");
  xdg.configFile."brave-browser-flags.conf".text = config.xdg.configFile."brave-flags.conf".text;
  xdg.configFile."chromium-flags.conf".text = config.xdg.configFile."brave-flags.conf".text;
  xdg.configFile."electron-flags.conf".source = ../raw_configs/electron-flags.conf;

  # Asociaciones de archivos por defecto
  xdg.configFile."mimeapps.list".source = ../raw_configs/mimeapps.list;
}
