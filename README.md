# JorgeDoicela's Nix Flakes & Home Manager Dotfiles (Desktop Infrastructure as Code)

Configuración declarativa modular, ultralimpia y reproducible para Debian + Hyprland, gestionada profesionalmente con **Nix Flakes**, **Home Manager** y conceptos de **Infrastructure as Code (IaC)**.

> **Desktop IaC / Systems Engineering Highlight**: Este repositorio demuestra el control declarativo completo de un entorno de trabajo Linux (*Desktop Infrastructure as Code*), garantizando reproducibilidad total en minutos, cero desvío de configuración (*configuration drift*), inmutabilidad gestionada por el Nix Store y control de versiones profesional.

---

## Arquitectura del Repositorio

```text
dotfiles-nix/
├── flake.nix              # Entrada principal de Nix Flakes (Entorno reproducible)
├── home.nix               # Configuración central de Home Manager (Variables globales, PATH, paquetes base)
├── modules/               # Módulos declarativos organizados por responsabilidad
│   ├── style.nix          # GTK3/GTK4 (WhiteSur-Dark), Qt (Fusion/Qt6ct), Iconos (Tela), Cursores (Bibata) y Fuentes
│   ├── desktop.nix        # Waybar, Rofi, SwayNC, Wlogout, Hyprpaper, Hypridle, Hyprlock, nwg-dock y utilidades
│   ├── apps.nix           # Alacritty, Neovim, Yazi, Sioyek, VS Code, Fastfetch, LSD, Rclone y flags Wayland
│   ├── shell.nix          # Zsh, Starship Prompt, FZF y Git
│   └── scripts.nix        # Ejecutables de usuario (~/.local/bin/hypr-rotate, voxd, sincro, etc.)
├── setup/                 # Aprovisionamiento del sistema base Debian (/etc/, TLP, sysctl, AMDGPU, apt)
└── raw_configs/           # Archivos de configuración fuente (Hyprland, Waybar, Rofi, Wlogout, Scripts)
```

---

## Perfiles Multi-Host Disponibles

Este repositorio implementa una arquitectura **Multi-Host limpia**, soportando diferentes máquinas con configuraciones compartidas:

| Hostname | Perfil Flake | Propósito / Características |
| :--- | :--- | :--- |
| **`jorge-terciaria`** | `.#jorge@jorge-terciaria` | Laptop actual (Panel único `eDP-1`, optimizaciones AMD) |
| **`jorge-secundaria`** | `.#jorge@jorge-secundaria` | Segunda laptop (Configuración de doble pantalla / monitor externo) |
| *(Default)* | `.#jorge` | Alias universal de compatibilidad directa |

---

## Cómo aplicar cambios en tu máquina actual

Si realizas alguna modificación dentro de `~/dotfiles-nix/`, aplica los cambios ejecutando:

```bash
# Aplica automáticamente según el hostname de la máquina
home-manager switch --flake ~/dotfiles-nix

# O especificando el perfil explícito:
home-manager switch --flake ~/dotfiles-nix#jorge@jorge-terciaria
```

---

## Despliegue en una máquina nueva (2 Pasos)

### Paso 1: Configurar Hostname y Aprovisionar Sistema Base (Debian)

1. Establece el nombre de la máquina (por ejemplo, en la segunda laptop):
   ```bash
   sudo hostnamectl set-hostname jorge-secundaria
   sudo sed -i 's/127.0.1.1.*/127.0.1.1\tjorge-secundaria/' /etc/hosts
   ```

2. Clona este repositorio y ejecuta el script de aprovisionamiento de sistema:
   ```bash
   git clone https://github.com/JorgeDoicela/dotfiles-nix.git ~/dotfiles-nix
   sudo bash ~/dotfiles-nix/setup/instalar.sh
   ```

### Paso 2: Restaurar el Entorno de Usuario con Nix

```bash
# 1. Instalar Nix (instalador oficial moderno de Determinate Systems)
sh <(curl -L https://install.determinate.systems/nix) install

# 2. Desplegar tu entorno completo de forma automática según la máquina:
# Para jorge-secundaria:
nix run github:nix-community/home-manager -- switch --flake ~/dotfiles-nix#jorge@jorge-secundaria

# O para jorge-terciaria:
nix run github:nix-community/home-manager -- switch --flake ~/dotfiles-nix#jorge@jorge-terciaria
```

