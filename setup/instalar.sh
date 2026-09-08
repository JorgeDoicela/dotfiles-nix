#!/bin/bash
# ==============================================================================
# SCRIPT DE REPLICACIÓN DE CONFIGURACIONES DEL SISTEMA (MIGRACIÓN COMPLETA)
# ==============================================================================
# Ejecuta este script con sudo en la nueva laptop AMD.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "Error: Este script debe ejecutarse con sudo (sudo ./instalar.sh)" >&2
   exit 1
fi

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "jorge")}"

# Función de copia segura con respaldo timestamped (idempotencia y rollback)
safe_copy() {
    local src="$1"
    local dest="$2"
    if [ -f "$dest" ]; then
        cp -a "$dest" "${dest}.bak.$(date +%Y%m%d_%H%M%S)"
    fi
    cp "$src" "$dest"
}

echo "=== INICIANDO INSTALACIÓN DE CONFIGURACIONES DE SISTEMA ==="

# 1. Configurar fuentes de apt y llaves GPG
echo "=> Copiando llaves GPG de seguridad y repositorios..."
mkdir -p /usr/share/keyrings /etc/apt/sources.list.d /etc/apt/preferences.d /etc/apt/apt.conf.d

# Restaurar sources.list base de Debian
safe_copy "$CURRENT_DIR/etc/sources.list" /etc/apt/sources.list

# Copiar llaves GPG locales del sistema (Brave y HashiCorp)
safe_copy "$CURRENT_DIR/keyrings/brave-browser-archive-keyring.gpg" /usr/share/keyrings/brave-browser-archive-keyring.gpg
safe_copy "$CURRENT_DIR/keyrings/hashicorp-archive-keyring.gpg" /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Copiar archivos de repositorios exactos
safe_copy "$CURRENT_DIR/etc/brave-browser-release.list" /etc/apt/sources.list.d/brave-browser-release.list
safe_copy "$CURRENT_DIR/etc/hashicorp.list" /etc/apt/sources.list.d/hashicorp.list

# 2. Copiar archivos de configuración de etc
echo "=> Copiando archivos de optimización y arranque silencioso..."
mkdir -p /etc/sysctl.d /etc/ssh/sshd_config.d /etc/default/grub.d /etc/systemd/system/systemd-fsck@.service.d /etc/systemd/system/systemd-fsck-root.service.d /etc/plymouth /etc/systemd /etc/bluetooth

safe_copy "$CURRENT_DIR/etc/sysctl-optimization.conf" /etc/sysctl.d/99-sysctl-optimization.conf
safe_copy "$CURRENT_DIR/etc/ssh-hardening.conf" /etc/ssh/sshd_config.d/99-hardening.conf
safe_copy "$CURRENT_DIR/etc/clean-boot.cfg" /etc/default/grub.d/99-clean-boot.cfg
safe_copy "$CURRENT_DIR/etc/fsck-silent.conf" /etc/systemd/system/systemd-fsck@.service.d/silent.conf
safe_copy "$CURRENT_DIR/etc/fsck-silent.conf" /etc/systemd/system/systemd-fsck-root.service.d/silent.conf
safe_copy "$CURRENT_DIR/etc/apt-no-recommends.conf" /etc/apt/apt.conf.d/99no-recommends

# Configurar TLP, Plymouth, System.conf y Bluetooth
safe_copy "$CURRENT_DIR/etc/tlp.conf" /etc/tlp.conf
safe_copy "$CURRENT_DIR/etc/plymouthd.conf" /etc/plymouth/plymouthd.conf
safe_copy "$CURRENT_DIR/etc/system.conf" /etc/systemd/system.conf

# Configurar bluetooth: deshabilitar autoenable forzado para respetar la persistencia de estado
if [ -f /etc/bluetooth/main.conf ]; then
    sed -i 's/^AutoEnable=true/AutoEnable=false/' /etc/bluetooth/main.conf
    sed -i 's/^#AutoEnable=false/AutoEnable=false/' /etc/bluetooth/main.conf
fi

# Copiar y habilitar el servicio de retroiluminación de teclado Dell
safe_copy "$CURRENT_DIR/etc/dell-kbd-backlight-timeout.service" /etc/systemd/system/dell-kbd-backlight-timeout.service
systemctl daemon-reload
systemctl enable dell-kbd-backlight-timeout.service || true

# Actualizar arranque (GRUB y Plymouth)
if command -v update-grub &>/dev/null; then
    update-grub
elif command -v grub-mkconfig &>/dev/null; then
    grub-mkconfig -o /boot/grub/grub.cfg
fi


# 3. Replicar control de GPU AMD (Hardware coincidente)
echo "=> Instalando scripts y servicios de control de energía GPU AMD..."
mkdir -p /usr/local/sbin /etc/udev/rules.d /etc/systemd/system

safe_copy "$CURRENT_DIR/amdgpu/amdgpu-powersave" /usr/local/sbin/amdgpu-powersave
chmod +x /usr/local/sbin/amdgpu-powersave

safe_copy "$CURRENT_DIR/amdgpu/amdgpu-performance" /usr/local/sbin/amdgpu-performance
chmod +x /usr/local/sbin/amdgpu-performance

safe_copy "$CURRENT_DIR/amdgpu/amdgpu-powersave.service" /etc/systemd/system/amdgpu-powersave.service
safe_copy "$CURRENT_DIR/amdgpu/91-amdgpu-powersave.rules" /etc/udev/rules.d/91-amdgpu-powersave.rules

systemctl enable amdgpu-powersave.service
udevadm control --reload-rules


# 4. Seguridad de dispositivos de entrada (Principio de mínimo privilegio)
# En Wayland moderno con systemd-logind / seatd, el acceso a /dev/input/* es asignado
# de forma dinámica y segura a la sesión activa. Queda terminantemente prohibido
# agregar usuarios al grupo 'input' por riesgo crítico de keylogging local sin privilegios.

# 5. Permisos profesionales estándar (umask 022 a nivel de sistema)
echo "=> Configurando umask 022 profesional a nivel de sistema..."
if grep -q "^UMASK" /etc/login.defs; then
    sed -i 's/^UMASK.*/UMASK\t\t022/' /etc/login.defs
else
    sed -i 's/^USERGROUPS_ENAB yes/USERGROUPS_ENAB yes\nUMASK\t\t022/' /etc/login.defs
fi

# 6. Actualizar repositorios e instalar paquetes base de Debian (Kernel/Drivers/Hyprland)
echo "=> Actualizando fuentes de apt e instalando paquetes base del sistema..."
apt-get update
apt-get install -y --no-install-recommends \
    curl \
    git \
    hyprland \
    hyprland-guiutils \
    hyprpolkitagent \
    xdg-desktop-portal-hyprland \
    mesa-vulkan-drivers \
    libgl1-mesa-dri \
    hyprpaper \
    hyprlock \
    hypridle \
    pipewire \
    wireplumber \
    pipewire-audio \
    pipewire-pulse \
    tlp \
    tlp-rdw \
    plymouth \
    plymouth-themes \
    brave-browser || true

echo "=== MIGRACIÓN Y RÉPLICA COMPLETADA CON ÉXITO ==="
echo "Ahora instala Nix y ejecuta Home Manager para restaurar todo el entorno de usuario:"
echo "  1. sh <(curl -L https://install.determinate.systems/nix) install"
echo "  2. nix run github:nix-community/home-manager -- switch --flake ~/dotfiles-nix#jorge"

