#!/usr/bin/env bash
# ==============================================================================
# SELECTOR DINÁMICO DE LIBROS Y ESTUDIO PARA SIOYEK (HYPRLAND / ROFI)
# ==============================================================================
# - Consulta en tiempo real el historial real de lectura de Sioyek (SQLite)
# - Escanea dinámicamente toda la biblioteca (PDF / EPUB) en ~/Documentos
# - Cero listas manuales fijas; actualización automática al añadir libros
# ==============================================================================
set -euo pipefail

# 1. Obtener parámetros de estilo de Hyprland para coherencia visual
hypr_border=$(hyprctl -j getoption decoration:rounding 2>/dev/null | jq -r '.int // 10' 2>/dev/null || echo 10)
hypr_width=$(hyprctl -j getoption general:border_size 2>/dev/null | jq -r '.int // 2' 2>/dev/null || echo 2)
wind_border=$((hypr_border * 3))
[ "$hypr_border" -eq 0 ] && elem_border="10" || elem_border=$((hypr_border * 2))
r_override="window {border: ${hypr_width}px; border-radius: ${wind_border}px;} element {border-radius: ${elem_border}px;}"

# 2. Generar lista dinámica (Recientes + Toda la colección) con Python
python3 - "$r_override" << 'EOF'
import os
import sys
import subprocess
import sqlite3

home = os.path.expanduser("~")
db_local = os.path.join(home, ".local/share/sioyek/local.db")
db_shared = os.path.join(home, ".local/share/sioyek/shared.db")

items = []
seen_paths = set()

# A. Historial dinámico de Sioyek (Libros leídos recientemente)
if os.path.isfile(db_local) and os.path.isfile(db_shared):
    try:
        con = sqlite3.connect(db_local)
        con.execute(f"ATTACH DATABASE \"{db_shared}\" AS shared")
        query = """
        SELECT d.path, s.last_access_time
        FROM document_hash d
        JOIN shared.opened_books s ON d.hash = s.path
        ORDER BY s.last_access_time DESC
        LIMIT 8
        """
        for path, _ in con.execute(query):
            if os.path.isfile(path) and path not in seen_paths:
                title = os.path.splitext(os.path.basename(path))[0]
                items.append((f"🕒 [Reciente]  {title}", path))
                seen_paths.add(path)
    except Exception:
        pass

# B. Escaneo dinámico de la colección completa
search_dirs = [
    os.path.join(home, "Documentos/Libros cristianos"),
    os.path.join(home, "Documentos/Libros"),
]

library = []
for sdir in search_dirs:
    if os.path.isdir(sdir):
        for root, _, files in os.walk(sdir):
            for f in files:
                if f.lower().endswith((".pdf", ".epub")):
                    full_path = os.path.join(root, f)
                    if full_path not in seen_paths:
                        title = os.path.splitext(f)[0]
                        rel_dir = os.path.relpath(root, sdir)
                        tag = f" [{rel_dir}]" if rel_dir != "." else ""
                        library.append((f"📖  {title}{tag}", full_path))
                        seen_paths.add(full_path)

library.sort(key=lambda x: x[0].lower())
items.extend(library)

if not items:
    subprocess.run(["notify-send", "-a", "Biblioteca", "Aviso", "No se encontraron libros en ~/Documentos/Libros*"])
    sys.exit(0)

# C. Construir menú para Rofi
rofi_input = "\n".join(display for display, _ in items)
r_override = sys.argv[1] if len(sys.argv) > 1 else ""

rofi_cmd = [
    "rofi",
    "-dmenu",
    "-i",
    "-format", "i",
    "-p", "󰗚 Biblioteca de Estudio",
    "-theme", os.path.expanduser("~/.config/rofi/config.rasi"),
    "-theme-str", r_override,
    "-theme-str", "window {width: 48em;}",
    "-theme-str", "inputbar entry { placeholder: \"Buscar en toda la biblioteca o recientes...\"; }"
]

proc = subprocess.Popen(rofi_cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
stdout, _ = proc.communicate(input=rofi_input)

if proc.returncode != 0 or not stdout.strip():
    sys.exit(0)

try:
    selected_idx = int(stdout.strip())
    selected_path = items[selected_idx][1]
except (ValueError, IndexError):
    sys.exit(0)

# D. Abrir en Sioyek (o visor del sistema)
sioyek_available = subprocess.run(["which", "sioyek"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0

if sioyek_available:
    subprocess.Popen(["sioyek", selected_path], start_new_session=True)
else:
    subprocess.Popen(["xdg-open", selected_path], start_new_session=True)
EOF
