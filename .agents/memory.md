# Memoria Técnica de Infraestructura — Laptops de Trabajo

## 1. Identificación de Equipos y Contexto de Hardware

* **`jorge-terciaria` (Laptop Principal):**
  * Pantalla: Panel interno `eDP-1` a 1920x1080 (1080p nativo).
  * Escala: Estándar (11pt GTK/DConf, Waybar 13px, cursor Bibata 24px).
  * Touchpad: Calibrado para respuesta ágil con `cursorSensitivity = "0.35"` y `scrollFactor = "0.27"`.
  * Gráficos: AMD Radeon con soporte para perfiles `amdgpu-powersave` y `amdgpu-performance`.

* **`jorge-secundaria` (Laptop Auxiliar / Dual Display):**
  * Pantallas:
    * Panel interno `eDP-1` a 1366x768 (768p nativo), posicionado en `1366x0` (derecha).
    * Monitor externo `HDMI-A-1` / `DP-1` a 1366x768, posicionado en `0x0` (izquierda).
  * Workaround físico: La pantalla interna de la laptop tiene una franja rota en su margen izquierdo, compensada mediante directiva de Hyprland (`monitor = eDP-1, addreserved, 0, 0, 228, 0`) y paddings dedicados en Rofi (`rofiLauncherPadding`, `rofiBooksPadding`) en `mySystem`.
  * Workspaces: Intercalados en bloques de 3 (eDP-1: 1, 2, 3, 7, 8, 9; HDMI-A-1: 4, 5, 6, 10).
  * Escala: Compacta (9pt GTK/DConf, Waybar 11px, cursor Bibata 20px, browserScale 0.8, hyprActiveBorder "rgba(ffffffc6)", hyprRounding 10, SwayNC 300x620px, SwayOSD 11px, Hyprshell 11px).

---

## 2. Decisiones Arquitectónicas Fundamentales

1. **Desktop IaC Inmutable:**
   * Las configuraciones de usuario se generan en `/nix/store/` y se enlazan como symlinks de solo lectura.
   * La fuente de verdad es este repositorio Git.
2. **Modelo Híbrido Debian + Home Manager:**
   * Drivers Mesa, kernel y Hyprland base corren en Debian nativo para máxima aceleración 3D/Vulkan y cero problemas de ABI con librerías dinámicas (`radeonsi_dri.so`).
   * Home Manager opera en modo Standalone gestionando paquetes de usuario, servicios systemd de sesión y dotfiles.
3. **Escala Nativa 1.0 vs Escalado Fraccional:**
   * Se prohíbe el escalado menor a 1.0 en Wayland por degradación tipográfica y remuestreo borroso.
   * La densidad visual se adapta mediante las opciones de tipografía y paddings en `mySystem` ([modules/style.nix](../modules/style.nix)).
4. **Seguridad y Permisos:**
   * No se agregan usuarios al grupo secundario `input` por riesgo crítico de keylogging en Wayland. El acceso a periféricos lo gobierna `systemd-logind` / `seatd`.
   * El script de provisionamiento base [setup/instalar.sh](../setup/instalar.sh) es idempotente y crea copias timestamped (`safe_copy`) antes de editar archivos en `/etc/`.
5. **Separación de Herramientas Gráficas y Aceleración GPU (Alacritty, Zoom y Flatpak):**
   * Alacritty y Zoom se delegan al entorno nativo de Debian (`package = null` en Nix o paquete `.deb` en Debian).
   * Aplicaciones de escritorio complejas de terceros (como ZapZap / WhatsApp) se delegan a Flatpak (`flathub`), integradas con wrapper declarativo en `~/.local/bin/` gestionado por Home Manager.
   * Motivo: En Debian con Nix standalone (no NixOS), los paquetes con QtWebEngine/Chromium/OpenGL de Nixpkgs fallan por incompatibilidad ABI con el driver Mesa del host (`radeonsi_drv_video.so` enlazado a `libLLVM.so` de Debian). Flatpak empaqueta sus propios runtimes de Mesa desacoplados de las librerías dinámicas del host, garantizando aceleración completa sin errores de RHI o core dumps.
   * Replicación: `setup/instalar.sh` aprovisiona automáticamente `flatpak`, el remoto Flathub y `com.rtosta.zapzap` para paridad total en nuevas máquinas.

---

## 3. Comandos Operativos Habituales

* Aplicar cambios locales desde la raíz del repositorio:
  ```bash
  home-manager switch --flake .
  ```
* Validar sintaxis estricta de todos los hosts antes de hacer commit:
  ```bash
  nix flake check .
  ```
* Limpieza y recolección de basura del Nix Store:
  ```bash
  nix-collect-garbage -d
  ```

---

## 4. Biblioteca de Estudio (`Super + L`)
* **Script:** `raw_configs/scripts/selector-libros.sh` enlazado a `~/.local/bin/selector-libros.sh`.
* **Pestañas Dinámicas:** `mode-switcher` superior autogenerado al vuelo: `[ Todos ]`, `[ Recientes ]` y una pestaña por cada subcarpeta real que contenga libros en disco (codificación hex en argumentos para inmunidad a caracteres especiales y espacios).
* **Escaneo:** Recursivo con `followlinks=True` y control anti-cíclico (`visited_dirs` con `realpath`) sobre `~/Documentos/Libros` y `~/Documentos/Libros cristianos`.
* **Tema Visual:** `raw_configs/rofi/books.rasi` enlazado a `~/.config/rofi/books.rasi` (Fullscreen WhiteSur-Dark a doble columna, botones píldora adaptativos sin truncamiento y navegación con `Tab` / `Shift+Tab`).
* **Filtros defensivos:** Poda automática de directorios ocultos (`.git`, `.obsidian`, cachés) y archivos ocultos (`.DS_Store`, temporales). Formatos: `.pdf`, `.epub`, `.djvu`. Detección nativa con `shutil.which`.

---

## 5. Gestión del Arranque y Display Manager (GRUB & SDDM)
* **Arquitectura 100% Drop-In en GRUB:**
  * Se mantiene `/etc/default/grub` con valores mínimos limpios para evitar prompts interactivos de `dpkg` en actualizaciones de paquetes.
  * Todas las políticas residen en `/etc/default/grub.d/`: `10-system.cfg` (políticas base y timeout), `20-resume.cfg` (swap física en disco resuelta dinámicamente y filtrando zram), `50-grub-theme.cfg` (tema Apple Dark y GFXMODE sin alterar timeout/recovery) y `99-clean-boot.cfg` (concatenación estricta de parámetros de kernel silencioso con `plymouth.enable=0` y omisión de `splash` para transición oscura directa a SDDM).
* **SDDM Modular y Adaptativo:**
  * Eliminación del `/etc/sddm.conf` monolítico. Uso estricto de drop-ins en `/etc/sddm.conf.d/` (`10-theme.conf`, `20-wayland.conf`, `30-general.conf`, `40-users.conf`).
  * `40-users.conf`: Filtra usuarios de sistema sin shell interactiva (`HideShells=/sbin/nologin,/usr/sbin/nologin,/bin/false,/usr/bin/false`) y establece `MaximumUid=29999` para erradicar la aparición de las cuentas de compilación `nixbld1..32` en el login.
  * Tema `sddm-astronaut-theme` parametrizado con `ScreenWidth=""` y `ScreenHeight=""` para cálculo responsivo en tiempo de ejecución a través del motor QML (`Screen.width` / `Screen.height`), garantizando soporte nativo para 1080p, 768p y monitores externos sin desalineación. Requiere los paquetes `qml6-module-qtquick-effects`, `qml6-module-qtmultimedia` y `qml6-module-qtquick-virtualkeyboard`.
  * Recursos del tema (`astronaut.conf` y `Fondo_de_Bloqueo.png`) centralizados en `setup/sddm/` para aprovisionamiento autosuficiente.

---

## 6. Sincronización y Aplicaciones Gráficas de Sesión
* **Protección de Directorios Vacíos en `sincro`:**
  * `rclone bisync` aborta por diseño ante carpetas locales vacías para evitar interpretar la falta de archivos locales como un borrado masivo en Google Drive.
  * En inicialización de nuevos targets o en laptops secundarias recién configuradas, el comando obligatorio es `sincro <alias> --resync`.
* **Zoom en Debian:**
  * Paquete `.deb` nativo para aceleración hardware.
  * Wrapper en `~/.local/bin/zoom` con patrón *Raise or Launch*: si no se pasan argumentos y ya existe ventana mapeada en Hyprland, la enfoca al instante (`hyprctl dispatch focuswindow class:^zoom$`); si se invoca con enlace de reunión (`zoommtg://`) o sin ventana, despacha limpiando variables de tema Qt (`QT_STYLE_OVERRIDE`, `QT_QPA_PLATFORMTHEME`, `QT_PLUGIN_PATH`).
  * Lanzador `Zoom.desktop` apunta a la ruta absoluta `${config.home.homeDirectory}/.local/bin/zoom %U` para blindar aperturas desde Rofi y navegadores web.
  * Aceleración GPU habilitada en `~/.config/zoomus.conf` (`enableCefGpu=true` y `enablegpucomputeutilization=true`) para renderizado por hardware en CEF sin software rasterizer SwiftShader.
  * Reglas de mosaico en Hyprland: Las ventanas principales de reunión y pantalla compartida se fuerzan a mosaico (`tile true`) mediante regex inclusiva (`Zoom Workplace.*|Zoom Meeting.*|Zoom.*|Reuni.*|Pantalla de Zoom.*|Meeting.*`) para cubrir títulos dinámicos en español y caracteres no-UTF8 de XWayland (`Reuni\ufffd`). Esto garantiza que en `eDP-1` la ventana respete la compensación `addreserved 0, 0, 228, 0` sin invadir la franja rota, y en monitores externos (`HDMI-A-1`) ocupe los 1366x768 completos sin letterboxing de ventana flotante. Diálogos, configuración y popups permanecen en `float true`.
* **Atajos de Lanzamiento Clave:**
  * `Super + A`: Antigravity IDE (`antigravity-ide`).
  * `Super + M`: Zoom (`zoom`).
  * `Super + O`: Obsidian (`obsidian`).
* **Respaldo Git en Obsidian (`vida_de_jorge.git`):**
  * La bóveda `/home/jorge/Documentos/Vida de Jorge` coexiste con Git (GitHub Privado via SSH) y Rclone (`sincro`).
  * `sincro-filters.txt` excluye estrictamente `- .git/**` para que Google Drive no interfiera ni corrompa objetos locales de Git.
  * La bóveda utiliza `.gitignore` local para excluir `.obsidian/workspace*.json`, cachés y papelera `.trash/`.

---

## 7. Entorno de Desarrollo y Neovim (Desktop IaC)
* **Gestión de Lockfile en Entornos Nix Inmutables:**
  * Dado que `~/.config/nvim` es un symlink de solo lectura hacia `/nix/store/`, el parámetro `lockfile` de `lazy.nvim` debe apuntar a una ruta mutable de usuario (`vim.fn.stdpath("data") .. "/lazy-lock.json"`). De lo contrario, cualquier sincronización o actualización de plugins arroja `Permiso denegado`.
* **Arquitectura LSP Nativa (Neovim 0.11+ / 0.12):**
  * Se descarta el framework legacy `require("lspconfig")[server].setup(...)` y se utiliza la API nativa `vim.lsp.config` y `vim.lsp.enable` junto al evento autocmd `LspAttach`.
  * Se prohíbe el uso de monkey-patches en `vim.notify` para ocultar avisos de deprecación.
* **Herramientas CLI Declarativas de Soporte:**
  * Linters, formatters y compiladores de parsers (`tree-sitter`, `ripgrep`, `fd`, `stylua`, `shfmt`, `shellcheck`, `ruff`) se declaran en `home.packages` dentro de `modules/apps.nix` para garantizar su presencia independiente del host o distribución subyacente.

---

## 8. Optimización FUSE de Google Drive y Rendimiento de Exploradores (Desktop IaC)
* **Prevención de Bloqueos en `statfs` / GVFS (`rclone-gdrive`):**
  * Al montar Google Drive vía FUSE en `modules/apps.nix` (`~/Drive`), es mandatorio declarar `--vfs-disk-space-total-size 5T` y `--vfs-fast-fingerprint`.
  * Motivo: Sin esta bandera, `rclone` intercepta las llamadas al sistema `statfs()`/`statvfs()` de Linux y realiza una consulta HTTP síncrona a la API de Google Drive (`About.get`) para resolver la cuota libre. Esto congela de forma síncrona a exploradores de archivos (Thunar, Yazi) y monitores de dispositivos (`gvfs-udisks2-volume-monitor`) durante 20-35 segundos en el arranque. Declarar el tamaño estático emula la geometría en memoria local respondiendo en milisegundos sin llamadas de red.
* **Blindaje del Servicio FUSE y Resiliencia de Red:**
  * La unidad `rclone-gdrive.service` no debe depender de `network-online.target` (inexistente en `systemd --user`), sino acoplarse a `graphical-session.target`.
  * Parámetros innegociables de resiliencia: `--attr-timeout 10m` y `--dir-cache-time 24h` (eliminan consultas repetitivas de atributos a la API remota), `--poll-interval 1m` (notificaciones asíncronas de cambios), `--timeout 30s` y `--contimeout 10s` (límite estricto para evitar sockets en estado D en el kernel ante caídas de red) y `--no-modtime`.
* **Aislamiento Declarativo de Miniaturas (Tumbler y Thunar):**
  * `raw_configs/tumbler/tumbler.rc` enlazado a `~/.config/tumbler/tumbler.rc`: Define formalmente `Excludes=~/Drive;~/.cache;` en todos los generadores y fija `MaxFileSize=52428800` (50 MB). Esto impide que `tumblerd` intente escanear o descargar archivos a través de FUSE, eliminando saturaciones del bus D-Bus y deadlocks en el hilo de UI de GTK.
  * `raw_configs/xfce4/xfconf/xfce-perchannel-xml/thunar.xml` enlazado declarativamente por Home Manager: Fija `misc-thumbnail-mode="THUNAR_THUMBNAIL_MODE_ONLY_LOCAL"` y `misc-parallel-copy-mode="THUNAR_PARALLEL_COPY_MODE_ALWAYS"`.
* **Stack Base del Sistema Operativo (`setup/instalar.sh`):**
  * Para réplica limpia en nuevas máquinas, `instalar.sh` aprovisiona obligatoriamente: `thunar`, `thunar-volman`, `thunar-archive-plugin`, `gvfs`, `gvfs-backends`, `gvfs-fuse` (imprescindible para el puente GIO/FUSE), `tumbler`, `tumbler-plugins-extra` y `ffmpegthumbnailer`.
  * Habilita de forma idempotente `user_allow_other` en `/etc/fuse.conf` para desacoplamiento seguro de permisos entre demonios de usuario y el kernel.
