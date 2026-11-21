# 01 — Arquitectura del Sistema (Desktop IaC)

## 1. Filosofía de Ingeniería: Desktop Infrastructure as Code (Desktop IaC)

Este repositorio traslada los principios de la ingeniería de infraestructura en la nube (**IaC**, **GitOps**, **Idempotencia** e **Inmutabilidad**) a la gestión de estaciones de trabajo personales (laptops).

El objetivo es erradicar por completo el **desvío de configuración (*Configuration Drift*)**:
* Ningún cambio estético, de paquetes o de comportamiento se realiza directamente mediante clics o comandos manuales no reproducibles.
* La configuración completa reside en Git como fuente única de verdad (*Single Source of Truth*).
* Los archivos resultantes generados en el directorio de usuario (`~/.config/`, `~/.local/bin/`, etc.) son enlaces simbólicos de solo lectura que apuntan directamente a entradas criptográficamente verificadas dentro del **Nix Store** (`/nix/store/`).

```mermaid
graph TD
    Repo[Repositorio Git ~/dotfiles-nix] -->|flake.nix & home.nix| NixFlake[Evaluación Nix Flakes]
    HostProfile[hosts/jorge-*] -->|mySystem & monitores| NixFlake
    NixFlake -->|home-manager switch| NixStore[/nix/store/... Inmutable/]
    NixStore -->|Symlinks de solo lectura| HomeDir[Entorno de Usuario ~]
    HomeDir --> Conf[~/.config/*]
    HomeDir --> Bin[~/.local/bin/*]
    HomeDir --> Themes[~/.local/share/themes & icons]
```

---

## 2. Modelo Híbrido: Debian GNU/Linux + Nix Flakes Standalone

Una de las decisiones arquitectónicas más importantes de este entorno es el uso de **Home Manager en modo Standalone sobre Debian GNU/Linux**, en lugar de utilizar NixOS puro.

### Separación de Responsabilidades (*Separation of Concerns*)

| Capa | Administrador | Responsabilidad Técnica | Razón de Ingeniería |
| :--- | :--- | :--- | :--- |
| **Capa 1: Sistema Base** | Debian (`apt` + `/etc/`) | Kernel Linux, Firmware/DRM, controladores gráficos Mesa 32/64 bits (AMDGPU/Intel), PipeWire, compositor Hyprland base, Display Manager SDDM (módulos Qt6), autenticación PAM (`/etc/pam.d/hyprlock` para `hyprlock`/`hypridle`), almacenamiento de sistema/FUSE (`gvfs`, `gvfs-fuse`, `pcmanfm-qt`, `lxqt-archiver`), TLP y aplicaciones nativas aceleradas (`brave-browser`, `zoom`, `steam-installer`, `ffmpeg`). | Enlace 100% nativo con librerías dinámicas del sistema (`radeonsi_dri.so`, `libEGL.so`), aceleración por hardware por GPU sin wrappers ni desajustes de ABI, y gestión de seguridad privilegiada en PAM que no puede ser gobernada por gestores de paquetes no privilegiados de usuario. |
| **Capa 2: Entorno Declarativo** | Nix Flakes + Home Manager | Herramientas CLI (Neovim, Yazi, Tmux, Zoxide, Bat, Direnv + nix-direnv, Delta, Lazygit, Lazydocker, Fastfetch, LSD, Rclone, Linters/Formatters, gestor Python `uv`, Node.js 22), toolchain DevSecOps (`gitleaks`, `trivy`, `age`, `sops`), Git endurecido con firma SSH, monitor `btop`, entorno visual de sesión (Waybar, Rofi, SwayNC, SwayOSD, Hyprshell), perfiles de rendimiento (`low` / `balanced` / `full`), temas GTK/Qt (`qt6ct`), cursores, fuentes, scripts en `~/.local/bin/` y dotfiles inmutables en `/nix/store/` (incluyendo `hyprlock.conf` e `hypridle.conf`). | Entorno reproducible, versionado, aislado de dependencias de Debian y con posibilidad de rollback instantáneo sin romper el sistema operativo. Se evita instalar paquetes que colisionen con PAM del host. |
| **Capa 3: Aplicaciones GUI Aisladas** | Flatpak (`flathub`) | Clientes de mensajería (ZapZap / WhatsApp), multimedia y aplicaciones de terceros con interfaces web o QtWebEngine complejas. | Provee runtimes y drivers Mesa autocontenidos que operan directamente sobre el subsistema DRM del kernel, eliminando rupturas de enlaces dinámicos (ABI) que ocurren al ejecutar aplicaciones gráficas pesadas dentro de Nix Standalone sobre Debian. |

### Por qué esta separación es superior en laptops de producción:
1. **Estabilidad Gráfica en Wayland:** Compositor Wayland (Hyprland) y navegadores (Brave/Chromium) se comunican directamente con el subsistema gráfico del kernel y Mesa sin desajustes de versiones de drivers.
2. **Portabilidad Multi-Distribución:** Si una laptop futura utiliza Arch Linux, Fedora u otra distro, la capa de usuario de Nix se despliega de forma idéntica sin modificar la lógica declarativa.

### Gestión de Binarios CLI Autónomos en Nivel 1 (`agy`)
El binario autónomo `agy` (~258 MB, con auto-updater integrado) sigue el mismo estándar FHS de Nivel 1 que `antigravity` y `antigravity-ide`:
* **Ubicación en SSD (`/opt/agy/agy`):** Expuesto globalmente mediante enlace simbólico en `/usr/local/bin/agy` y excluido de `/nix/store/` para no bloquear su mecanismo de actualización.
* **Causa Raíz Técnica:** En máquinas con `/` en SSD y `/home` en HDD mecánico de 5400 RPM, alojar un ejecutable monolítico de 258 MB en `$HOME/.local/bin/` provoca lecturas en frío de 5 a 12 segundos. Mantenerlo en `/opt/agy/` respeta la separación `/` vs `/home` sin enlaces rotos, logra lecturas en frío en < 0.5 s sobre el SSD y se actualiza con `sudo agy update`.

---

## 3. La Dupla Técnica: Nix Flakes + Home Manager

La arquitectura se sustenta en dos herramientas complementarias que resuelven dos problemas distintos:

### ¿Qué hace Nix Flakes? (Capa de Reproducibilidad e Integridad)
* **Bloqueo Criptográfico de Dependencias:** A través de [flake.lock](../flake.lock), fija los hashes exactos de los canales de `nixpkgs` y `home-manager`. Ambas laptops compilan y descargan exactamente las mismas versiones de paquetes sin variación temporal.
* **Hermetismo y Cero Efectos Secundarios:** Las evaluaciones no dependen de variables de entorno globales del sistema ni de canales imperativos (`nix-channel`), eliminando el problema clásico de *"en mi máquina sí funciona"*.
* **Definición de Entradas y Salidas Estructuradas:** Expone formalmente la función `outputs` donde se declaran las configuraciones de cada laptop (`jorge@jorge-terciaria`, `jorge@jorge-secundaria`).

### ¿Qué hace Home Manager? (Capa de Gestión del Entorno de Usuario)
* **Orquestación de `$HOME`:** Transforma las expresiones Nix en archivos reales dentro de `/nix/store/` y crea los enlaces simbólicos de solo lectura hacia `~/.config/`, `~/.local/share/` y `~/.local/bin/`.
* **Servicios de Usuario Systemd:** Levanta y supervisa automáticamente los daemons de usuario como `swaync`, `swayosd`, `wlsunset` y `hyprshell` vinculados a `graphical-session.target`.
* **Inyección de Variables de Sesión:** Exporta de manera declarativa variables críticas para Wayland (`XDG_SESSION_TYPE`, `GTK_THEME`, `XCURSOR_SIZE`, etc.) sin ensuciar manualmente `.bashrc` o `/etc/environment`.
* **Aislamiento Multi-Host:** Permite inyectar los parámetros de hardware específicos de cada laptop (`hosts/jorge-*`) sobre una base común compartida ([home.nix](../home.nix)).

---

## 4. Estructura y Flujo de Evaluación de Nix

El punto de entrada del sistema es [flake.nix](../flake.nix):

1. **`inputs`:**
   * `nixpkgs`: Canal `nixos-unstable` para disponer del software más moderno.
   * `home-manager`: Rama sincronizada que sigue a `nixpkgs` para garantizar compatibilidad binaria de librerías.
2. **`outputs`:**
   * **Auto-descubrimiento dinámico de hosts:** En lugar de declarar targets manualmente, [flake.nix](../flake.nix) escanea recursivamente el directorio `./hosts/` mediante `builtins.readDir` y genera automáticamente la configuración `"jorge@<hostname>"` para cualquier nuevo subdirectorio creado.
   * Expone formalmente `homeConfigurations`:
     * `"jorge@jorge-terciaria"`: Mapea a [home.nix](../home.nix) + [hosts/jorge-terciaria](../hosts/jorge-terciaria).
     * `"jorge@jorge-secundaria"`: Mapea a [home.nix](../home.nix) + [hosts/jorge-secundaria](../hosts/jorge-secundaria).
     * `"jorge"`: Alias de conveniencia retrocompatible.
   * **Script Operativo de Despliegue ([switch](../switch)):** Wrapper que resuelve dinámicamente `$(hostname)`, valida la existencia del perfil en `hosts/` y ejecuta `home-manager switch --flake .#jorge@<hostname>`.
   * **Validación Continua (CI):** Pipeline en `.github/workflows/ci.yml` que valida la integridad de todos los perfiles de la flota con `nix flake check` en cada commit.
3. **Módulos (`modules/`):**
   * [home.nix](../home.nix) orquesta la importación modular de:
     * `style.nix`: Motor de temas, fuentes y opciones tipadas `mySystem`.
     * `desktop.nix`: Componentes de escritorio, servicios de usuario systemd y Waybar.
     * `apps.nix`: Terminal Alacritty tipado, navegadores, flags de aceleración y utilidades.
     * `shell.nix`: Zsh, Starship prompt, FZF personalizado y Git.
     * `scripts.nix`: Enlace declarativo de ejecutables a `~/.local/bin/`.

---

## 5. Subsistema de Archivos, VFS y Aislamiento FUSE

La exploración de archivos y el montaje de unidades virtuales combinan la base de Debian y Home Manager bajo un diseño estrictamente defensivo para erradicar cuelgues de la interfaz gráfica:

```mermaid
graph TD
    PCManFM["PCManFM-Qt (Qt6 / Wayland)"] -->|Miniaturas locales <= 2 MB| LocalThumb["libfm-qt (ThumbnailLocalFilesOnly=true)"]
    PCManFM -->|I/O Local| Ext4["Almacenamiento Local (SSD / Ext4)"]
    PCManFM -->|Acceso a ~/Drive| FUSE["Kernel VFS / FUSE (/etc/fuse.conf)"]
    FUSE -->|Lectura con Caché VFS| Rclone["Rclone Daemon (rclone-gdrive.service)"]
    Rclone -->|HTTPS con Timeout estricto| GDrive["Google Drive (Cloud)"]
```

### Principios de Aislamiento
1. **Políticas Inmutables en PCManFM-Qt ([raw_configs/pcmanfm-qt/settings.conf](../raw_configs/pcmanfm-qt/settings.conf)):**
   * Enlazado declarativamente por Home Manager a `~/.config/pcmanfm-qt/default/settings.conf`.
   * Fija `ThumbnailLocalFilesOnly=true` y `MaxThumbnailFileSize=2048` (2 MB) para impedir que `libfm-qt` descargue archivos a través de FUSE al generar previsualizaciones.
   * Fija `PlacesNetwork=false` y `MountOnStartup=false` para erradicar sondeos de red y demoras en el arranque en frío.
   * Integra de forma nativa `Terminal=alacritty` (`F4`), `Archiver=lxqt-archiver`, vista dividida (`F3`), barra de rutas moderna (`PathBarButtons=true`) sin barra de menú legacy (`ShowMenuBar=false`), y tema visual oscuro coherente vía `qt6ct` (`Tela-circle-dark` + `Fusion`).
2. **Resiliencia en el Montaje FUSE de Rclone ([modules/apps.nix](../modules/apps.nix)):**
   * Vinculado a `graphical-session.target`.
   * Banderas críticas: `--attr-timeout 10m` y `--dir-cache-time 72h` (eliminan llamadas remotas `stat()` redundantes al retener metadatos en memoria), `--poll-interval 1m` (notificaciones asíncronas de cambios), `--vfs-disk-space-total-size 5T` (emulación estática de espacio que previene congelamiento en `statfs()`), `--daemon-timeout 5s` (límite estricto para que rclone nunca retenga peticiones del kernel en estado D si la red está en negociación), `--timeout 10s` y `--contimeout 5s` (corte estricto de sockets para prevenir procesos en estado D no interrumpible ante fallos de red o rate-limits de Google Drive) y `--no-modtime`.
3. **Aislamiento FUSE contra Sondeos de Discos GVFS ([modules/apps.nix](../modules/apps.nix)):**
   * El sistema FUSE se monta en `~/.local/share/gdrive` y se expone como enlace simbólico transparente en `~/Drive`.
   * Motivo técnico: La regla nativa de GVFS (`g_strstr_len(mount_path, -1, "/.") != NULL`) ignora automáticamente cualquier montaje en subdirectorios ocultos. Esto impide que `gvfs-udisks2-volume-monitor` lo catalogue como unidad extraíble y envíe sondeos síncronos de red (`autorun.inf`, `bdmv`, `xdg_volume_info`) al abrir diálogos de archivos o exploradores en frío, eliminando de raíz el timeout de 25 segundos de D-Bus.
4. **Desactivación Blindada de AutoMount en GVFS de Red ([setup/instalar.sh](../setup/instalar.sh)):**
   * Se fija `AutoMount=false` en `/usr/share/gvfs/mounts/network.mount` y `/usr/share/gvfs/mounts/wsdd.mount` protegidos mediante `dpkg-divert` contra futuras actualizaciones de `apt`.
   * Motivo técnico: Por defecto Debian activa el sondeo automático de red local (mDNS, SMB y WSDD), lo cual induce bloqueos de 20 a 25 segundos en los diálogos de archivos GTK (navegadores, Obsidian, etc.). Al desactivar el automount preventivo con `dpkg-divert`, la política sobrevive a cualquier actualización del sistema.

---

## 6. Resolución Declarativa de Tipos MIME y Protocolos URL

El despacho de enlaces web y protocolos personalizados (`zoommtg://`, `zoomus://`, `whatsapp://`, `mailto://`) se gobierna mediante la especificación oficial de **FreeDesktop XDG MIME**:

1. **Preferencia Primaria Declarativa ([raw_configs/mimeapps.list](../raw_configs/mimeapps.list)):**
   * Enlazado a `~/.config/mimeapps.list` por Home Manager.
   * La biblioteca GLib/GIO y los portales Wayland (`xdg-desktop-portal-gtk` vía OpenURI) consultan primero este archivo. Al definir explícitamente los mapeos:
     ```ini
     [Default Applications]
     x-scheme-handler/zoommtg=Zoom.desktop
     x-scheme-handler/zoomus=Zoom.desktop
     x-scheme-handler/whatsapp=com.rtosta.zapzap.desktop
     ```
   * Se elimina la necesidad de herramientas auxiliares o reconstrucciones de caché `mimeinfo.cache`, resolviendo los lanzadores de forma instantánea sin mostrar cuadros de error de aplicaciones no disponibles.

---

## 7. Ciclo de Vida de Seguridad y Gestión Criptográfica de Parches

La gestión de parches para vulnerabilidades críticas (como fallos RCE o denegación de servicio en runtimes) aprovecha el determinismo de **Nix Flakes**:

1. **Bloqueo Inmutable de Versiones ([flake.lock](../flake.lock)):**
   * Cada herramienta del entorno de desarrollo (Node.js, Neovim, linters, compiladores) está fijada a un hash SHA-256 exacto. Ningún commit o compilación introduce cambios flotantes sin consentimiento.
2. **Mitigación Quirúrgica de Vulnerabilidades:**
   * Ante alertas de seguridad críticas (ejemplo: `CVE-2026-111497` de ejecución remota de código en el decodificador Brotli de Node.js 22.x), la remediación se ejecuta actualizando el input de Nixpkgs (`nix flake update nixpkgs`).
   * Nix descarga la versión mitigada (`v22.23.4`) directamente de la caché binaria oficial (`cache.nixos.org`), reemplazando el runtime en `/nix/store/` sin tocar el gestor de paquetes del sistema operativo base (Debian).
3. **Distribución Cero-Drift a la Flota:**
   * Al hacer commit de `flake.lock` y sincronizarlo mediante Git, cualquier laptop de la flota que ejecute `git pull && ./switch` recibe exactamente el mismo binario validado criptográficamente, erradicando discrepancias entre equipos de trabajo.
