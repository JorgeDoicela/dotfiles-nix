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

  # Alacritty (Terminal declarativo parametrizado por host)
  xdg.configFile."alacritty/alacritty.toml".text =
    builtins.replaceStrings [ "size = 11.0" "padding = { x = 14, y = 14 }" ]
      [ "size = ${toString config.mySystem.fontSize}.0" "padding = { x = 10, y = 10 }" ]
      (builtins.readFile ../raw_configs/alacritty/alacritty.toml);

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
