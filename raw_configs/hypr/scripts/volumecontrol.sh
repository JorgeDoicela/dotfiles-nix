#!/usr/bin/env bash
# Script autónomo e independiente para controlar el volumen en Hyprland (Debian/Pipewire)

# Valores por defecto
step=${VOLUME_STEPS:-5}
isNotify=true

# Mostrar ayuda
print_usage() {
    cat << EOF
Uso: $(basename "$0") -[device] <action> [step]
Aparato:
    -o    Salida de audio (Altavoces)
    -i    Entrada de audio (Micrófono)
Acciones:
    i     Subir volumen
    d     Bajar volumen
    m     Alternar silencio (mute)
    q     Modo silencioso (sin notificaciones)
EOF
    exit 1
}

# Obtener volumen y estado de silencio (Salida)
get_output_status() {
    local info
    info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    vol=$(echo "$info" | awk '{print int($2 * 100)}')
    if echo "$info" | grep -q "MUTED"; then
        mute="true"
    else
        mute="false"
    fi
}

# Obtener volumen y estado de silencio (Micrófono)
get_input_status() {
    local info
    info=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)
    vol=$(echo "$info" | awk '{print int($2 * 100)}')
    if echo "$info" | grep -q "MUTED"; then
        mute="true"
    else
        mute="false"
    fi
}

# Notificación de volumen
notify_vol() {
    [ "$isNotify" = "false" ] && return
    local appName="Sistema"
    local icon="audio-volume-medium"
    local bar=""
    
    if [ "$device" = "mic" ]; then
        appName="Micrófono"
        if [ "$mute" = "true" ]; then
            icon="microphone-sensitivity-muted"
            notify-send -a "$appName" -r 8 -t 1500 -i "$icon" "Micrófono Silenciado"
        else
            icon="microphone-sensitivity-high"
            bar=$(seq -s "■" $((vol / 10)) 2>/dev/null | sed 's/[0-9]//g')
            notify-send -a "$appName" -r 8 -t 1500 -i "$icon" "$vol%  $bar"
        fi
    else
        appName="Volumen"
        if [ "$mute" = "true" ]; then
            icon="audio-volume-muted"
            notify-send -a "$appName" -r 8 -t 1500 -i "$icon" "Silenciado"
        else
            if [ "$vol" -lt 30 ]; then
                icon="audio-volume-low"
            elif [ "$vol" -lt 70 ]; then
                icon="audio-volume-medium"
            else
                icon="audio-volume-high"
            fi
            bar=$(seq -s "■" $((vol / 10)) 2>/dev/null | sed 's/[0-9]//g')
            notify-send -a "$appName" -r 8 -t 1500 -i "$icon" "$vol%  $bar"
        fi
    fi
}

# Procesar opciones
while getopts "ioq" opt; do
    case $opt in
        i) device="mic" ;;
        o) device="speaker" ;;
        q) isNotify=false ;;
        *) print_usage ;;
    esac
done
shift $((OPTIND - 1))

[ -z "$device" ] && print_usage

action="$1"
step="${2:-$step}"

if [ "$device" = "speaker" ]; then
    case "$action" in
        i)
            wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$step%+"
            get_output_status
            notify_vol
            ;;
        d)
            wpctl set-volume @DEFAULT_AUDIO_SINK@ "$step%-"
            get_output_status
            notify_vol
            ;;
        m)
            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
            get_output_status
            notify_vol
            ;;
        *) print_usage ;;
    esac
elif [ "$device" = "mic" ]; then
    case "$action" in
        i)
            wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SOURCE@ "$step%+"
            get_input_status
            notify_vol
            ;;
        d)
            wpctl set-volume @DEFAULT_AUDIO_SOURCE@ "$step%-"
            get_input_status
            notify_vol
            ;;
        m)
            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
            get_input_status
            notify_vol
            ;;
        *) print_usage ;;
    esac
fi
