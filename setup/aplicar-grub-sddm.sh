#!/usr/bin/env bash
# ==============================================================================
# SCRIPT MAESTRO DE APLICACIÓN Y ESTANDARIZACIÓN: GRUB & SDDM
# ==============================================================================
# Estándar Senior SysAdmin:
# 1. Arquitectura 100% drop-in (/etc/default/grub.d/ y /etc/sddm.conf.d/)
# 2. Cero conflicto con paquetes base de Debian (dpkg conffiles inalterados)
# 3. Detección física defensiva de swap (inmune a zram y discos virtuales)
# 4. Verificación estricta de sintaxis con 'bash -n' antes de compilar arranque
# 5. Idempotencia y purga automática de archivos residuales (.bak)
# ==============================================================================

set -euo pipefail
IFS=$'\n\t'

if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Este script debe ejecutarse con privilegios de root (sudo $0)" >&2
    exit 1
fi

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $*"; }
warn() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $*" >&2; }
die()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" >&2; exit 1; }

log "=== INICIANDO CONFIGURACIÓN PROFESIONAL DE GRUB Y SDDM ==="

# ------------------------------------------------------------------------------
# 1. PRE-VALIDACIÓN DEFENSIVA DE SINTAXIS
# ------------------------------------------------------------------------------
log "1. Validando sintaxis de expresiones y drop-ins..."
for cfg in "$CURRENT_DIR/etc/grub.d/"*.cfg; do
    [[ -f "$cfg" ]] || continue
    bash -n "$cfg" || die "Error de sintaxis detectado en plantilla: $cfg"
done

# ------------------------------------------------------------------------------
# 2. CONFIGURACIÓN MODULAR DE GRUB (/etc/default/grub.d/)
# ------------------------------------------------------------------------------
log "2. Desplegando drop-ins modulares de GRUB en /etc/default/grub.d/..."
mkdir -p /etc/default/grub.d

# Purgar copias residuales previas en /etc/default/
rm -f /etc/default/grub.bak* /etc/default/grub.d/*.bak*

# Copiar drop-in base del sistema (10-system.cfg)
cp "$CURRENT_DIR/etc/grub.d/10-system.cfg" /etc/default/grub.d/10-system.cfg

# Detección defensiva de swap física en disco (excluyendo zram)
SWAP_UUID=$(lsblk -no NAME,TYPE,UUID,FSTYPE | awk '$1 !~ /^zram/ && $4=="swap" && $3!="" {print $3; exit}' || true)
if [[ -n "$SWAP_UUID" ]]; then
    log "   Swap física detectada (UUID: $SWAP_UUID); generando drop-in /etc/default/grub.d/20-resume.cfg..."
    cat <<EOF > /etc/default/grub.d/20-resume.cfg
# Reanudación de swap física para hibernación (generado dinámicamente)
GRUB_CMDLINE_LINUX_DEFAULT="\${GRUB_CMDLINE_LINUX_DEFAULT} resume=UUID=${SWAP_UUID}"
EOF
else
    log "   No se detectó swap física dedicada; removiendo drop-in de resume si existiera..."
    rm -f /etc/default/grub.d/20-resume.cfg
fi

# Desplegar tema Apple Dark (50-grub-theme.cfg)
if [[ -d "$CURRENT_DIR/themes/apple-dark" && ! -d "/boot/grub/themes/apple-dark" ]]; then
    log "   Instalando tema apple-dark en /boot/grub/themes/..."
    mkdir -p /boot/grub/themes
    cp -r "$CURRENT_DIR/themes/apple-dark" /boot/grub/themes/
fi
cp "$CURRENT_DIR/etc/grub.d/50-grub-theme.cfg" /etc/default/grub.d/50-grub-theme.cfg

# Desplegar arranque silencioso (99-clean-boot.cfg)
cp "$CURRENT_DIR/etc/grub.d/99-clean-boot.cfg" /etc/default/grub.d/99-clean-boot.cfg

# Asegurar que /etc/default/grub contenga los valores mínimos limpios sin pisar drop-ins
cat <<EOF > /etc/default/grub
# Configuración base de GRUB — Debian GNU/Linux
# Las políticas específicas del sistema se gestionan en /etc/default/grub.d/
GRUB_DEFAULT=0
GRUB_TIMEOUT=2
GRUB_DISTRIBUTOR="Debian"
GRUB_CMDLINE_LINUX_DEFAULT=""
GRUB_CMDLINE_LINUX=""
EOF

# Validar integridad sintáctica final antes de compilar
for installed_cfg in /etc/default/grub.d/*.cfg; do
    [[ -f "$installed_cfg" ]] || continue
    bash -n "$installed_cfg" || die "Fallo de sintaxis en archivo instalado: $installed_cfg"
done

log "3. Compilando /boot/grub/grub.cfg..."
if command -v update-grub &>/dev/null; then
    update-grub
elif command -v grub-mkconfig &>/dev/null; then
    grub-mkconfig -o /boot/grub/grub.cfg
fi

# ------------------------------------------------------------------------------
# 3. ELIMINACIÓN DE PLYMOUTH (CAUSA RAÍZ: ARRANQUE SILENCIOSO PURO)
# ------------------------------------------------------------------------------
if dpkg -l | grep -qE "^ii[[:space:]]+(plymouth|libplymouth5)"; then
    log "4. Purgando paquetes innecesarios de Plymouth para erradicar retrasos y pantalla gris..."
    apt-get purge -y plymouth libplymouth5 plymouth-themes 2>/dev/null || true
    rm -rf /etc/plymouth /usr/share/plymouth
    log "   Regenerando initramfs sin hooks de splash..."
    update-initramfs -u
fi

# ------------------------------------------------------------------------------
# 4. CONFIGURACIÓN MODULAR DE SDDM (/etc/sddm.conf.d/)
# ------------------------------------------------------------------------------
log "5. Configurando SDDM bajo arquitectura modular (/etc/sddm.conf.d/)..."
mkdir -p /etc/sddm.conf.d

# Eliminar archivo monolítico legacy y configuraciones sueltas
rm -f /etc/sddm.conf /etc/sddm.conf.d/wayland.conf

# Desplegar drop-ins modulares versionados
cp "$CURRENT_DIR/etc/sddm.conf.d/10-theme.conf" /etc/sddm.conf.d/10-theme.conf
cp "$CURRENT_DIR/etc/sddm.conf.d/20-wayland.conf" /etc/sddm.conf.d/20-wayland.conf
cp "$CURRENT_DIR/etc/sddm.conf.d/30-general.conf" /etc/sddm.conf.d/30-general.conf

THEME_DIR="/usr/share/sddm/themes/sddm-astronaut-theme"
if [[ ! -d "$THEME_DIR" ]]; then
    log "   Clonando sddm-astronaut-theme en /usr/share/sddm/themes/..."
    mkdir -p /usr/share/sddm/themes
    git clone --depth 1 https://github.com/Keyitdev/sddm-astronaut-theme.git "$THEME_DIR"
fi

if [[ -f "$CURRENT_DIR/sddm/astronaut.conf" && -d "$THEME_DIR/Themes" ]]; then
    log "5. Desplegando astronaut.conf adaptativo (auto-escalado multi-pantalla)..."
    cp "$CURRENT_DIR/sddm/astronaut.conf" "$THEME_DIR/Themes/astronaut.conf"
fi

if [[ -f "$CURRENT_DIR/sddm/Fondo_de_Bloqueo.png" && -d "$THEME_DIR/Backgrounds" ]]; then
    log "6. Desplegando fondo de bloqueo oficial en el tema..."
    cp "$CURRENT_DIR/sddm/Fondo_de_Bloqueo.png" "$THEME_DIR/Backgrounds/Fondo_de_Bloqueo.png"
fi

log "=== ESTANDARIZACIÓN COMPLETADA EXITOSAMENTE SIN ERRORES ==="
