# 05 — Gestión y Optimización de GPU AMD (AMDGPU)

Este documento describe la arquitectura de control de energía para gráficos integrados y dedicados AMD Radeon implementada en [setup/amdgpu/](file:///home/jorge/dotfiles-nix/setup/amdgpu/).

---

## 1. Subsistema DRM y Control DPM de AMD

El controlador de kernel `amdgpu` expone interfaces de administración dinámica de energía (DPM - *Dynamic Power Management*) a través del pseudofilesystem `sysfs`:

```text
/sys/class/drm/card*/device/power_dpm_force_performance_level
```

### Niveles de Rendimiento Soportados:
1. **`low` (Modo Bajo Consumo / Powersave):**
   * Fuerza el reloj del motor gráfico (sclk) y de la memoria de video (mclk) a sus frecuencias mínimas operativas.
   * **Beneficios:** Reduce drásticamente la temperatura térmica del chasis de la laptop, silencia los ventiladores y alarga la duración de la batería durante tareas de ofimática, navegación web y lectura de PDFs.
2. **`auto` (Modo Rendimiento Dinámico / Performance):**
   * El controlador ajusta dinámicamente las frecuencias entre los estados de reloj según la demanda de cómputo gráfico o aceleración 3D/Vulkan.

---

## 2. Implementación de Scripts y Servicios

### 1. Script de Bajo Consumo ([setup/amdgpu/amdgpu-powersave](file:///home/jorge/dotfiles-nix/setup/amdgpu/amdgpu-powersave))
Descubre automáticamente la tarjeta gráfica activa sin importar si se asignó a `card0`, `card1` o variantes dinámicas:
```bash
for card in /sys/class/drm/card*/device; do
    if [ -f "$card/power_dpm_force_performance_level" ]; then
        echo "low" > "$card/power_dpm_force_performance_level" 2>/dev/null || true
        echo "AMD GPU configurada en bajo consumo (low)"
        exit 0
    fi
done
```

### 2. Script de Rendimiento ([setup/amdgpu/amdgpu-performance](file:///home/jorge/dotfiles-nix/setup/amdgpu/amdgpu-performance))
Restaura el comportamiento dinámico (`auto`) para tareas de alta carga gráfica.

### 3. Servicio Systemd y Regla Udev
* **Servicio ([amdgpu-powersave.service](file:///home/jorge/dotfiles-nix/setup/amdgpu/amdgpu-powersave.service)):** Se ejecuta al inicio del sistema para arrancar la laptop en estado frío y de bajo consumo por defecto.
* **Regla Udev ([91-amdgpu-powersave.rules](file:///home/jorge/dotfiles-nix/setup/amdgpu/91-amdgpu-powersave.rules)):** Aplica la política energética ante eventos de conexión en caliente o reanudación tras suspensión.

---

## 3. Integración con Hyprland y Atajos de Teclado

Los scripts están integrados en [modules/scripts.nix](file:///home/jorge/dotfiles-nix/modules/scripts.nix) y mapeados con notificaciones OSD nativas en [keybindings.conf](file:///home/jorge/dotfiles-nix/raw_configs/hypr/keybindings.conf):

| Atajo de Teclado | Acción | Notificación en Pantalla |
| :--- | :--- | :--- |
| `Super + Ctrl + Alt + G` | Activa modo rendimiento (`auto`) | "GPU: Modo Rendimiento Activado" |
| `Super + Ctrl + Alt + P` | Activa modo ahorro (`low`) | "GPU: Modo Ahorro Activado" |

---

## 4. Comandos de Diagnóstico y Verificación

Para consultar el estado actual del reloj y nivel de energía de la GPU desde la terminal:

```bash
# Consultar el nivel de rendimiento forzado actual:
cat /sys/class/drm/card*/device/power_dpm_force_performance_level

# Consultar el reloj de la GPU (sclk) y ver cuál nivel está activo (marcado con *):
cat /sys/class/drm/card*/device/pp_dpm_sclk
```
