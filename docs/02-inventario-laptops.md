# 02 — Inventario de Laptops y Gestión de Hardware

Este documento especifica los perfiles técnicos de hardware para cada laptop gestionada en el repositorio, sus particularidades físicas y cómo se configuran declarativamente en `hosts/`.

---

## 1. Tabla Comparativa de Parámetros de Hardware

| Parámetro (`mySystem`) | `jorge-terciaria` (Principal) | `jorge-secundaria` (Dual Display) | Explicación Técnica |
| :--- | :--- | :--- | :--- |
| **Rol del Equipo** | Estación móvil primaria | Estación fija / desarrollo con monitor externo | Propósito de despliegue. |
| **Resolución Nativa** | 1920x1080 (1080p) | 1366x768 (768p) | Panel interno de la laptop (`eDP-1`). |
| **`fontSize`** | `11` | `9` | Tamaño de fuente base (GTK, Terminal, DConf). |
| **`cursorSize`** | `24` | `20` | Tamaño de puntero Bibata en Wayland. |
| **`waybarFontSize`** | `13px` | `11px` | Tipografía para barra de estado Waybar. |
| **`rofiFontSize`** | `10` | `8.5` | Tamaño tipográfico del lanzador Rofi. |
| **`rofiWidth` x `rofiHeight`** | `600px` x `350px` | `440px` x `270px` | Ventana de Rofi adaptada a la densidad de pantalla. |
| **`browserScale`** | `1.0` | `0.8` | Factor `--force-device-scale-factor` para Brave/Chromium. |
| **`cursorSensitivity`** | `0.35` | `0.2` (default) | Calibración de aceleración del puntero en Hyprland. |
| **`scrollFactor`** | `0.27` | `0.75` (default) | Sensibilidad de desplazamiento en el touchpad. |

---

## 2. Perfil 1: `jorge-terciaria` (Laptop Principal)

* **Ruta de Configuración:** [hosts/jorge-terciaria/](../hosts/jorge-terciaria/)
* **Esquema de Pantallas:** Panel interno único (`eDP-1`).
* **Archivo de Monitores ([monitors.conf](../hosts/jorge-terciaria/monitors.conf)):**
  ```ini
  monitor = eDP-1, preferred, auto, 1
  monitor = , preferred, auto, 1
  ```
* **Calibración Ergonómica de Touchpad:**
  Para compensar la tasa de sondeo del touchpad de este equipo y brindar una experiencia de navegación ágil y fluida, se ajustaron valores en [default.nix](../hosts/jorge-terciaria/default.nix):
  * `cursorSensitivity = "0.35"`: respuesta ágil sin sobrepasarse en distancias cortas.
  * `scrollFactor = "0.27"`: factor de reducción de inercia de scroll para evitar saltos violentos al leer documentos o navegar la web.
* **Waybar:** [hosts/jorge-terciaria/config.json](../hosts/jorge-terciaria/config.json) con barra horizontal completa a `34px` de altura.

---

## 3. Perfil 2: `jorge-secundaria` (Dual Display + Compensación de Falla)

* **Ruta de Configuración:** [hosts/jorge-secundaria/](../hosts/jorge-secundaria/)
* **Esquema de Pantallas:**
  * **Monitor Externo (`HDMI-A-1` / `DP-1`):** `1366x768@60Hz` posicionado en `0x0` (a la izquierda).
  * **Panel de Laptop (`eDP-1`):** `1366x768@60Hz` posicionado en `1366x0` (a la derecha).

### Quirk de Hardware y Solución de Ingeniería:
La pantalla física de esta laptop presenta una **franja vertical rota / dañada en su lateral izquierdo**. Para rescatar el 100% de la utilidad del panel sin que las ventanas o el contenido queden tapados por los píxeles dañados, se implementó la directiva `addreserved` de Hyprland en [monitors.conf](../hosts/jorge-secundaria/monitors.conf):

```ini
# Margen reservado: 228px en el margen izquierdo de eDP-1
monitor = eDP-1, addreserved, 0, 0, 228, 0
```
*Efecto:* El compositor Wayland reduce el área utilizable del monitor, desplazando el inicio del espacio de trabajo 228 píxeles a la derecha. Ninguna ventana flotante, tiled o barra cubrirá la zona dañada.

### Esquema de Workspaces Intercalados:
Para optimizar el flujo de trabajo entre ambas pantallas:
* **Pantalla de la Laptop (`eDP-1` - Derecha / Principal):** Workspaces `1`, `2`, `5`, `6`, `9`, `10`
* **Monitor Externo (`HDMI-A-1` - Izquierda / Secundario):** Workspaces `3`, `4`, `7`, `8`

---

## 4. Diagnóstico de Monitores y Puertos de Video

Si cambias de monitor externo o necesitas verificar los conectores detectados por el kernel:

```bash
# Listar monitores detectados por Wayland con detalles de resolución, escala y posición
hyprctl monitors

# Salida en formato JSON para inspección con jq
hyprctl monitors -j | jq '.[] | {name: .name, width: .width, height: .height, scale: .scale}'
```
