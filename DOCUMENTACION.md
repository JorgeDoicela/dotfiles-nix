# Guía y Documentación de Arquitectura — Desktop Infrastructure as Code (IaC)

Este documento detalla la arquitectura, estándares de ingeniería, diseño modular y procedimientos operativos del entorno de trabajo declarativo gestionado con **Nix Flakes** y **Home Manager**.

---

## 1. Filosofía y Principios de Diseño

El sistema está concebido bajo el paradigma de **Desktop Infrastructure as Code (Desktop IaC)** y **GitOps**, aplicando las mejores prácticas de ingeniería de sistemas:

1. **Inmutabilidad y Cero Desvío de Configuración (*Zero Drift*):**
   * Toda la configuración del entorno de usuario (Wayland, Hyprland, Waybar, temas GTK/Qt, terminal, fuentes y variables de entorno) reside en el **Nix Store** (`/nix/store/`) en modo de solo lectura.
   * Se eliminan las modificaciones manuales no registradas: cualquier cambio en el sistema debe realizarse en el código fuente de este repositorio y aplicarse mediante `home-manager switch`.

2. **Principio DRY (*Don't Repeat Yourself*) y Cero Código Duplicado:**
   * Las definiciones comunes (temas, cursores, keybindings, utilidades base, servicios) viven en módulos globales centralizados dentro de `modules/`.
   * Los hosts individuales (`hosts/jorge-secundaria`, `hosts/jorge-terciaria`) **nunca duplican archivos de configuración enteros**; únicamente declaran sus variables de hardware y escala de interfaz.

3. **Independencia Multi-Host y Desacoplamiento de Hardware:**
   * Cada máquina física tiene un perfil aislado que gestiona sus peculiaridades de hardware (número de monitores, resolución, orientación, posiciones X/Y y márgenes de pantalla).
   * Los cambios aplicados a una máquina no alteran ni degradan la experiencia en las demás.

---

## 2. Estructura del Repositorio

```text
dotfiles-nix/
├── flake.nix                  # Entrada principal de Nix Flakes (Evaluación declarativa y definición de hosts)
├── flake.lock                 # Bloqueo estricto de dependencias y versiones de nixpkgs/home-manager
├── home.nix                   # Núcleo de Home Manager: variables de sesión, PATH y paquetes base
├── DOCUMENTACION.md           # Manual técnico de arquitectura y operaciones (este archivo)
├── README.md                  # Resumen rápido y comandos de despliegue
├── modules/                   # Módulos declarativos globales (Lógica compartida)
│   ├── style.nix              # Sistema de diseño: temas GTK/Qt, cursor Bibata, iconos Tela y opciones mySystem
│   ├── desktop.nix            # Hyprland, Waybar dinámica, SwayNC, Rofi, Wlogout y utilidades de escritorio
│   ├── apps.nix               # Alacritty declarativo, Neovim, Fastfetch, Yazi, VS Code y flags Wayland
│   ├── shell.nix              # Zsh, Starship Prompt, FZF y Git
│   └── scripts.nix            # Scripts de usuario en ~/.local/bin/ (sincronización, atajos, etc.)
├── hosts/                     # Perfiles específicos por máquina física
│   ├── jorge-secundaria/      # Host secundario (Pantalla 1366x768 + Monitor externo + Escala compacta)
│   │   ├── default.nix        # Parámetros mySystem (fontSize = 9) y enlaces de monitor
│   │   ├── monitors.conf      # Configuración de doble display y margen de pantalla rota (addreserved 223px)
│   │   └── config.json        # Configuración de Waybar adaptada a 2 monitores (altura 28px)
│   └── jorge-terciaria/       # Host principal/terciario (Pantalla única + Escala estándar 11pt / 13px / 34px)
│       ├── default.nix        # Declaración estándar heredando valores base
│       ├── monitors.conf      # Configuración para monitor único
│       └── config.json        # Configuración de Waybar para monitor único
├── raw_configs/               # Archivos fuente base y temas visuales
│   ├── hypr/                  # Configuraciones base de Hyprland, keybindings y scripts
│   ├── waybar/                # Estilo base style.css, tema theme.css y presets
│   ├── rofi/                  # Temas y estilos del lanzador Rofi
│   └── ...                    # Otras configuraciones crudas compartidas
└── setup/                     # Scripts de aprovisionamiento del sistema base Debian (/etc/, TLP, AMDGPU)
```

---

## 3. Sistema de Parametrización Declarativa (`mySystem`)

Para evitar tener que duplicar archivos cuando diferentes máquinas requieren tamaños de interfaz distintos (por ejemplo, una pantalla de 1366x768 vs una de 1080p), se implementó un sistema de opciones nativo en Nix en `modules/style.nix`:

### Declaración de Opciones (`modules/style.nix`):
```nix
options.mySystem = {
  fontSize = lib.mkOption {
    type = lib.types.number;
    default = 11;
    description = "Tamaño base de tipografía del sistema (GTK, Terminal, DConf)";
  };
  waybarFontSize = lib.mkOption {
    type = lib.types.str;
    default = "13px";
    description = "Tamaño tipográfico para Waybar";
  };
};
```

### Cómo se propaga a las aplicaciones:

1. **GTK3 y GTK4:**
   ```nix
   gtk.font = {
     name = "JetBrainsMono Nerd Font";
     size = config.mySystem.fontSize;
   };
   ```
2. **DConf / GNOME / Portales XDG:**
   ```nix
   dconf.settings."org/gnome/desktop/interface" = {
     document-font-name = "JetBrainsMono Nerd Font ${toString config.mySystem.fontSize}";
     monospace-font-name = "JetBrainsMono Nerd Font ${toString config.mySystem.fontSize}";
   };
   ```
3. **X11 / XWayland (`xsettingsd`):**
   ```nix
   xdg.configFile."xsettingsd/xsettingsd.conf".text = ''
     Gtk/FontName "JetBrainsMono Nerd Font ${toString config.mySystem.fontSize}"
     ...
   '';
   ```
4. **Terminal Alacritty (`modules/apps.nix`):**
   ```nix
   programs.alacritty.settings = {
     font.size = config.mySystem.fontSize;
     window.padding = {
       x = if config.mySystem.fontSize < 10 then 10 else 14;
       y = if config.mySystem.fontSize < 10 then 10 else 14;
     };
     ...
   };
   ```
5. **Waybar CSS Dinámico (`modules/desktop.nix`):**
   ```nix
   xdg.configFile."waybar/style.css".text =
     builtins.replaceStrings [ "font-size: 13px;" ] [ "font-size: ${config.mySystem.waybarFontSize};" ]
       (builtins.readFile ../raw_configs/waybar/style.css);
   ```

---

## 4. Gestión de Pantallas y Monitores

### Por qué usar Escala Nativa 1.0 vs Escalado Fraccional (<1.0)
* **Limitación del escalado fraccional:** En Wayland (backend Aquamarine de Hyprland), establecer escalas menores a 1 (`scale = 0.8`) provoca advertencias del compositor, cuantización obligatoria a `2/3` (0.67) y pérdida de nitidez tipográfica por remuestreo de píxeles.
* **Solución profesional adoptada:** Mantener la **escala nativa en 1.0** y compactar los tamaños de fuente (`fontSize = 9`), paddings y altura de barras (`28px`). Esto entrega la misma densidad visual de un panel 1080p sin distorsión gráfica.

### Configuración de `jorge-secundaria` (`hosts/jorge-secundaria/monitors.conf`):
* **Monitor Externo (HDMI-A-1):** `1366x768@60` en posición `0x0` (Izquierda), asignado a Workspaces 1 al 5.
* **Pantalla de Laptop (eDP-1):** `1366x768@60` en posición `1366x0` (Derecha), asignada a Workspaces 6 al 10.
* **Margen para Pantalla Dañada:**
  ```ini
  monitor = eDP-1, addreserved, 0, 0, 223, 0
  ```
  Reserva 223 píxeles en el borde izquierdo de la pantalla de la laptop para evitar que ventanas y elementos se ubiquen sobre la zona dañada.

---

## 5. Guía de Operaciones y Procedimientos

### 1. Aplicar cambios en la máquina local
Tras editar cualquier archivo del repositorio:
```bash
home-manager switch --flake ~/dotfiles-nix
```
*Home Manager detecta automáticamente el hostname actual (`jorge-secundaria` o `jorge-terciaria`) y aplica el perfil correspondiente.*

### 2. Validar la sintaxis de todos los hosts antes de hacer commit
```bash
nix flake check ~/dotfiles-nix
```

### 3. Crear un nuevo Host / Máquina
Si en el futuro agregas una tercera máquina (ej. `jorge-desktop`):
1. Crea la carpeta `hosts/jorge-desktop/` con sus respectivos `default.nix`, `monitors.conf` y `config.json`.
2. En `flake.nix`, registra la nueva salida dentro de `homeConfigurations`:
   ```nix
   "jorge@jorge-desktop" = home-manager.lib.homeManagerConfiguration {
     inherit pkgs;
     modules = [
       ./home.nix
       ./hosts/jorge-desktop
     ];
   };
   ```
3. En la nueva máquina, establece el hostname:
   ```bash
   sudo hostnamectl set-hostname jorge-desktop
   ```
4. Despliega con:
   ```bash
   home-manager switch --flake ~/dotfiles-nix#jorge@jorge-desktop
   ```

### 4. Flujo de GitOps recomendado
1. Modifica tus archivos en `~/dotfiles-nix/`.
2. Prueba y valida localmente con `home-manager switch --flake ~/dotfiles-nix`.
3. Haz commit con mensajes descriptivos en español:
   ```bash
   git add .
   git commit -m "feat(modulo): descripcion clara del cambio"
   git push origin main
   ```
4. En las otras máquinas, simplemente sincroniza:
   ```bash
   git pull origin main
   home-manager switch --flake ~/dotfiles-nix
   ```

---

## 6. Mantenimiento y Buenas Prácticas

* **Limpieza de generaciones antiguas:**
  Para liberar espacio de generaciones previas de Home Manager en el Nix Store:
  ```bash
  nix-collect-garbage -d
  ```
* **Nunca editar archivos en `~/.config/` manualmente:**
  La mayoría de los archivos en `~/.config/` son enlaces de solo lectura hacia `/nix/store/`. Las modificaciones manuales se perderán en el siguiente `switch`. Siempre edita dentro de `~/dotfiles-nix/`.

---

## 7. Compatibilidad Multi-Distribución (Debian y Arch Linux — Non-NixOS)

Este repositorio está diseñado para operar en modo **Standalone Home Manager** sobre distribuciones tradicionales como **Debian GNU/Linux** y **Arch Linux**, no sobre NixOS.

### Separación de Responsabilidades (*Separation of Concerns*):

1. **Capa del Sistema Operativo Base (Debian `apt` / Arch `pacman`):**
   * **Controladores Gráficos y Kernel:** Mesa, Vulkan, ACO, DRM y drivers de GPU (AMD Radeon / Intel / Nvidia).
   * **Compositor y Binarios Gráficos Críticos:** Hyprland, Alacritty, Brave, VS Code.
   * *Razón técnica:* Al ser instalados por la distribución base, estos ejecutables se enlazan de forma 100% nativa con las librerías dinámicas de OpenGL/EGL del sistema operativo (`radeonsi_dri.so`), garantizando aceleración por hardware completa, fluidez máxima y cero errores de *display handle* en Wayland.

2. **Capa Declarativa de Home Manager (Nix Flakes):**
   * **Herramientas CLI y Desarrollo:** Neovim, Yazi, Fastfetch, LSD, Rclone, JQ, Socat.
   * **Entorno Visual de Escritorio:** Waybar, Rofi, SwayNC, Wlogout, Hyprlock, Grim, Slurp, Swappy.
   * **Activos de Diseño:** Temas GTK (WhiteSur-Dark), Iconos (Tela-circle-dracula), Cursores (Bibata-Modern-Ice), Fuentes (JetBrainsMono Nerd Font).
   * **Gestión Inmutable de Dotfiles:** Todos los archivos de configuración (`~/.config/alacritty/alacritty.toml`, `~/.config/hypr/`, `~/.config/waybar/`, `~/.config/Code/User/settings.json`, variables de sesión de Wayland y atajos de teclado).

### Procedimiento de Instalación en Arch Linux:

Si en el futuro despliegas en una máquina con **Arch Linux**:
1. Instala los paquetes base del sistema con Pacman:
   ```bash
   sudo pacman -S hyprland alacritty waybar rofi-wayland git base-devel mesa vulkan-radeon
   ```
2. Instala Nix en modo multi-usuario:
   ```bash
   sh <(curl -L https://install.determinate.systems/nix) install
   ```
3. Clona tu repositorio y despliega tu perfil:
   ```bash
   git clone https://github.com/JorgeDoicela/dotfiles-nix.git ~/dotfiles-nix
   nix run github:nix-community/home-manager -- switch --flake ~/dotfiles-nix#jorge@<tu-host>
   ```
Nix generará automáticamente todo tu entorno con tus temas, escalas y atajos sin importar si estás en Debian o en Arch Linux.

