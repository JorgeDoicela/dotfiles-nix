{ config, pkgs, ... }:

{
  # Configuración declarativa de Git
  programs.git = {
    enable = true;
    userName = "JorgeDoicela";
    userEmail = "ismael02doicela@gmail.com";
  };

  # Configuración declarativa de Xresources (para X11/XWayland cursores)
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
  xdg.configFile."starship/starship.toml".source = ../raw_configs/starship/starship.toml;

  # FZF con paleta Tokyo Night declarativa
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    defaultOptions = [
      "--height 45%"
      "--layout=reverse"
      "--border"
      "--color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7"
      "--color=fg+:#c0caf5,bg+:#2e3c64,hl+:#7dcfff"
      "--color=info:#7ac824,prompt:#7aa2f7,pointer:#f7768e"
      "--color=marker:#9ece6a,spinner:#f7768e,header:#9ece6a"
    ];
  };

  # Integración de Zsh
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };
}
