{ config, pkgs, ... }:

{
  # Configuración Declarativa de GTK
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Tela-circle-dracula";
      package = pkgs.tela-circle-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };
    gtk4.theme = config.gtk.theme;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # Configuración Declarativa de Qt (Fusion nativo + Qt6CT)
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "fusion";
  };

  # Configuración global del esquema oscuro en DConf / XDG Desktop Portal
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Catppuccin-Mocha";
      icon-theme = "Tela-circle-dracula";
      cursor-theme = "Bibata-Modern-Ice";
    };
  };

  # Enlace declarativo de xsettingsd.conf para compatibilidad con X11 / XWayland
  xdg.configFile."xsettingsd/xsettingsd.conf".text = ''
    Net/ThemeName "Catppuccin-Mocha"
    Net/IconThemeName "Tela-circle-dracula"
    Gtk/CursorThemeName "Bibata-Modern-Ice"
    Net/EnableEventSounds 1
    EnableInputFeedbackSounds 0
    Xft/Antialias 1
    Xft/Hinting 1
    Xft/HintStyle "hintfull"
    Xft/RGBA "rgb"
  '';

  # Cursor global predeterminado para aplicaciones aisladas
  home.file.".local/share/icons/default/index.theme".text = ''
    [Icon Theme]
    Inherits=Bibata-Modern-Ice
  '';
}
