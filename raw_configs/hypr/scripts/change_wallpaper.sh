#!/usr/bin/env bash

# Directorio de fondos y enlace simbólico
WALLPAPER_DIR="$HOME/Imágenes/Fondos"
SYM_LINK="$HOME/.config/hypr/wallpaper_real.png"

# Comprobar que el directorio existe
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Fondo de Pantalla" "El directorio $WALLPAPER_DIR no existe." -i dialog-error
    exit 1
fi

# Obtener lista de imágenes en el directorio
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | sort)

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    notify-send "Fondo de Pantalla" "No se encontraron imágenes en $WALLPAPER_DIR." -i dialog-error
    exit 1
fi

# Obtener la ruta real del fondo actual
CURRENT_WALLPAPER=""
if [ -L "$SYM_LINK" ]; then
    CURRENT_WALLPAPER=$(readlink -f "$SYM_LINK")
elif [ -f "$SYM_LINK" ]; then
    # Si es un archivo físico, se respalda para evitar pérdida de datos
    mv "$SYM_LINK" "$SYM_LINK.bak"
fi

# Determinar el siguiente fondo
NEXT_WALLPAPER="${WALLPAPERS[0]}"
if [ -n "$CURRENT_WALLPAPER" ]; then
    for i in "${!WALLPAPERS[@]}"; do
        if [ "${WALLPAPERS[i]}" = "$CURRENT_WALLPAPER" ]; then
            NEXT_INDEX=$(( (i + 1) % ${#WALLPAPERS[@]} ))
            NEXT_WALLPAPER="${WALLPAPERS[NEXT_INDEX]}"
            break
        fi
    done
fi

# Crear/actualizar el enlace simbólico
ln -sf "$NEXT_WALLPAPER" "$SYM_LINK"

# Reiniciar hyprpaper para aplicar los cambios de inmediato
killall hyprpaper 2>/dev/null
hyprpaper >/dev/null 2>&1 &

# Notificar el cambio
WALLPAPER_NAME=$(basename "$NEXT_WALLPAPER")
notify-send "Fondo de Pantalla" "Cambiado a: $WALLPAPER_NAME" -i dialog-information
