# 06 — Ecosistema de Scripts y Utilidades de Usuario

Este documento describe la arquitectura, dependencias y uso operativo de los scripts y utilidades personalizados enlazados a `~/.local/bin/` mediante [modules/scripts.nix](../modules/scripts.nix).

---

## 1. Integración Profesional con Google Drive (Rclone)

El entorno implementa un **modelo híbrido de dos capas** para gestionar Google Drive de manera ágil entre múltiples laptops:

### Capa 1: Disco Virtual On-Demand (`~/Drive` vía FUSE Aislado)
* **Servicio:** `rclone-gdrive.service` (Systemd de usuario en [modules/apps.nix](../modules/apps.nix)).
* **Arquitectura de Aislamiento XDG:** Para evitar que GVFS (`gvfs-udisks2-volume-monitor`) sondee la API de Google Drive buscando archivos `autorun.inf` o `bdmv` y bloquee D-Bus durante 25 segundos al abrir exploradores como Thunar, el punto de montaje real reside en un subdirectorio XDG oculto: `%h/.local/share/gdrive`.
* **Symlink Transparente:** Se expone de forma automática hacia `%h/Drive` (`~/Drive`) para paridad con terminales y scripts.
* **Resiliencia VFS y Emulación de Cuota:**
  * `--vfs-disk-space-total-size 5T`: Emula un tamaño estático para responder al instante las llamadas al sistema `statfs()`/`statvfs()` de Linux sin consultar la cuota remota por HTTP.
  * `--vfs-cache-mode full` con límite de 15 GB y expiración de 72h.
  * `--attr-timeout 10m` y `--dir-cache-time 24h` para caching agresivo de metadatos.
  * `--timeout 30s` y `--contimeout 10s` para desconexión limpia ante fallos de red.
* **Aliases rápidos en Zsh:** `drive` o `gdrive` para navegar directamente a `$HOME/Drive`.

### Capa 2: Gestor Modular de Sincronización Offline (`sincro`)
* **Ubicación del Script:** [raw_configs/scripts/sincro](../raw_configs/scripts/sincro).
* **Definición Declarativa de Carpetas:** [raw_configs/rclone/sincro-targets.conf](../raw_configs/rclone/sincro-targets.conf) (enlazado a `~/.config/rclone/sincro-targets.conf`).
* **Filtros Antiduplicados y Exclusiones:** [raw_configs/rclone/sincro-filters.txt](../raw_configs/rclone/sincro-filters.txt) (enlazado a `~/.config/rclone/sincro-filters.txt`).
* **Objetivo:** Sincronización bidireccional fiable para carpetas que requieres 100% disponibles en disco sin conexión a internet (ej. Obsidian).
* **Mecanismos de Resiliencia:**
  * Bloqueo contra concurrencia con `flock` para evitar colisiones de base de datos entre procesos.
  * Formato de targets modular: `ALIAS|REMOTO_DRIVE|RUTA_LOCAL`.
  * Filtros automáticos mediante `--filter-from sincro-filters.txt`.

### Prevención de Conflictos y Duplicados Multidispositivo (Obsidian + Linux / Windows / Android)
Cuando sincronizas una bóveda de Obsidian entre **Linux** (con `sincro`), **Windows** (con Google Drive oficial) y **Android** (con FolderSync), el origen clásico de duplicados y archivos `.conflict` **nunca son las notas Markdown**, sino el archivo de estado de interfaz `.obsidian/workspace.json`.

Cada sistema operativo tiene dimensiones de pantalla, ventanas abiertas y posiciones de cursor incompatibles. Si este archivo se sincroniza entre dispositivos al mismo tiempo, los clientes detectan modificaciones concurrentes y generan copias redundantes (`workspace.json.conflict1`, etc.).

Para erradicar la causa raíz, `sincro-filters.txt` aplica las siguientes reglas estándar de la industria:
1. `- .obsidian/workspace*.json`: Cada máquina mantiene su propia disposición de pestañas local sin sobreescribir la de las demás.
2. `- .obsidian/cache/**`: Excluye cachés volátiles de indexación.
3. `- .trash/**`: Evita sincronizar archivos borrados localmente.
4. `- *.conflict*`: Pasa por alto copias residuales de conflictos antiguos generados por clientes externos.
5. `- ~$*.docx / ~$*.pptx / ~$*.xlsx`: Excluye archivos de bloqueo temporal de suites ofimáticas (Word, Excel, PowerPoint) para no generar colisiones en la nube.
6. `- __pycache__/** / .venv/**`: Evita sincronizar entornos y cachés de ejecución locales.
7. `- .git/**`: Excluye bases de datos y repositorios Git locales para evitar que Rclone colisione con respaldos remotos (ej. GitHub).

* **Comandos Operativos:**
  ```bash
  # Sincronizar todos los targets configurados:
  sincro

  # Sincronizar un target especifico (ej. obsidian o ube):
  sincro obsidian
  sincro ube

  # Listar targets configurados y rutas locales:
  sincro --list

  # Consultar estado de conectividad y montaje de Drive:
  sincro --status

  # Inicializar nuevo equipo o forzar resincronizacion en caso de conflicto estructural:
  sincro obsidian --resync
  sincro ube --resync
  ```

### Inicialización en Equipos Nuevos y Protección de Directorios Vacíos
`rclone bisync` incorpora un mecanismo de seguridad por diseño (*Empty Directory Safety Check*):
* **Causa Raíz del Error al Iniciar:** Si una carpeta local se crea vacía (ej. al clonar la configuración o añadir un nuevo target como `/home/jorge/Escritorio/UBE` en una laptop secundaria), `bisync` aborta preventivamente con el mensaje:
  ```text
  ERROR: Path2 is empty, aborting...
  ```
  Esto previene que una carpeta local vacía sea interpretada erróneamente como la eliminación masiva de todos los archivos existentes en Google Drive.
* **Procedimiento Operativo Obligatorio:** En la primera sincronización de cualquier target recién configurado o en una máquina donde el directorio local aún no tiene archivos, es obligatorio ejecutar:
  ```bash
  sincro <alias> --resync
  ```
  Esto construye la base de datos de listados (`listings`) sin interpretar la disparidad como un borrado masivo y descarga todo el contenido remoto de forma segura.

* **Cómo agregar nuevas carpetas a sincronizar:**
  Basta con añadir una nueva línea a `raw_configs/rclone/sincro-targets.conf` (ej. target académico UBE):
  ```text
  ube|gdrive:UBE|$HOME/UBE
  ```

---

## 2. Dictado por Voz Offline (VOXD + Whisper + Ydotool)

* **Ubicación de Scripts:**
  * [raw_configs/scripts/setup-voxd.sh](../raw_configs/scripts/setup-voxd.sh) (Instalador inicial del stack)
  * [raw_configs/scripts/voxd-toggle](../raw_configs/scripts/voxd-toggle) (Interruptor de grabación para atajos)
  * [raw_configs/scripts/whisper-fast-jorge](../raw_configs/scripts/whisper-fast-jorge) (Inferencia directa rápida)
* **Arquitectura Técnica:**
  1. **Motor de Transcripción:** `voxd` ejecutando **Whisper.cpp** con el modelo cuantizado **`small-q8_0`** (~252 MB). Es 100% privado, no envía datos a servidores externos y ofrece latencia mínima en CPUs modernas.
  2. **Inyección de Texto en Wayland:** Utiliza `ydotool` para simular pulsaciones de teclado a través de un daemon de usuario:
     * Unidad de servicio: `~/.config/systemd/user/ydotoold.service`
     * Socket seguro: `$HOME/.ydotool_socket`
  3. **Activación:** Atajo de teclado global en Hyprland: **`Super + D`**.

---

## 3. Rotación Dinámica de Pantalla (`hypr-rotate`)

* **Ubicación:** [raw_configs/scripts/hypr-rotate](../raw_configs/scripts/hypr-rotate)
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

* **Ubicación:** [raw_configs/scripts/selector-libros.sh](../raw_configs/scripts/selector-libros.sh)
* **Objetivo:** Abrir al instante libros, guías técnicas y documentos de estudio en el visor especializado **Sioyek**.
* **Integración:** Lanza un menú interactivo con Rofi indexando las carpetas de libros y documentos locales.
* **Atajo en Hyprland:** **`Super + L`**.

---

## 5. Control de Ventanas en Mosaico (`hypr-window-mosaic.sh`)

* **Ubicación:** [raw_configs/scripts/hypr-window-mosaic.sh](../raw_configs/scripts/hypr-window-mosaic.sh)
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

* **Ubicación:** Generado por [modules/scripts.nix](../modules/scripts.nix)
* **Propósito:** Lee automáticamente todas las opciones y flags declarados en `~/.config/brave-flags.conf` (incluyendo aceleración VA-API por GPU y el factor de escala por host `--force-device-scale-factor`) y los pasa de forma transparente al binario del navegador `/usr/bin/brave-browser-stable`.

---

## 7. Wrapper y Patrón Raise or Launch para Zoom (`zoom`)

* **Ubicación:** Generado por [modules/scripts.nix](../modules/scripts.nix) hacia `~/.local/bin/zoom`.
* **Mecanismos de Ingeniería:**
  1. **Patrón Raise or Launch en Hyprland:** Si se invoca sin argumentos y ya existe una ventana activa con clase `zoom`, utiliza `hyprctl dispatch focuswindow class:^zoom$` para traerla al frente de inmediato, evitando ventanas duplicadas innecesarias.
  2. **Compatibilidad de Reuniones:** Si se recibe un enlace de unión (`zoommtg://...`) o no hay ventanas previas, despacha directamente al binario nativo `/usr/bin/zoom`.
  3. **Purga de Variables de Tema Qt:** Ejecuta bajo `env -u QT_STYLE_OVERRIDE -u QT_QPA_PLATFORMTHEME -u QT_PLUGIN_PATH` para prevenir pantallas negras causadas por temas globales incompatibles con el Qt empaquetado de Zoom.

---

## 8. Wrapper Declarativo para ZapZap / WhatsApp (`zapzap`)

* **Ubicación:** Generado por [modules/scripts.nix](../modules/scripts.nix) hacia `~/.local/bin/zapzap`.
* **Propósito:** Encapsula la ejecución del contenedor Flatpak (`exec /usr/bin/flatpak run com.rtosta.zapzap "$@"`).
* **Beneficio:** Permite lanzar el cliente de WhatsApp desde terminales, scripts personalizados o lanzadores rápidos de manera transparente sin depender de la sintaxis verbosa de Flatpak.

---

## 9. Wrapper Operativo de Despliegue (`switch`)

* **Ubicación:** [switch](../switch) en la raíz del repositorio.
* **Propósito:** Automatiza la aplicación de perfiles de Home Manager resolviendo dinámicamente el hostname de la máquina y blindando la ejecución:
  1. **Resolución Automática:** Detecta `$(hostname)` y resuelve el target `jorge@<hostname>`.
  2. **Validación Preventiva:** Verifica si existe la carpeta correspondiente dentro de `hosts/`. Si no existe, muestra los hosts válidos disponibles y aborta antes de evaluar el Flake.
  3. **Auto-fallback en Bootstrapping:** Si el comando `home-manager` no se encuentra en el `PATH` del usuario (típico en la primera instalación de una laptop), delega automáticamente a `nix run github:nix-community/home-manager -- switch --flake ...` para que el usuario no tenga que memorizar comandos complejos.


