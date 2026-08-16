# JorgeDoicela's Nix Flakes & Home Manager Dotfiles (Desktop Infrastructure as Code)

Configuración declarativa modular, ultralimpia y reproducible para Debian + Hyprland, gestionada profesionalmente con **Nix Flakes**, **Home Manager** y conceptos de **Infrastructure as Code (IaC)**.

> **Desktop IaC / Systems Engineering Highlight**: Este repositorio demuestra el control declarativo completo de un entorno de trabajo Linux (*Desktop Infrastructure as Code*), garantizando reproducibilidad total en minutos, cero desvío de configuración (*configuration drift*), inmutabilidad gestionada por el Nix Store y control de versiones profesional.

---

## Arquitectura del Repositorio

```text
dotfiles-nix/
├── flake.nix              # Entrada principal de Nix Flakes (Entorno reproducible)
├── home.nix               # Configuración central de Home Manager
├── modules/               # Módulos declarativos organizados por responsabilidad
│   ├── style.nix          # GTK3/GTK4 (Catppuccin Mocha), Qt (Fusion), Iconos (Tela) y Cursores (Bibata)
│   ├── desktop.nix        # Hyprland, Waybar (estilo macOS), Rofi (Catppuccin Mocha) y SwayNC
│   ├── apps.nix           # Alacritty (Tokyo Night), VS Code, Flameshot y LSD
│   ├── shell.nix          # Zsh, Starship Prompt y FZF
│   └── scripts.nix        # Ejecutables de usuario (~/.local/bin/hypr-rotate, voxd, etc.)
├── setup/                 # Aprovisionamiento del sistema base Debian (/etc/, TLP, sysctl, AMDGPU)
└── raw_configs/           # Archivos de configuración fuente (Hyprland, Scripts, Rofi, Waybar)
```

---

## Cómo aplicar cambios en tu máquina actual

Si realizas alguna modificación dentro de `~/dotfiles-nix/`, aplica los cambios ejecutando:

```bash
home-manager switch --flake ~/dotfiles-nix#jorge
```

---

## Despliegue en una máquina nueva (2 Pasos)

### 1. Aprovisionar el Sistema Base (Debian)
Clona este repositorio y ejecuta el script de aprovisionamiento de sistema:
```bash
sudo bash ~/dotfiles-nix/setup/instalar.sh
```

### 2. Restaurar el Entorno de Usuario con Nix
```bash
# 1. Instalar Nix (si no está instalado)
sh <(curl -L https://install.determinate.systems/nix) install

# 2. Desplegar tu entorno completo de forma automática
nix run github:nix-community/home-manager -- switch --flake github:JorgeDoicela/dotfiles-nix#jorge
```
