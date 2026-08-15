{ config, pkgs, ... }:

{
  # Configuración declarativa de Git (sintaxis actualizada de Home Manager)
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "JorgeDoicela";
        email = "ismael02doicela@gmail.com";
      };
    };
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
    };
  };
}
