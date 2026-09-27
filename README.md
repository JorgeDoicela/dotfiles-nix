# JorgeDoicela's Nix Flakes & Home Manager Dotfiles (Desktop Infrastructure as Code)

Configuración declarativa modular, ultralimpia y reproducible para Debian + Hyprland, gestionada profesionalmente con **Nix Flakes**, **Home Manager** y conceptos de **Infrastructure as Code (IaC)**.

> **Desktop IaC / Systems Engineering Highlight**: Este repositorio demuestra el control declarativo completo de un entorno de trabajo Linux (*Desktop Infrastructure as Code*), garantizando reproducibilidad total en minutos, cero desvío de configuración (*configuration drift*), inmutabilidad gestionada por el Nix Store y control de versiones profesional.

---

## Arquitectura del Repositorio

```text
dotfiles-nix/
├── flake.nix              # Entrada principal de Nix Flakes (Entorno reproducible)
├── home.nix               # Configuración central de Home Manager (Variables globales, PATH, paquetes base)
├── docs/                  # Manual técnico y operativo completo (Runbooks, hardware, arquitectura)
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

## Documentación Técnica (`docs/`)

La documentación detallada de arquitectura, hardware y procedimientos operativos se organiza en módulos independientes dentro de `docs/`:

| Documento | Descripción |
| :--- | :--- |
| **[01. Arquitectura del Sistema](docs/01-arquitectura-sistema.md)** | Desktop IaC, Flakes, Home Manager Standalone y modelo híbrido con Debian. |
| **[02. Inventario de Laptops](docs/02-inventario-laptops.md)** | Perfiles de hardware (`jorge-terciaria` y `jorge-secundaria`), resoluciones y workaround de pantalla dañada. |
| **[03. Diseño y Escalado](docs/03-diseno-y-escalado.md)** | Sistema `mySystem`, solución al escalado fraccional en Wayland y propagación tipográfica. |
| **[04. Aprovisionamiento Base](docs/04-provisionamiento-base.md)** | Setup de Debian (`setup/instalar.sh`), TLP para batería, GRUB silencioso, llaves GPG y hardening. |
| **[05. Gestión de GPU AMD](docs/05-gestion-gpu-amdgpu.md)** | Control dinámico de energía en sysfs DRM (`low` vs `auto`), udev, systemd y atajos. |
| **[06. Ecosistema de Scripts](docs/06-ecosistema-scripts.md)** | Stack de dictado por voz (VOXD/Whisper), sincro Rclone, rotación de pantalla y utilidades. |
| **[07. Runbooks Operativos](docs/07-runbooks-operaciones.md)** | Despliegue en laptops nuevas, sincronización GitOps, creación de nuevos hosts y recolección de basura. |
| **[08. Referencia de Atajos](docs/08-referencia-atajos.md)** | Catálogo completo y categorizado de keybindings de Hyprland (ventanas, medios, brillo, captura, etc.). |

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

