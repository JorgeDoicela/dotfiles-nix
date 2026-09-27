# 03 — Sistema de Diseño y Escalado Declarativo

Este documento detalla la solución arquitectónica implementada en [modules/style.nix](../modules/style.nix) para gestionar la apariencia visual y resolver el problema del escalado de pantallas en Wayland sin degradar la calidad tipográfica.

---

## 1. El Problema del Escalado Fraccional en Wayland

En compositores Wayland modernos (como Hyprland con backend Aquamarine), configurar una escala fraccional menor a 1.0 (por ejemplo, `scale = 0.8` para que "quepan más cosas" en un panel de 1366x768):

1. **Provoca remuestreo borroso:** Wayland renderiza la superficie a una resolución virtual y luego la re-escala usando filtrado bilineal o bicúbico, lo que destruye el *subpixel rendering* de las fuentes.
2. **Cuantización forzada:** Muchos compositores redondean a fracciones estrictas (como `2/3 = 0.67`), provocando saltos bruscos en el tamaño de los elementos.
3. **Pérdida de rendimiento:** Requiere procesamiento de GPU continuo para el reescalado de buffers de ventana.

### Solución de Ingeniería Adoptada: Escala Nativa 1.0 + Parametrización Declarativa
Se mantiene la escala del monitor fija en **`1.0`** y se modulan dinámicamente los tamaños tipográficos, paddings y dimensiones de componentes a través del submódulo **`mySystem`**.

---

## 2. Definición del Módulo `mySystem`

En [modules/style.nix](../modules/style.nix) se declaran las opciones que cada host puede sobreescribir:

```nix
options.mySystem = {
  fontSize          = lib.mkOption { type = lib.types.number; default = 11; };
  cursorSize        = lib.mkOption { type = lib.types.int;    default = 24; };
  waybarFontSize    = lib.mkOption { type = lib.types.str;    default = "13px"; };
  rofiFontSize      = lib.mkOption { type = lib.types.str;    default = "10"; };
  rofiWidth         = lib.mkOption { type = lib.types.str;    default = "600px"; };
  rofiHeight        = lib.mkOption { type = lib.types.str;    default = "350px"; };
  browserScale      = lib.mkOption { type = lib.types.str;    default = "1"; };
  cursorSensitivity = lib.mkOption { type = lib.types.str;    default = "0.2"; };
  scrollFactor      = lib.mkOption { type = lib.types.str;    default = "0.75"; };
};
```

---

## 3. Cadena de Propagación a Aplicaciones

Los valores definidos en cada host se propagan automáticamente a las siguientes capas del sistema:

### 1. Entorno GTK3, GTK4 y DConf / GNOME
```nix
gtk = {
  font = {
    name = "JetBrainsMono Nerd Font";
    size = config.mySystem.fontSize;
  };
  cursorTheme = {
    name = "Bibata-Modern-Ice";
    size = config.mySystem.cursorSize;
  };
};

dconf.settings."org/gnome/desktop/interface" = {
  cursor-size = config.mySystem.cursorSize;
  document-font-name = "JetBrainsMono Nerd Font ${toString config.mySystem.fontSize}";
  monospace-font-name = "JetBrainsMono Nerd Font ${toString config.mySystem.fontSize}";
};
```

### 2. X11 / XWayland (`xsettingsd`)
Garantiza que aplicaciones legacy o juegos que corren bajo XWayland mantengan la escala y tamaño del cursor idénticos a las aplicaciones nativas de Wayland:
```nix
xdg.configFile."xsettingsd/xsettingsd.conf".text = ''
  Gtk/CursorThemeSize ${toString config.mySystem.cursorSize}
  Gtk/FontName "JetBrainsMono Nerd Font ${toString config.mySystem.fontSize}"
'';
```

### 3. Terminal Alacritty ([modules/apps.nix](../modules/apps.nix))
Se utiliza el módulo nativo fuertemente tipado de Home Manager para inyectar la tipografía y paddings adaptativos sin manipular strings de archivos de configuración:
```nix
programs.alacritty.settings = {
  font.size = config.mySystem.fontSize;
  window.padding = {
    x = if config.mySystem.fontSize < 10 then 10 else 14;
    y = if config.mySystem.fontSize < 10 then 10 else 14;
  };
};
```

### 4. Waybar ([modules/desktop.nix](../modules/desktop.nix))
Inyección de token explícito en el archivo CSS de estilos:
```nix
xdg.configFile."waybar/style.css".text =
  builtins.replaceStrings [ "@WAYBAR_FONT_SIZE@" ] [ config.mySystem.waybarFontSize ]
    (builtins.readFile ../raw_configs/waybar/style.css);
```

### 5. Lanzador Rofi ([modules/desktop.nix](../modules/desktop.nix))
Inyección dinámica de ancho, alto y tamaño de fuente en `config.rasi`:
```nix
xdg.configFile."rofi/config.rasi".text =
  builtins.replaceStrings
    [ "@ROFI_FONT@" "@ROFI_WIDTH@" "@ROFI_HEIGHT@" ]
    [ "JetBrainsMono Nerd Font ${config.mySystem.rofiFontSize}"
      config.mySystem.rofiWidth
      config.mySystem.rofiHeight
    ]
    (builtins.readFile ../raw_configs/rofi/config.rasi);
```

### 6. Navegadores Web (Chromium y Brave)
Para pantallas pequeñas (como en `jorge-secundaria`), se inyecta el flag `--force-device-scale-factor=0.8` en `brave-flags.conf` y se ejecuta mediante el wrapper universal [brave-browser](../modules/scripts.nix).

---

## 4. Arquitectura de la Barra de Estado (Waybar) Multi-Host

La barra superior sigue un esquema estrictamente adaptado al hardware de cada equipo:

### Perfil 1: `jorge-terciaria` (Panel 1080p Único)
* **Archivo de Configuración:** [hosts/jorge-terciaria/config.json](../hosts/jorge-terciaria/config.json)
* **Altura:** `34px`
* **Módulos Izquierda:** Lanzador Tux (`custom/launcher`), espacios de trabajo (`hyprland/workspaces`), título de ventana activa (`hyprland/window`).
* **Módulos Centro:** Reloj con fecha y hora (`clock`), sondeo térmico cada 30s sin segundos.
* **Módulos Derecha:** MPRIS (reproductor de medios), uso de CPU, uso de RAM, estado Wi-Fi/Ethernet, Bluetooth, control de volumen PipeWire/PulseAudio, batería inteligente, centro de notificaciones SwayNC con Do-Not-Disturb y botón de sesión wlogout.
* **Telemetría de Batería:** Clic en el icono de batería invoca [raw_configs/hypr/scripts/battery-info.sh](../raw_configs/hypr/scripts/battery-info.sh) para emitir una notificación OSD detallada con porcentaje, estado, tiempo estimado restante, salud y consumo en Watts vía `upower`.

### Perfil 2: `jorge-secundaria` (Dual Display + Panel Dañado)
* **Archivo de Configuración:** [hosts/jorge-secundaria/config.json](../hosts/jorge-secundaria/config.json)
* **Altura:** `28px` (compactado para pantallas de resolución 768p).
* **Barra 1 (`HDMI-A-1` / `DP-1` - Monitor Externo Principal):**
  * Incluye la suite completa de telemetría (CPU, RAM, red, bluetooth, mpris, audio, batería, notificaciones y reloj).
  * Workspaces desacoplados mediante `"all-outputs": false` para respetar la partición intercalada de pantallas.
* **Barra 2 (`eDP-1` - Pantalla Compacta de Laptop):**
  * Optimización de espacio horizontal: Omite CPU, memoria, red y bluetooth para no saturar el panel y convivir con la franja de 228px reservada por hardware.
  * Reloj optimizado a 30s sin segundos para eliminar despertares innecesarios del procesador a batería.
  * Centro de notificaciones completo con soporte para DND (`swaync-client -d`) e inhibición de alertas.

### Perfil de Rotación Vertical Dinámica (`config_vertical.json`)
* **Archivo:** [raw_configs/waybar/config_vertical.json](../raw_configs/waybar/config_vertical.json)
* **Activación:** Se activa de forma automática cuando el script [hypr-rotate](../raw_configs/scripts/hypr-rotate) cambia la matriz de pantalla a 90° o 270°.
* **Distribución:** Minimiza el ancho de los módulos utilizando exclusivamente iconografía compacta en red y bluetooth.

### Principio de Invocación Declarativa (`start_waybar.sh`)
El lanzador [raw_configs/hypr/start_waybar.sh](../raw_configs/hypr/start_waybar.sh) respeta de manera prioritaria el archivo `config.json` enlazado por Home Manager para cada máquina. La selección del perfil se rige exclusivamente por la orientación de pantalla detectada mediante `hyprctl monitors -j`, eliminando bypasses frágiles basados en memoria RAM que rompían la paridad multi-monitor.

