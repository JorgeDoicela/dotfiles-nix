#!/usr/bin/env bash
pkill -x rofi && exit

SCRIPTS_DIR="$HOME/.config/hypr/scripts"
keyconfDir="$HOME/.config/hypr"
kb_hint_conf=("$keyconfDir/hyprland.conf" "$keyconfDir/keybindings.conf" "$keyconfDir/userprefs.conf")

kb_cache="/tmp/keybinds_hint.rofi"

# Función local para obtener la fuente de Hyprland si es posible
get_hyprConf() {
    hyprctl -j getoption "$1" 2>/dev/null | jq -r '.str' | sed 's/ /\\ /g'
}

[ -f "$kb_cache" ] && {
    trap 'python3 "$SCRIPTS_DIR/keybinds/hint-hyprland.py" --format rofi > "$kb_cache" && echo "Keybind cache updated" ' EXIT
}

output="$(if ! cat "$kb_cache" 2> /dev/null; then
    python3 "$SCRIPTS_DIR/keybinds/hint-hyprland.py" --format rofi | tee "$kb_cache"
fi)"

wait

if [ -z "$output" ]; then
    notify-send "Keybind Hint" "Initialization failed."
    exit 0
fi

if ! command -v rofi &> /dev/null; then
    echo "$output"
    echo "rofi not detected. Displaying on terminal instead"
    exit 0
fi

hypr_border=$(hyprctl -j getoption decoration:rounding | jq '.int')
hypr_width=$(hyprctl -j getoption general:border_size | jq '.int')
wind_border=$((hypr_border * 3 / 2))
elem_border=$([ "$hypr_border" -eq 0 ] && echo "5" || echo "$hypr_border")

kb_hint_width="$ROFI_KEYBIND_HINT_WIDTH"
kb_hint_height="$ROFI_KEYBIND_HINT_HEIGHT"
kb_hint_line="$ROFI_KEYBIND_HINT_LINE"

r_width="width: ${kb_hint_width:-35em};"
r_height="height: ${kb_hint_height:-35em};"
r_listview="listview { lines: ${kb_hint_line:-13}; }"
r_override="window {$r_height $r_width border: ${hypr_width}px; border-radius: ${wind_border}px;} entry {border-radius: ${elem_border}px;} element {border-radius: ${elem_border}px;} $r_listview "

font_scale="${ROFI_KEYBIND_HINT_SCALE:-$(gsettings get org.gnome.desktop.interface font-name 2>/dev/null | awk '{gsub(/'\''/,""); print $NF}')}"
[[ $font_scale =~ ^[0-9]+$ ]] || font_scale=10
font_name=${ROFI_KEYBIND_HINT_FONT:-$ROFI_FONT}
font_name=${font_name:-$(get_hyprConf "MENU_FONT")}
font_name=${font_name:-$(get_hyprConf "FONT")}
font_override="* {font: \"${font_name:-"JetBrainsMono Nerd Font"} ${font_scale:-10}\";}"

selected=$(echo -e "$output" | rofi -dmenu -p \
    -theme-str "entry { placeholder: \"\t⌨️ Keybindings \";}" \
    " Keybinds \t\tﴕ Description" \
    -p -i \
    -display-columns 1 \
    -display-column-separator ":::" \
    -theme-str "$font_override" \
    -theme-str "$r_override" \
    -theme "~/.config/rofi/config.rasi" | sed 's/.*\s*//')

if [ -z "$selected" ]; then exit 0; fi

dispatch=$(awk -F ':::' '{print $2}' <<< "$selected" | xargs)
arg=$(awk -F ':::' '{print $3}' <<< "$selected" | xargs)
repeat=$(awk -F ':::' '{print $4}' <<< "$selected" | xargs)

RUN() {
    case "$(eval "hyprctl dispatch '$dispatch' '$arg'")" in *"Not enough arguments"*) exec $0 ;; esac
}

if [ -n "$dispatch" ] && [ "$(echo "$dispatch" | wc -l)" -eq 1 ]; then
    if [ "$repeat" = repeat ]; then
        while true; do
            repeat_command=$(echo -e "Repeat" | rofi -dmenu -no-custom -p - "[Enter] repeat; [ESC] exit" -theme "notification")
            if [ "$repeat_command" = "Repeat" ]; then
                RUN
            else
                exit 0
            fi
        done
    else
        RUN
    fi
else
    exec $0
fi
