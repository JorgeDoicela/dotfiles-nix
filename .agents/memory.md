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
  * Workaround físico: La pantalla interna de la laptop tiene una franja rota en su margen izquierdo, compensada mediante directiva de Hyprland: `monitor = eDP-1, addreserved, 0, 0, 228, 0`.
  * Workspaces: Intercalados (eDP-1: 1, 2, 5, 6, 9, 10; HDMI-A-1: 3, 4, 7, 8).
  * Escala: Compacta (9pt GTK/DConf, Waybar 11px, cursor Bibata 20px, browserScale 0.8).

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
