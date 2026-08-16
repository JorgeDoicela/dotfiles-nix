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

  home.file.".local/bin/sincro" = {
    source = ../raw_configs/scripts/sincro;
    executable = true;
  };

  home.file.".local/bin/selector-libros.sh" = {
    source = ../raw_configs/scripts/selector-libros.sh;
    executable = true;
  };

  home.file.".local/bin/check-kbd-backlight-boot.sh" = {
    source = ../raw_configs/scripts/check-kbd-backlight-boot.sh;
    executable = true;
  };

  home.file.".local/bin/set-kbd-backlight-half.sh" = {
    source = ../raw_configs/scripts/set-kbd-backlight-half.sh;
    executable = true;
  };

  home.file.".local/bin/setup-voxd.sh" = {
    source = ../raw_configs/scripts/setup-voxd.sh;
    executable = true;
  };

  home.file.".local/bin/voxd-daemon.py" = {
    source = ../raw_configs/scripts/voxd-daemon.py;
    executable = true;
  };

  home.file.".local/bin/voxd-press.sh" = {
    source = ../raw_configs/scripts/voxd-press.sh;
    executable = true;
  };

  home.file.".local/bin/voxd-release.sh" = {
    source = ../raw_configs/scripts/voxd-release.sh;
    executable = true;
  };

  home.file.".local/bin/voxd-toggle" = {
    source = ../raw_configs/scripts/voxd-toggle;
    executable = true;
  };

  home.file.".local/bin/whisper-fast-jorge" = {
    source = ../raw_configs/scripts/whisper-fast-jorge;
    executable = true;
  };

  home.file.".local/bin/hypr-rotate" = {
    source = ../raw_configs/scripts/hypr-rotate;
    executable = true;
  };
}
