# 04 — Aprovisionamiento del Sistema Base (Debian)

Este documento detalla los procedimientos de ingeniería de sistemas ejecutados a nivel de sistema operativo (`root` / `/etc/`) mediante el script [setup/instalar.sh](../setup/instalar.sh).

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
* Se restaura el [sources.list](../setup/etc/sources.list) base de Debian Bookworm/Trixie.
* Se mantiene `/etc/apt/sources.list.d/` estrictamente libre de repositorios de terceros para herramientas de desarrollo (las cuales se gestionan mediante Nix).

### 2. Gestión de Energía y Batería con TLP ([setup/etc/tlp.conf](../setup/etc/tlp.conf))
Para maximizar la autonomía de las laptops desconectadas de la corriente:
* Gobernador de CPU configurado en modo dinámico eficiente en batería.
* Autosuspend de puertos USB inactivos.
* Desactivación de ahorro de energía agresivo en Wi-Fi que provoque pérdida de paquetes.
* Integración con `tlp-rdw` para gestión inteligente de radiofrecuencias.

### 3. Arranque Silencioso y Rápido (GRUB, Plymouth y FSCK)
* **GRUB Silencioso ([clean-boot.cfg](../setup/etc/clean-boot.cfg)):** Elimina mensajes ruidosos del kernel durante el POST (`quiet splash loglevel=3 rd.systemd.show_status=auto`).
* **Tema Visual GRUB ([themes/apple-dark/](../setup/themes)):** Interfaz moderna y minimalista estilo macOS.
* **Chequeo de Disco Silencioso ([fsck-silent.conf](../setup/etc/fsck-silent.conf)):** Silencia la salida innecesaria de `systemd-fsck`.

### 4. Hardening y Seguridad del Sistema Operativo
* **Endurecimiento de SSH ([ssh-hardening.conf](../setup/etc/ssh-hardening.conf)):** Restringe protocolos obsoletos, deshabilita autenticación débil y refuerza la configuración de `sshd`.
* **Política Global de Umask (`022`):** Garantiza que los archivos y directorios creados por el sistema no tengan permisos excesivos (`login.defs`).
* **Seguridad de Periféricos Wayland vs Grupo `input`:**
  En sistemas Wayland modernos gobernados por `systemd-logind` y `seatd`, los nodos `/dev/input/*` son asignados dinámicamente a la sesión gráfica activa. **Queda terminantemente prohibido agregar usuarios de forma permanente al grupo secundario `input`**, ya que permitiría a cualquier proceso no privilegiado leer todas las pulsaciones de teclado en segundo plano (vulnerabilidad crítica de keylogging).

### 5. Servicios de Hardware Específicos y Detección Condicional
* **Bluetooth Apagado en Boot:** Modificación de `AutoEnable=false` en `/etc/bluetooth/main.conf` para evitar gasto innecesario de batería al arrancar la laptop.
* **Control de Teclado Dell (Condicional):** El servicio [dell-kbd-backlight-timeout.service](../setup/etc/dell-kbd-backlight-timeout.service) solo se instala y activa si `/sys/class/dmi/id/sys_vendor` detecta hardware de fabricante Dell, garantizando portabilidad limpia en laptops HP, Lenovo u otras marcas.
* **Ahorro de Energía GPU AMD (Condicional):** Los servicios y reglas udev de `amdgpu-powersave` se despliegan exclusivamente si se detecta una controladora VGA/3D de AMD vía `lspci`.

### 6. Estabilidad del Kernel y Aislamiento de Almacenamiento (Swap y Docker)
* **Memoria de Intercambio Defensiva (Swap 8 GB en `/home/swapfile`):** Si el sistema no cuenta con partición swap activa, `instalar.sh` crea y configura de forma idempotente un archivo swap de 8 GB en `/home/swapfile` (aprovechando el espacio mayoritario de `/home`) y lo registra en `/etc/fstab`. Esto elimina los cierres abruptos por el *OOM Killer* del kernel en cargas pesadas de desarrollo o emulación.
* **Desacoplamiento de Docker (`/home/docker`):** Se aprovisiona declarativamente `/etc/docker/daemon.json` fijando `"data-root": "/home/docker"` y limitación de logs JSON a 50 MB (3 archivos rotativos). Esto previene que imágenes, volúmenes y cachés de Docker saturen los ~46 GB de la partición raíz `/`.

### 7. Display Manager y Seguridad PAM (SDDM e Hyprlock)
Para garantizar la autenticación correcta y el bloqueo de pantalla en Wayland:
* **Módulos Qt6 de SDDM:** Se aprovisionan `qml6-module-qtquick-layouts`, `qml6-module-qtquick-controls`, `qml6-module-qtquick-effects`, `qml6-module-qtmultimedia`, `qml6-module-qtquick-virtualkeyboard` y `libqt6svg6`. Estos paquetes son requeridos por las directivas `import` del tema `sddm-astronaut-theme` para evitar que el intérprete QML falle en el arranque.
* **Integración PAM de Hyprlock:** `hyprlock` e `hypridle` se instalan a nivel de sistema (.deb) para proveer el conffile `/etc/pam.d/hyprlock`. Esto garantiza que el desbloqueo de pantalla autentique contra los módulos PAM nativos de Debian sin desajustes de librerías.

### 7. Aprovisionamiento de Aplicaciones Gráficas Aisladas (Flatpak)
Para dotar al sistema de clientes de comunicación y aplicaciones de escritorio de terceros sin generar conflictos de enlaces dinámicos con Mesa/AMDGPU:
* Instalación automatizada del paquete base `flatpak` dentro del lote esencial de Debian.
* Registro criptográfico del repositorio oficial de Flathub (`https://dl.flathub.org/repo/flathub.flatpakrepo`).
* Despliegue desatendido de ZapZap (`com.rtosta.zapzap`) para soporte completo de WhatsApp Web con bandeja de sistema y aceleración de hardware.

### 8. Subsistema de Archivos, VFS y Desacoplamiento FUSE
Para garantizar que el explorador de archivos y las operaciones de entrada/salida no sufran bloqueos síncronos ni congelamiento de la interfaz gráfica GTK:
* **Habilitación de FUSE Multi-usuario (`/etc/fuse.conf`):** Activa de forma idempotente `user_allow_other` para permitir el aislamiento seguro y desacoplamiento de permisos entre demonios VFS de usuario y el kernel.
* **Stack Completo del Explorador Gráfico:** Despliegue automatizado de `thunar`, `thunar-volman` (gestor de volúmenes y dispositivos externos) y `thunar-archive-plugin`.
* **Capa de Abstracción VFS de Usuario:** Instalación de `gvfs-backends` y `gvfs-fuse`. Sin `gvfs-fuse`, el subsistema GIO intenta ejecutar llamadas síncronas bloqueantes de metadatos directamente sobre puntos de montaje FUSE, provocando que el hilo de renderizado de GTK se cuelgue al abrir `$HOME`.
* **Motor de Miniaturas y Previsualizaciones:** Instalación de `tumbler`, `tumbler-plugins-extra` y `ffmpegthumbnailer` para procesamiento eficiente de imágenes y videos locales.

---

## 3. Ejecución del Script de Aprovisionamiento

En una máquina nueva o tras actualizar configuraciones en `setup/etc/` (ejecutado desde la raíz del repositorio):

```bash
sudo bash ./setup/instalar.sh
```
El script reportará cada fase con indicadores legibles y ejecutará `update-grub` y `udevadm control --reload-rules` de forma automática.
