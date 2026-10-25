# JorgeDoicela's Nix Flakes & Home Manager Dotfiles (Desktop Infrastructure as Code)

Configuración declarativa modular, ultralimpia y reproducible para Debian + Hyprland, gestionada profesionalmente con **Nix Flakes**, **Home Manager** y principios de **Desktop Infrastructure as Code (Desktop IaC)**.

> **Desktop IaC / Systems Engineering Highlight**: Este repositorio demuestra el control declarativo completo de un entorno de trabajo Linux, garantizando reproducibilidad total en minutos, cero desvío de configuración (*configuration drift*), inmutabilidad gobernada por el Nix Store, auto-descubrimiento de máquinas y validación continua mediante CI.

---

## 1. Arquitectura del Repositorio

```text
dotfiles-nix/
├── flake.nix              # Entrada principal de Nix Flakes (Auto-descubrimiento dinámico de hosts)
├── flake.lock             # Bloqueo criptográfico inmutable de dependencias (Nixpkgs / Home Manager)
├── home.nix               # Configuración central de Home Manager (Variables globales, PATH, paquetes base)
├── switch                 # Wrapper operativo ejecutable con validación de host y auto-fallback
├── .github/               # Integración continua
│   └── workflows/ci.yml   # Pipeline de GitHub Actions (nix flake check en cada commit/PR)
├── docs/                  # Biblioteca técnica modular Docs-as-Code (00- a 09-)
│   ├── 00-indice-general.md
│   ├── 01-arquitectura-sistema.md
│   ├── ...
├── hosts/                 # Perfiles de hardware por máquina (Auto-descubiertos)
│   ├── jorge-terciaria/   # Laptop principal (Panel 1080p nativo, optimización AMD)
│   │   ├── default.nix    # Calibración mySystem y enlace de monitores
│   │   └── monitors.conf
│   └── jorge-secundaria/  # Laptop auxiliar (Dual display 768p + compensación de franja rota)
│       ├── default.nix    # Calibración compacta, 2 barras Waybar declarativas
│       └── monitors.conf
├── modules/               # Módulos declarativos de Home Manager
│   ├── style.nix          # Opciones tipadas mySystem, temas GTK/Qt, cursores Bibata y fuentes
│   ├── desktop.nix        # Waybar centralizado declarativo, Rofi, SwayNC, SwayOSD, Wlogout y sesión
│   ├── apps.nix           # Terminal Alacritty, Neovim, Yazi, Node.js 22, pnpm, Sioyek, Typst y FUSE
│   ├── shell.nix          # Zsh, Starship Prompt, FZF monocromático, Git y GitHub CLI
│   └── scripts.nix        # Wrappers e inyección declarativa de scripts a ~/.local/bin/
├── setup/                 # Aprovisionamiento del sistema base Debian (/etc/, TLP, sysctl, SDDM, GRUB)
│   ├── instalar.sh        # Script maestro idempotente con detección condicional de hardware y swap
│   ├── aplicar-grub-sddm.sh # Configuración modular de arranque silencioso y display manager
│   ├── etc/               # Drop-ins modulares para /etc/ (Docker daemon, sysctl, SSH, TLP)
│   └── amdgpu/            # Scripts y reglas udev para control dinámico de energía de GPU AMD
└── raw_configs/           # Fuentes de configuración estática y plantillas con inyección de tokens
```

---

## 2. Documentación Técnica Exhaustiva (`docs/`)

La biblioteca documental sigue el estándar **Docs-as-Code** con taxonomía numérica jerárquica. Consulta el catálogo maestro en:

👉 **[Catálogo Maestro de Documentación Técnica](docs/00-indice-general.md)**

| Módulo | Documento | Dominio de Ingeniería |
| :---: | :--- | :--- |
| `01` | **[Arquitectura del Sistema](docs/01-arquitectura-sistema.md)** | Modelo híbrido en 3 capas, hermetismo Flakes, auto-descubrimiento y VFS. |
| `02` | **[Inventario de Laptops](docs/02-inventario-laptops.md)** | Especificaciones de hardware, esquemas de monitores y calibración. |
| `03` | **[Diseño y Escalado](docs/03-diseno-y-escalado.md)** | Submódulo tipado `mySystem`, escalado Wayland 1.0 y Waybar declarativo. |
| `04` | **[Aprovisionamiento Base](docs/04-provisionamiento-base.md)** | Setup de Debian (`setup/instalar.sh`), Swap 8 GB, Docker en `/home` y TLP. |
| `05` | **[Gestión de GPU AMD](docs/05-gestion-gpu-amdgpu.md)** | Control DPM en sysfs (`low` vs `auto`), udev, systemd y atajos. |
| `06` | **[Ecosistema de Scripts](docs/06-ecosistema-scripts.md)** | Stack de dictado por voz (VOXD/Whisper), sincro Rclone y wrapper `./switch`. |
| `07` | **[Runbooks Operativos](docs/07-runbooks-operaciones.md)** | Manuales SOP para nuevas laptops, sincronización GitOps y ciclo de parches. |
| `08` | **[Referencia de Atajos](docs/08-referencia-atajos.md)** | Catálogo completo y categorizado de keybindings de Hyprland. |
| `09` | **[Pipeline Académico](docs/09-pipeline-documental-academico.md)** | Modelo bicanal (rubric-driven APA 7 y Typst para ingeniería) y sincronización UBE. |

---

## 3. Perfiles Multi-Host Disponibles

Este repositorio implementa un motor de **auto-descubrimiento dinámico**: cualquier subdirectorio en `hosts/` que contenga un archivo `default.nix` se compila automáticamente como un target `jorge@<hostname>` sin requerir modificaciones en `flake.nix`.

| Hostname | Perfil Flake | Propósito y Particularidades de Hardware |
| :--- | :--- | :--- |
| **`jorge-terciaria`** | `.#jorge@jorge-terciaria` | Laptop principal (Panel 1080p nativo `eDP-1`, touchpad ágil, barra de estado única de 26px). |
| **`jorge-secundaria`** | `.#jorge@jorge-secundaria` | Laptop auxiliar / estación de trabajo (Dual Display 768p, 2 barras Waybar y margen reservado de 228px por franja rota en `eDP-1`). |
| *(Default)* | `.#jorge` | Alias de compatibilidad directa hacia el perfil estándar. |

---

## 4. Gestión Rápida: Aplicar Cambios

Para aplicar cambios localmente en la máquina activa, utiliza el script wrapper operativo:

```bash
# Detecta automáticamente el hostname local, valida el perfil y aplica el Flake
./switch

# O invocando un perfil específico si deseas probar configuraciones cruzadas:
./switch jorge@jorge-terciaria
```

---

## 5. Despliegue en una Nueva Laptop (2 Pasos)

### Paso 1: Configurar Hostname y Aprovisionar Sistema Base (Debian)

1. Asigna el nombre de la máquina correspondiente a su perfil en `hosts/`:
   ```bash
   sudo hostnamectl set-hostname jorge-secundaria
   sudo sed -i 's/127.0.1.1.*/127.0.1.1\tjorge-secundaria/' /etc/hosts
   ```

2. Clona este repositorio y ejecuta el aprovisionamiento del sistema operativo:
   ```bash
   DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles-nix}"
   git clone https://github.com/JorgeDoicela/dotfiles-nix.git "$DOTFILES_DIR"
   cd "$DOTFILES_DIR"
   sudo bash ./setup/instalar.sh
   ```
   *Este script aprovisiona automáticamente de forma idempotente: repositorios oficiales, llaves GPG de Brave, swapfile defensivo de 8 GB en `/home/swapfile`, `data-root` de Docker en `/home/docker`, servicios de hardware condicionales (Dell/AMD), TLP para batería, GRUB silencioso y temas de SDDM.*

### Paso 2: Desplegar el Entorno Declarativo con Nix

```bash
# 1. Instalar Nix (instalador oficial moderno de Determinate Systems)
sh <(curl -L https://install.determinate.systems/nix) install

# 2. Desplegar el entorno de usuario completo:
cd ~/dotfiles-nix
./switch
```

El script `./switch` detectará automáticamente que `home-manager` aún no está presente en el `PATH` y lo invocará mediante `nix run` para realizar el bootstrapping sin requerir comandos manuales complejos.
