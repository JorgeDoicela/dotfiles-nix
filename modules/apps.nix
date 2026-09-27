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

    # Entorno de desarrollo JavaScript / TypeScript declarativo
    nodejs_22
    pnpm

    # Herramientas de productividad académica y comunicación
    libreoffice
    zoom-us
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
          background = "#1c1c1e";
          foreground = "#f5f5f7";
        };
        normal = {
          black   = "#2c2c2e";
          red     = "#ff453a";
          green   = "#30d158";
          yellow  = "#ff9f0a";
          blue    = "#0a84ff";
          magenta = "#bf5af2";
          cyan    = "#64d2ff";
          white   = "#e5e5ea";
        };
        bright = {
          black   = "#3a3a3c";
          red     = "#ff6961";
          green   = "#32d74b";
          yellow  = "#ffd60a";
          blue    = "#409cff";
          magenta = "#da8fff";
          cyan    = "#70d7ff";
          white   = "#ffffff";
        };
        selection = {
          background = "#0a84ff";
          foreground = "#ffffff";
        };
        cursor = {
          cursor = "#0a84ff";
          text   = "#ffffff";
        };
      };
      cursor = {
        style = { shape = "Beam"; blinking = "On"; };
        vi_mode_style = { shape = "Block"; };
      };
    };
  };


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

  # Definicion declarativa de targets para el gestor sincro
  xdg.configFile."rclone/sincro-targets.conf".source = ../raw_configs/rclone/sincro-targets.conf;

  # Reglas declarativas de exclusion de conflictos para sincro (Obsidian / Windows / Android)
  xdg.configFile."rclone/sincro-filters.txt".source = ../raw_configs/rclone/sincro-filters.txt;

  # Servicio de usuario Systemd para montaje FUSE de Google Drive bajo demanda (~/Drive)
  systemd.user.services.rclone-gdrive = {
    Unit = {
      Description = "Montaje virtual de Google Drive con Rclone (FUSE)";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "simple";
      ExecCondition = "${pkgs.bash}/bin/bash -c '${pkgs.rclone}/bin/rclone listremotes 2>/dev/null | grep -q \"^gdrive:\"'";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Drive";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount gdrive: %h/Drive \
          --vfs-cache-mode full \
          --vfs-cache-max-size 15G \
          --vfs-cache-max-age 72h \
          --dir-cache-time 1h \
          --vfs-read-chunk-size 32M \
          --vfs-read-chunk-size-limit 2G \
          --buffer-size 32M \
          --umask 022
      '';
      ExecStop = "/usr/bin/fusermount3 -u -z %h/Drive";
      Restart = "on-failure";
      RestartSec = "10s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Ocultar declarativamente las entradas de escritorio de LibreOffice en lanzadores de aplicaciones (Rofi)
  # Se utiliza xdg.dataFile para colocar las anulaciones con NoDisplay=true directamente en ~/.local/share/applications/
  # evitando colisiones en el buildEnv de Nix store y respetando la precedencia de la especificacion XDG.
  xdg.dataFile =
    let
      hiddenOfficeEntries = [
        "base"
        "calc"
        "draw"
        "impress"
        "math"
        "startcenter"
        "writer"
        "xsltfilter"
        "libreoffice-base"
        "libreoffice-calc"
        "libreoffice-draw"
        "libreoffice-impress"
        "libreoffice-math"
        "libreoffice-startcenter"
        "libreoffice-writer"
        "libreoffice-xsltfilter"
      ];
    in
    builtins.listToAttrs (map (entryName: {
      name = "applications/${entryName}.desktop";
      value = {
        text = ''
          [Desktop Entry]
          Type=Application
          Name=LibreOffice ${entryName}
          NoDisplay=true
        '';
      };
    }) hiddenOfficeEntries);
}

