{ config, pkgs, ... }:

{
  # Alacritty (Terminal con Tokyo Night)
  xdg.configFile."alacritty/alacritty.toml".source = ../raw_configs/alacritty/alacritty.toml;

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
}
