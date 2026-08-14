# ❄️ JorgeDoicela's Nix Flakes & Home Manager Dotfiles

Configuración declarativa modular, ultralimpia y estática para **Debian + Hyprland**, gestionada con **Nix Flakes** y **Home Manager**.

---

## 🏗️ Arquitectura del Repositorio

```text
dotfiles-nix/
├── flake.nix              # Entrada principal de Nix Flakes
├── home.nix               # Configuración central de Home Manager
├── modules/               # Módulos declarativos organizados por tecnología
│   ├── style.nix          # GTK3/GTK4 (Catppuccin Mocha), Qt (Fusion), Iconos (Tela) y Cursores (Bibata)
│   ├── desktop.nix        # Hyprland, Waybar (estilo macOS), Rofi (Catppuccin Mocha) y SwayNC
│   ├── apps.nix           # Alacritty (Tokyo Night), VS Code, Flameshot y LSD
│   ├── shell.nix          # Zsh, Starship Prompt y FZF
│   └── scripts.nix        # Ejecutables de usuario (~/.local/bin)
├── setup/                 # Aprovisionamiento del sistema base Debian (/etc/, TLP, sysctl, AMDGPU)
└── raw_configs/           # Archivos de configuración origen
```

---

## 🛠️ Cómo aplicar cambios en tu máquina actual

Si realizas alguna modificación dentro de `~/dotfiles-nix/`, aplica los cambios ejecutando:

```bash
home-manager switch --flake ~/dotfiles-nix#jorge
```

---

## 🚀 Despliegue en una máquina nueva (2 Pasos)

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
