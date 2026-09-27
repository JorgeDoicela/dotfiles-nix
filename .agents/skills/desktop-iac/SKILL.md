---
name: desktop-iac
description: Guía operativa y flujos de trabajo para administrar este entorno Desktop IaC (Nix Flakes, Home Manager Standalone, perfiles de laptops y módulos). Activa esta skill al modificar configuraciones, agregar hosts o auditar consistencia en dotfiles-nix.
---

# Habilidad Técnica: Operación de Desktop IaC (dotfiles-nix)

Esta skill proporciona las directrices y flujos de trabajo para modificar, depurar y expandir el sistema de gestión declarativa de las laptops de trabajo.

---

## 1. Principio Fundamental: Causa Raíz y Soluciones Profesionales

Ante cualquier fallo reportado en las laptops:
1. **Identificar la Causa Raíz:** No reiniciar servicios en bucle ni forzar sobreescrituras en caliente. Diagnosticar con `journalctl --user`, `hyprctl`, o logs de aplicación.
2. **Cero Parches Silenciosos:** No ocultar advertencias ni parchar temporalmente archivos en `~/.config/`. La corrección debe originarse en la expresión Nix o plantilla de `raw_configs/`.
3. **Idempotencia:** Cualquier cambio en scripts o módulos debe poder aplicarse decenas de veces sin efectos secundarios destructivos.

---

## 2. Flujo de Trabajo para Modificar Módulos

Al realizar cambios en `modules/`:

1. **Localizar la Responsabilidad:**
   * Apariencia, tipografía, cursor, GTK/Qt: [modules/style.nix](../../../modules/style.nix).
   * Servicios de usuario systemd, compositor, barras, OSD: [modules/desktop.nix](../../../modules/desktop.nix).
   * Aplicaciones de usuario, terminal Alacritty, flags de navegador: [modules/apps.nix](../../../modules/apps.nix).
   * Shell Zsh, Git, prompts, FZF: [modules/shell.nix](../../../modules/shell.nix).
   * Scripts de usuario en `~/.local/bin/`: [modules/scripts.nix](../../../modules/scripts.nix).

2. **Validar la Sintaxis del Flake:**
   Siempre antes de aplicar o commitear desde la raíz del repositorio:
   ```bash
   nix flake check .
   ```

3. **Probar el Despliegue Local:**
   ```bash
   home-manager switch --flake .
   ```

---

## 3. Flujo de Trabajo para Nuevas Laptops o Perfiles

Para agregar o modificar un host:

1. **Crear directorio en `hosts/<nombre-host>/`:**
   * `default.nix`: Define los parámetros tipográficos y de escala en `mySystem`, y los enlaces específicos de monitores.
   * `monitors.conf`: Configuración exacta de resolución, tasa de refresco, offsets y `addreserved` si aplica.
   * `config.json`: Perfil de Waybar adaptado a las pantallas del equipo.

2. **Declarar en `flake.nix`:**
   Registrar la salida en `homeConfigurations` importando `home.nix` y el directorio del host.

3. **Verificar Consistencia Multi-Host:**
   Asegurar que los cambios no rompan la evaluación de los otros hosts existentes (`jorge-terciaria` y `jorge-secundaria`).
