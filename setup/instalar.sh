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
CURRENT_USER=$(logname || echo "jorge")

echo "=== INICIANDO INSTALACIÓN DE CONFIGURACIONES DE SISTEMA ==="

# 1. Configurar fuentes de apt y llaves GPG
echo "=> Copiando llaves GPG de seguridad y repositorios..."
mkdir -p /usr/share/keyrings /etc/apt/sources.list.d /etc/apt/preferences.d /etc/apt/apt.conf.d

# Restaurar sources.list base de Debian
cp "$CURRENT_DIR/etc/sources.list" /etc/apt/sources.list

# Copiar llaves GPG locales
cp "$CURRENT_DIR/keyrings/brave-browser-archive-keyring.gpg" /usr/share/keyrings/brave-browser-archive-keyring.gpg
cp "$CURRENT_DIR/keyrings/nodesource.gpg" /usr/share/keyrings/nodesource.gpg
cp "$CURRENT_DIR/keyrings/hashicorp-archive-keyring.gpg" /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Copiar archivos de repositorios exactos
cp "$CURRENT_DIR/etc/brave-browser-release.list" /etc/apt/sources.list.d/brave-browser-release.list
cp "$CURRENT_DIR/etc/nodesource.sources" /etc/apt/sources.list.d/nodesource.sources
cp "$CURRENT_DIR/etc/hashicorp.list" /etc/apt/sources.list.d/hashicorp.list


# 2. Copiar archivos de configuración de etc
echo "=> Copiando archivos de optimización y arranque silencioso..."
mkdir -p /etc/sysctl.d /etc/ssh/sshd_config.d /etc/default/grub.d /etc/systemd/system/systemd-fsck@.service.d /etc/systemd/system/systemd-fsck-root.service.d /etc/plymouth /etc/systemd /etc/bluetooth

cp "$CURRENT_DIR/etc/sysctl-optimization.conf" /etc/sysctl.d/99-sysctl-optimization.conf
cp "$CURRENT_DIR/etc/ssh-hardening.conf" /etc/ssh/sshd_config.d/99-hardening.conf
cp "$CURRENT_DIR/etc/clean-boot.cfg" /etc/default/grub.d/99-clean-boot.cfg
cp "$CURRENT_DIR/etc/fsck-silent.conf" /etc/systemd/system/systemd-fsck@.service.d/silent.conf
cp "$CURRENT_DIR/etc/fsck-silent.conf" /etc/systemd/system/systemd-fsck-root.service.d/silent.conf
cp "$CURRENT_DIR/etc/apt-nodejs.pref" /etc/apt/preferences.d/nodejs
cp "$CURRENT_DIR/etc/apt-no-recommends.conf" /etc/apt/apt.conf.d/99no-recommends

# Configurar TLP, Plymouth, System.conf y Bluetooth
cp "$CURRENT_DIR/etc/tlp.conf" /etc/tlp.conf
cp "$CURRENT_DIR/etc/plymouthd.conf" /etc/plymouth/plymouthd.conf
cp "$CURRENT_DIR/etc/system.conf" /etc/systemd/system.conf

# Configurar bluetooth autoenable
if [ -f /etc/bluetooth/main.conf ]; then
    sed -i 's/^#AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf
    sed -i 's/^AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf
fi

# Copiar y habilitar el servicio de retroiluminación de teclado Dell
cp "$CURRENT_DIR/etc/dell-kbd-backlight-timeout.service" /etc/systemd/system/dell-kbd-backlight-timeout.service
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

cp "$CURRENT_DIR/amdgpu/amdgpu-powersave" /usr/local/sbin/amdgpu-powersave
chmod +x /usr/local/sbin/amdgpu-powersave

cp "$CURRENT_DIR/amdgpu/amdgpu-performance" /usr/local/sbin/amdgpu-performance
chmod +x /usr/local/sbin/amdgpu-performance

cp "$CURRENT_DIR/amdgpu/amdgpu-powersave.service" /etc/systemd/system/amdgpu-powersave.service
cp "$CURRENT_DIR/amdgpu/91-amdgpu-powersave.rules" /etc/udev/rules.d/91-amdgpu-powersave.rules

systemctl enable amdgpu-powersave.service
udevadm control --reload-rules


# 4. Asegurar grupo de entrada para Hyprland
usermod -aG input "$CURRENT_USER"

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

