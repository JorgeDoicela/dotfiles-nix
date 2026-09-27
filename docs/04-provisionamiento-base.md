# 04 — Aprovisionamiento del Sistema Base (Debian)

Este documento detalla los procedimientos de ingeniería de sistemas ejecutados a nivel de sistema operativo (`root` / `/etc/`) mediante el script [setup/instalar.sh](file:///home/jorge/dotfiles-nix/setup/instalar.sh).

---

## 1. Filosofía de Aprovisionamiento e Idempotencia

El script está diseñado para ejecutarse múltiples veces de forma segura sin provocar corrupción de configuraciones existentes:

* **Modo Estricto:** Ejecutado bajo `set -euo pipefail`.
* **Respaldos Automáticos Timestamped (`safe_copy`):**
  ```bash
  safe_copy() {
      local src="$1"
      local dest="$2"
      if [ -f "$dest" ]; then
          cp -a "$dest" "${dest}.bak.$(date +%Y%m%d_%H%M%S)"
      fi
      cp "$src" "$dest"
  }
  ```
  Antes de sobreescribir cualquier archivo crítico en `/etc/`, genera una copia de respaldo con fecha y hora exacta para garantizar capacidades inmediatas de rollback.

---

## 2. Componentes y Configuraciones Desplegadas

### 1. Repositorios de Paquetes y Llaves GPG Seguras
* Se configuran las llaves en `/usr/share/keyrings/` (estándar moderno de Debian, descartando `apt-key` deprecado):
  * Llave oficial de Brave Browser: `brave-browser-archive-keyring.gpg`.
  * Llave oficial de HashiCorp: `hashicorp-archive-keyring.gpg`.
* Se restaura el [sources.list](file:///home/jorge/dotfiles-nix/setup/etc/sources.list) base de Debian Bookworm/Trixie.

### 2. Gestión de Energía y Batería con TLP ([setup/etc/tlp.conf](file:///home/jorge/dotfiles-nix/setup/etc/tlp.conf))
Para maximizar la autonomía de las laptops desconectadas de la corriente:
* Gobernador de CPU configurado en modo dinámico eficiente en batería.
* Autosuspend de puertos USB inactivos.
* Desactivación de ahorro de energía agresivo en Wi-Fi que provoque pérdida de paquetes.
* Integración con `tlp-rdw` para gestión inteligente de radiofrecuencias.

### 3. Arranque Silencioso y Rápido (GRUB, Plymouth y FSCK)
* **GRUB Silencioso ([clean-boot.cfg](file:///home/jorge/dotfiles-nix/setup/etc/clean-boot.cfg)):** Elimina mensajes ruidosos del kernel durante el POST (`quiet splash loglevel=3 rd.systemd.show_status=auto`).
* **Tema Visual GRUB ([themes/apple-dark/](file:///home/jorge/dotfiles-nix/setup/themes)):** Interfaz moderna y minimalista estilo macOS.
* **Chequeo de Disco Silencioso ([fsck-silent.conf](file:///home/jorge/dotfiles-nix/setup/etc/fsck-silent.conf)):** Silencia la salida innecesaria de `systemd-fsck`.

### 4. Hardening y Seguridad del Sistema Operativo
* **Endurecimiento de SSH ([ssh-hardening.conf](file:///home/jorge/dotfiles-nix/setup/etc/ssh-hardening.conf)):** Restringe protocolos obsoletos, deshabilita autenticación débil y refuerza la configuración de `sshd`.
* **Política Global de Umask (`022`):** Garantiza que los archivos y directorios creados por el sistema no tengan permisos excesivos (`login.defs`).
* **Seguridad de Periféricos Wayland vs Grupo `input`:**
  En sistemas Wayland modernos gobernados por `systemd-logind` y `seatd`, los nodos `/dev/input/*` son asignados dinámicamente a la sesión gráfica activa. **Queda terminantemente prohibido agregar usuarios de forma permanente al grupo secundario `input`**, ya que permitiría a cualquier proceso no privilegiado leer todas las pulsaciones de teclado en segundo plano (vulnerabilidad crítica de keylogging).

### 5. Servicios de Hardware Específicos
* **Bluetooth Apagado en Boot:** Modificación de `AutoEnable=false` en `/etc/bluetooth/main.conf` para evitar gasto innecesario de batería al arrancar la laptop.
* **Control de Teclado Dell:** Servicio [dell-kbd-backlight-timeout.service](file:///home/jorge/dotfiles-nix/setup/etc/dell-kbd-backlight-timeout.service) para gestionar el tiempo de apagado de los LEDs del teclado.

---

## 3. Ejecución del Script de Aprovisionamiento

En una máquina nueva o tras actualizar configuraciones en `setup/etc/`:

```bash
sudo bash ~/dotfiles-nix/setup/instalar.sh
```
El script reportará cada fase con indicadores legibles y ejecutará `update-grub` y `udevadm control --reload-rules` de forma automática.
