# 08 — Catálogo de Referencia de Atajos de Teclado (Hyprland)

Este catálogo resume todos los atajos de teclado configurados en [raw_configs/hypr/keybindings.conf](../raw_configs/hypr/keybindings.conf).

> **Nota:** La tecla `Super` (`$mainMod`) corresponde a la tecla Windows / Meta del teclado.

---

## 1. Aplicaciones Principales y Lanzadores

| Atajo | Acción / Aplicación |
| :--- | :--- |
| `Super + Return` | Terminal Alacritty |
| `Super + B` | Navegador web Brave |
| `Super + C` | Editor de código (Antigravity / VS Code) |
| `Super + E` | Explorador de archivos terminal Yazi |
| `Super + Shift + E` | Explorador de archivos gráfico Thunar |
| `Ctrl + Shift + Esc` | Monitor del sistema interactivo (Btop) |
| `Super + Space` | Lanzador de aplicaciones (Rofi Drun) |
| `Super + Tab` | Selector de ventanas abiertas (Rofi Window) |
| `Alt + Tab` | Selector visual estilo Windows (**Hyprshell**) |
| `Super + V` | Historial del portapapeles (Cliphist + Rofi) |
| `Super + Shift + V` | Limpiar historial del portapapeles |
| `Super + H` | Guía de atajos en pantalla |

---

## 2. Gestión y Navegación de Ventanas

| Atajo | Acción |
| :--- | :--- |
| `Super + Q` | Cerrar ventana activa |
| `Super + Shift + Space` | Alternar ventana flotante / tiled |
| `Super + F` | Alternar pantalla completa (*Fullscreen*) |
| `Super + Shift + F` | Fijar ventana activa en todos los espacios (*Pin*) |
| `Super + G` | Alternar agrupación de ventanas (*Togglegroup*) |
| `Super + J` | Alternar división de mosaico (*Togglesplit*) |
| `Super + Flechas` | Cambiar foco entre ventanas (Izquierda, Derecha, Arriba, Abajo) |
| `Super + Shift + Flechas` | Redimensionar ventana activa |
| `Super + Ctrl + Shift + Flechas` | Mover ventana dentro del espacio de trabajo |
| `Super + Botón Izquierdo Ratón` | Arrastrar / mover ventana flotante |
| `Super + Botón Derecho Ratón` | Redimensionar ventana con el ratón |

---

## 3. Disposición Rápida en Mosaico (*Window Mosaic*)

| Atajo | Posición / Cuadrante |
| :--- | :--- |
| `Super + Alt + 1` | Mitad izquierda |
| `Super + Alt + 2` | Mitad derecha |
| `Super + Alt + 3` | Mitad superior |
| `Super + Alt + 4` | Mitad inferior |
| `Super + Alt + 5` | Esquina inferior derecha |
| `Super + Alt + 0` | Centrado en pantalla |
| `Super + Alt + T` | Alternar modo mosaico |
| `Super + Alt + Flechas` | Desplazar ventana flotante en saltos de 80px |

---

## 4. Productividad, Estudio y Hardware Personalizado

| Atajo | Acción / Herramienta |
| :--- | :--- |
| `Super + D` | **Dictado por voz offline** (VOXD + Whisper) |
| `Super + L` | **Buscador de libros de estudio** (Rofi + Sioyek) |
| `Alt + R` o `AltGr + R` | **Rotar pantalla de la laptop** (0° / 90° / 270°) |
| `Super + Shift + N` | Activar / Desactivar filtro de luz azul (Wlsunset) |
| `Super + Shift + B` | Ocultar / Mostrar barra superior Waybar |
| `Super + N` | Abrir / Cerrar centro de notificaciones (SwayNC) |
| `Super + Ctrl + Alt + G` | Forzar **Modo Rendimiento GPU AMD** |
| `Super + Ctrl + Alt + P` | Forzar **Modo Bajo Consumo GPU AMD** |

---

## 5. Capturas de Pantalla (Grim + Slurp + Swappy)

| Atajo | Modo de Captura | Destino |
| :--- | :--- | :--- |
| `Print` | Selección de área | Abre editor y anotador interactivo **Swappy** |
| `Super + Shift + S` | Selección de área | **Copia ultrarrápida al portapapeles** (sin GUI) |
| `Shift + Print` | Selección de área | Copia rápida al portapapeles |
| `Ctrl + Print` | Selección de área | Guarda archivo PNG directamente en disco |
| `Super + Print` | Ventana activa | Copia directa al portapapeles |
| `Super + Shift + Print` | Pantalla completa | Guarda archivo PNG en disco |
| `Super + Shift + P` | Selector de color en pantalla | Copia código HEX al portapapeles |

---

## 6. Control de Hardware y Multimedia (SwayOSD)

| Tecla / Atajo | Función |
| :--- | :--- |
| `XF86AudioMute` | Silenciar / Activar altavoces con OSD |
| `XF86AudioMicMute` | Silenciar / Activar micrófono con OSD |
| `XF86AudioRaiseVolume` | Subir volumen con OSD |
| `XF86AudioLowerVolume` | Bajar volumen con OSD |
| `XF86MonBrightnessUp` | Subir brillo de pantalla con OSD |
| `XF86MonBrightnessDown` | Bajar brillo de pantalla con OSD |
| `XF86AudioPlay` / `Pause` | Reproducir / Pausar medios (Playerctl) |
| `XF86AudioNext` / `Prev` | Siguiente / Anterior pista |
| `Caps_Lock` / `Num_Lock` | Indicador visual de estado de bloqueo en pantalla |

---

## 7. Espacios de Trabajo (*Workspaces*) y Sesión

| Atajo | Acción |
| :--- | :--- |
| `Super + [1..9, 0]` | Ir al espacio de trabajo correspondiente (1 al 10) |
| `Super + Shift + [1..9, 0]` | Mover ventana activa al espacio seleccionado |
| `Super + Ctrl + [1..9, 0]` | Mover ventana al espacio en silencio (*Silent*) |
| `Super + Ctrl + Flecha Der/Izq` | Ir al espacio siguiente / anterior |
| `Super + Ctrl + Flecha Abajo` | Ir al espacio vacío más cercano |
| `Super + Minus (-)` | Alternar espacio de trabajo especial (*Scratchpad*) |
| `Super + Shift + Minus (-)` | Enviar ventana activa al scratchpad |
| `Super + Shift + L` | Bloquear pantalla de inmediato (**Hyprlock**) |
| `Ctrl + Alt + Del` | Menú interactivo de apagado / reinicio (**Wlogout**) |
| `Super + Delete` | Salir de la sesión gráfica de Hyprland |
