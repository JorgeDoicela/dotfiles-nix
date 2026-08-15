#!/usr/bin/env bash
# Instala VOXD + ydotool + modelo Whisper small-q8_0 para dictado en español.
# Ejecutar: bash ~/.local/bin/setup-voxd.sh
set -euo pipefail

VOXD_VERSION="1.7.0-1"
VOXD_DEB="/tmp/voxd_${VOXD_VERSION}_amd64.deb"
VOXD_URL="https://github.com/jakovius/voxd/releases/download/v1.7.0/voxd_${VOXD_VERSION}_amd64.deb"
MODEL="small-q8_0"

echo "==> VOXD: dictado por voz local (Whisper.cpp)"
echo "    Sistema: Debian $(. /etc/os-release && echo "$VERSION") | $(nproc) hilos | $(free -h | awk '/^Mem:/{print $2}') RAM"

if [[ ! -f "$VOXD_DEB" ]]; then
  echo "==> Descargando VOXD v${VOXD_VERSION}..."
  curl -L -o "$VOXD_DEB" "$VOXD_URL"
fi

echo "==> Instalando VOXD (requiere sudo)..."
sudo apt update
sudo apt install -y "$VOXD_DEB" ydotool alsa-plugins pavucontrol

sudo modprobe uinput 2>/dev/null || true
if [[ ! -f /etc/modules-load.d/uinput.conf ]]; then
  echo uinput | sudo tee /etc/modules-load.d/uinput.conf >/dev/null
fi
sudo usermod -aG input "$USER" 2>/dev/null || true

if ! command -v ydotoold >/dev/null 2>&1; then
  echo "==> ydotoold no encontrado; compilando ydotool desde fuente..."
  sudo apt install -y git cmake build-essential libevdev-dev libudev-dev libconfig++-dev libboost-program-options-dev
  tmpdir=$(mktemp -d)
  git clone --depth 1 https://github.com/ReimuNotMoe/ydotool.git "$tmpdir/ydotool"
  cmake -S "$tmpdir/ydotool" -B "$tmpdir/ydotool/build"
  cmake --build "$tmpdir/ydotool/build" -j"$(nproc)"
  sudo cmake --install "$tmpdir/ydotool/build"
  rm -rf "$tmpdir"
fi

mkdir -p ~/.config/systemd/user
YDOTOOLD_PATH=$(command -v ydotoold)
cat > ~/.config/systemd/user/ydotoold.service <<EOF
[Unit]
Description=ydotool user daemon
After=default.target

[Service]
ExecStart=${YDOTOOLD_PATH} --socket-path=%h/.ydotool_socket --socket-own=%U:%G
Restart=on-failure

[Install]
WantedBy=default.target
EOF

SOCKET_LINE='export YDOTOOL_SOCKET="$HOME/.ydotool_socket"'
for rcfile in ~/.bashrc ~/.zshrc; do
  if [[ -f "$rcfile" ]] && ! grep -Fq 'YDOTOOL_SOCKET' "$rcfile"; then
    echo "$SOCKET_LINE" >> "$rcfile"
  fi
done
export YDOTOOL_SOCKET="$HOME/.ydotool_socket"

systemctl --user daemon-reload
systemctl --user enable --now ydotoold.service

mkdir -p ~/.config/voxd
cat > ~/.config/voxd/config.yaml <<'YAML'
language: es
typing: true
typing_delay: 1
typing_start_delay: 0.15
append_trailing_space: true
autostart: true
verbosity: false
audio_prefer_pulse: true
audio_input_device: "pulse"
mic_autoset_enabled: true
mic_autoset_level: 0.45
aipp_enabled: false
YAML

echo "==> Configuración inicial de VOXD..."
voxd --setup || true

echo "==> Descargando modelo Whisper '${MODEL}' (~252 MB, multilingüe)..."
voxd-model install "$MODEL"
voxd-model use "$MODEL"

echo "==> Activando autostart (bandeja del sistema)..."
voxd --autostart true

echo ""
echo "=============================================="
echo "  Instalación completada."
echo "=============================================="
echo ""
echo "IMPORTANTE: cierra sesión y vuelve a entrar (o reinicia)"
echo "para que el grupo 'input' y ydotool surtan efecto."
echo ""
echo "Después del reinicio:"
echo "  1. VOXD arrancará solo en la bandeja"
echo "  2. Atajo Hyprland: Super+Shift+V  →  grabar / parar"
echo "  3. Prueba en cualquier editor: atajo → habla → atajo"
