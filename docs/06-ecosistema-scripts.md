# 06 — Ecosistema de Scripts y Utilidades de Usuario

Este documento describe la arquitectura, dependencias y uso operativo de los scripts y utilidades personalizados enlazados a `~/.local/bin/` mediante [modules/scripts.nix](file:///home/jorge/dotfiles-nix/modules/scripts.nix).

---

## 1. Sincronización de Obsidian con Rclone (`sincro`)

* **Ubicación:** [raw_configs/scripts/sincro](file:///home/jorge/dotfiles-nix/raw_configs/scripts/sincro)
* **Objetivo:** Sincronización bidireccional fiable de la bóveda de notas personales y académicas de Obsidian con Google Drive.
* **Ruta Local:** `~/Documentos/Vida de Jorge`
* **Remoto Rclone:** `gdrive:Vida de Jorge`
* **Mecanismo:** Utiliza `rclone bisync` con flags verbose para mantener coherencia de timestamps y resolución de conflictos entre diferentes laptops.
* **Uso:**
  ```bash
  # Ejecución interactiva directa o desde alias zsh:
  sincro

  # Modo de re-sincronización forzada en caso de conflicto estructural:
  sincro --resync
  ```

---

## 2. Dictado por Voz Offline (VOXD + Whisper + Ydotool)

* **Ubicación de Scripts:**
  * [raw_configs/scripts/setup-voxd.sh](file:///home/jorge/dotfiles-nix/raw_configs/scripts/setup-voxd.sh) (Instalador inicial del stack)
  * [raw_configs/scripts/voxd-toggle](file:///home/jorge/dotfiles-nix/raw_configs/scripts/voxd-toggle) (Interruptor de grabación para atajos)
  * [raw_configs/scripts/whisper-fast-jorge](file:///home/jorge/dotfiles-nix/raw_configs/scripts/whisper-fast-jorge) (Inferencia directa rápida)
* **Arquitectura Técnica:**
  1. **Motor de Transcripción:** `voxd` ejecutando **Whisper.cpp** con el modelo cuantizado **`small-q8_0`** (~252 MB). Es 100% privado, no envía datos a servidores externos y ofrece latencia mínima en CPUs modernas.
  2. **Inyección de Texto en Wayland:** Utiliza `ydotool` para simular pulsaciones de teclado a través de un daemon de usuario:
     * Unidad de servicio: `~/.config/systemd/user/ydotoold.service`
     * Socket seguro: `$HOME/.ydotool_socket`
  3. **Activación:** Atajo de teclado global en Hyprland: **`Super + D`**.

---

## 3. Rotación Dinámica de Pantalla (`hypr-rotate`)

* **Ubicación:** [raw_configs/scripts/hypr-rotate](file:///home/jorge/dotfiles-nix/raw_configs/scripts/hypr-rotate)
* **Objetivo:** Rotar la orientación de la pantalla de la laptop sobre la marcha (ideal para lectura de documentos largos o visualización vertical de código).
* **Parámetros Soportados:** `normal (0°)`, `left (90°)`, `inverted (180°)`, `right (270°)`, `toggle`.
* **Mecanismo:**
  1. Detecta dinámicamente el monitor interno activo (`eDP-1`) mediante `hyprctl monitors -j | jq`.
  2. Aplica la transformación de matriz de pantalla preservando la escala nativa del monitor.
  3. Reinicia automáticamente la barra superior Waybar para adaptar su orientación y dimensiones.
  4. Envía una notificación OSD en pantalla con el nuevo estado.
* **Atajos Rápidos en Hyprland:** **`Alt + R`** o **`AltGr + R`**.

---

## 4. Selector Rápido de Libros de Estudio (`selector-libros.sh`)

* **Ubicación:** [raw_configs/scripts/selector-libros.sh](file:///home/jorge/dotfiles-nix/raw_configs/scripts/selector-libros.sh)
* **Objetivo:** Abrir al instante libros, guías técnicas y documentos de estudio en el visor especializado **Sioyek**.
* **Integración:** Lanza un menú interactivo con Rofi indexando las carpetas de libros y documentos locales.
* **Atajo en Hyprland:** **`Super + L`**.

---

## 5. Control de Ventanas en Mosaico (`hypr-window-mosaic.sh`)

* **Ubicación:** [raw_configs/scripts/hypr-window-mosaic.sh](file:///home/jorge/dotfiles-nix/raw_configs/scripts/hypr-window-mosaic.sh)
* **Objetivo:** Reposicionar la ventana activa en cuadrantes y mitades exactas sin depender del mouse:
  * `Super + Alt + 1`: Mitad izquierda
  * `Super + Alt + 2`: Mitad derecha
  * `Super + Alt + 3`: Mitad superior
  * `Super + Alt + 4`: Mitad inferior
  * `Super + Alt + 5`: Esquina inferior
  * `Super + Alt + 0`: Centrado en pantalla
  * `Super + Alt + T`: Alternar modo tiled / flotante

---

## 6. Wrapper Universal para Brave Browser (`brave-browser`)

* **Ubicación:** Generado por [modules/scripts.nix](file:///home/jorge/dotfiles-nix/modules/scripts.nix)
* **Propósito:** Lee automáticamente todas las opciones y flags declarados en `~/.config/brave-flags.conf` (incluyendo aceleración VA-API por GPU y el factor de escala por host `--force-device-scale-factor`) y los pasa de forma transparente al binario del navegador `/usr/bin/brave-browser-stable`.
