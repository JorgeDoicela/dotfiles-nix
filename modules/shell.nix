{ config, pkgs, ... }:

{
  # Configuración declarativa de Git endurecida (firma SSH, rebase, histogram diff, rerere)
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "JorgeDoicela";
        email = "ismael02doicela@gmail.com";
        signingkey = "~/.ssh/id_ed25519_github.pub";
      };
      gpg = {
        format = "ssh";
      };
      commit = {
        gpgsign = true;
      };
      tag = {
        gpgsign = true;
      };
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = true;
      };
      fetch = {
        prune = true;
      };
      rerere = {
        enabled = true;
      };
      diff = {
        algorithm = "histogram";
      };
      core = {
        autocrlf = "input";
      };
    };
  };

  # Pager moderno para diffs de Git con resaltado de sintaxis
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      dark = true;
      line-numbers = true;
      side-by-side = false;
    };
  };

  # GitHub CLI declarativo
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };

  # Navegación inteligente de directorios (zoxide)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  # Visor de archivos con resaltado de sintaxis e integración Git (bat)
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      style = "numbers,changes,header";
    };
  };

  # Carga automática de entornos de proyecto por directorio (direnv + nix-direnv)
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  # Multiplexor de sesiones Tmux declarativo (paleta monocromática coherente con Alacritty)
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 10000;
    keyMode = "vi";
    terminal = "tmux-256color";
    extraConfig = ''
      set -ag terminal-overrides ",alacritty:RGB"
      set -g renumber-windows on
      set -g status-position top

      # División intuitiva de paneles manteniendo el directorio actual
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Navegación de paneles estilo Vim
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Estética monocromática oscura (coherente con Alacritty / Waybar)
      set -g status-style "bg=#1c1c1e,fg=#f5f5f7"
      set -g status-left "#[bg=#ffffff,fg=#000000,bold] #S #[default] "
      set -g status-right "#[fg=#8e8e93]%H:%M "
      set -g window-status-current-style "bg=#2c2c2e,fg=#ffffff,bold"
      set -g window-status-format " #I:#W "
      set -g window-status-current-format " #I:#W "
      set -g pane-border-style "fg=#2c2c2e"
      set -g pane-active-border-style "fg=#ffffff"
    '';
  };

  # Configuración declarativa de Xresources
  xresources.properties = {
    "Xcursor.theme" = "Bibata-Modern-Ice";
    "Xcursor.size" = 24;
  };

  # Starship Prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
  xdg.configFile."starship.toml".source = ../raw_configs/starship/starship.toml;

  # FZF con paleta Monocromática Blanco / Gris Espacial declarativa
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    defaultOptions = [
      "--height 45%"
      "--layout=reverse"
      "--border"
      "--color=fg:#f5f5f7,bg:#0d0d0f,hl:#ffffff"
      "--color=fg+:#ffffff,bg+:#2c2c2e,hl+:#ffffff"
      "--color=info:#8e8e93,prompt:#ffffff,pointer:#ffffff"
      "--color=marker:#ffffff,spinner:#ffffff,header:#8e8e93"
    ];
  };

  # Integración de Zsh
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      sincro = "sincro";
      drive = "cd ~/Drive";
      gdrive = "cd ~/Drive";
      ls = "lsd";
      ll = "lsd -l";
      la = "lsd -a";
      lla = "lsd -la";
      lt = "lsd --tree";
      cat = "bat";
      lg = "lazygit";
      ld = "lazydocker";
      Hyprland = "start-hyprland";
      hyprland = "start-hyprland";
    };
    initContent = ''
      # Función wrapper de Yazi para cambiar de directorio al salir
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }
    '';
  };
}
