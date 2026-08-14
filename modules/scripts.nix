{ config, pkgs, ... }:

{
  # Enlace declarativo con permisos de ejecución para scripts personales en ~/.local/bin
  home.file.".local/bin/flameshot-hypr" = {
    source = ../raw_configs/scripts/flameshot-hypr;
    executable = true;
  };

  home.file.".local/bin/lockscreen-splash.sh" = {
    source = ../raw_configs/scripts/lockscreen-splash.sh;
    executable = true;
  };

  home.file.".local/bin/hypr-window-mosaic.sh" = {
    source = ../raw_configs/scripts/hypr-window-mosaic.sh;
    executable = true;
  };
}
