#!/usr/bin/env bash

# Obtener el PID de hyprlock activo para este usuario
hyprlock_pid=$(pgrep -u "$USER" -x hyprlock | head -n1)

if [ -n "$hyprlock_pid" ]; then
    cache_file="/tmp/hyprlock-splash-${hyprlock_pid}.txt"
else
    cache_file="/tmp/hyprlock-splash-default.txt"
fi

# Si ya existe la frase para esta sesión de bloqueo, la mostramos y salimos
if [ -f "$cache_file" ]; then
    cat "$cache_file"
    exit 0
fi

# Limpiar archivos de caché antiguos de hyprlock para mantener ordenado /tmp
rm -f /tmp/hyprlock-splash-*.txt

# Lista de frases en español para la pantalla de bloqueo
frases=(
    "El único modo de hacer un gran trabajo es amar lo que haces."
    "La simplicidad es la máxima sofisticación."
    "Ningún código es más rápido que el código que no existe."
    "La seguridad no es un producto, es un proceso."
    "Hazlo simple, hazlo memorable."
    "Primero resuelve el problema, después escribe el código."
    "El mejor código es el que no necesita comentarios."
    "La paciencia y la persistencia superan a la inteligencia."
    "La tecnología es mejor cuando une a las personas."
    "El software es una gran combinación entre arte y ciencia."
)

# Seleccionar una frase de forma aleatoria
frase="${frases[RANDOM % ${#frases[@]}]}"

# Guardar en caché para la sesión actual y mostrar
echo "$frase" > "$cache_file"
echo "$frase"
