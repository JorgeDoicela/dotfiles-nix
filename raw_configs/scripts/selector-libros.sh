#!/usr/bin/env python3
# ==============================================================================
# SELECTOR DINÁMICO DE LIBROS Y ESTUDIO PARA SIOYEK (HYPRLAND / ROFI)
# ==============================================================================
# - Interfaz Fullscreen con pestañas superiores generadas DINÁMICAMENTE
# - Cada subcarpeta detectada en disco se convierte automáticamente en una pestaña
# - Filtrado y búsqueda instantánea sin mezclar categorías
# ==============================================================================
import os
import sys
import shutil
import sqlite3
import subprocess

home = os.path.expanduser("~")
db_local = os.path.join(home, ".local/share/sioyek/local.db")
db_shared = os.path.join(home, ".local/share/sioyek/shared.db")

dir_libros = os.path.join(home, "Documentos/Libros")
dir_cristianos = os.path.join(home, "Documentos/Libros cristianos")
search_dirs = [dir_libros, dir_cristianos]
valid_extensions = (".pdf", ".epub", ".djvu")


def open_target_book(book_path):
    """Abre el libro seleccionado en Sioyek o visor predeterminado de forma desacoplada."""
    if not book_path or not os.path.isfile(book_path):
        sys.exit(0)
    viewer = "sioyek" if shutil.which("sioyek") else "xdg-open"
    # Desacoplar por completo el visor de los descriptores de archivo (pipes) de Rofi
    # para evitar que Rofi quede bloqueado esperando EOF en stdout/stderr
    subprocess.Popen(
        [viewer, book_path],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
        close_fds=True,
    )
    try:
        sys.stdout.close()
        sys.stderr.close()
    except Exception:
        pass
    # Forzar el cierre inmediato y limpio de Rofi para liberar el foco y el layer surface
    subprocess.Popen(
        ["pkill", "-x", "rofi"],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )
    sys.exit(0)


def has_valid_books(target_dir):
    """Verifica si un directorio contiene al menos un libro válido."""
    if not os.path.isdir(target_dir):
        return False
    for root, dirs, files in os.walk(target_dir, followlinks=True):
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        for f in files:
            if not f.startswith(".") and f.lower().endswith(valid_extensions):
                return True
    return False


def get_recent_books():
    """Obtiene los últimos libros leídos desde el historial SQLite de Sioyek."""
    recent = []
    seen = set()
    if os.path.isfile(db_local) and os.path.isfile(db_shared):
        try:
            con = sqlite3.connect(db_local)
            con.execute(f'ATTACH DATABASE "{db_shared}" AS shared')
            query = """
            SELECT d.path, s.last_access_time
            FROM document_hash d
            JOIN shared.opened_books s ON d.hash = s.path
            ORDER BY s.last_access_time DESC
            LIMIT 14
            """
            for path, _ in con.execute(query):
                if os.path.isfile(path) and path not in seen:
                    title = os.path.splitext(os.path.basename(path))[0].replace("\n", " ")
                    parent_dir = os.path.basename(os.path.dirname(path))
                    tag = f" [{parent_dir}]" if parent_dir not in ("Libros", "Libros cristianos") else ""
                    recent.append((f"[Reciente] {title}{tag}", path))
                    seen.add(path)
        except Exception:
            pass
    return recent


def scan_directory(target_dir, is_recursive=True):
    """Escanea un directorio y devuelve tuplas (display_text, full_path)."""
    results = []
    if not os.path.isdir(target_dir):
        return results

    visited_dirs = set()

    for root, dirs, files in os.walk(target_dir, followlinks=True):
        real_root = os.path.realpath(root)
        if real_root in visited_dirs:
            dirs[:] = []
            continue
        visited_dirs.add(real_root)

        dirs[:] = [d for d in dirs if not d.startswith(".")]

        rel_dir = os.path.relpath(root, target_dir)
        tag = f" [{rel_dir}]" if (rel_dir != "." and is_recursive) else ""

        for f in files:
            if f.startswith("."):
                continue
            if f.lower().endswith(valid_extensions):
                full_path = os.path.join(root, f)
                title = os.path.splitext(f)[0].replace("\n", " ")
                results.append((f"{title}{tag}", full_path))

        if not is_recursive:
            break

    return results


def print_items(items):
    """Imprime los elementos con metadatos de Rofi manejando broken pipes."""
    try:
        for display, path in items:
            clean_display = display.replace("\x00", "").replace("\x1f", "")
            print(f"{clean_display}\0info\x1f{path}")
        sys.stdout.flush()
    except BrokenPipeError:
        sys.exit(0)


def handle_mode_dispatch():
    """Maneja las peticiones de datos de cada modo o la selección de un libro."""
    rofi_info = os.environ.get("ROFI_INFO", "").strip()
    if rofi_info:
        open_target_book(rofi_info)

    mode = sys.argv[2] if len(sys.argv) >= 3 else "all"

    # Detección defensiva de selección cuando no llega ROFI_INFO
    if mode in ("dir-hex", "root-hex"):
        if len(sys.argv) >= 5 and sys.argv[4]:
            open_target_book(sys.argv[4])
    else:
        if len(sys.argv) >= 4 and sys.argv[3]:
            open_target_book(sys.argv[3])

    if mode == "recent":
        print_items(get_recent_books())
    elif mode == "dir-hex":
        try:
            target_dir = bytes.fromhex(sys.argv[3]).decode("utf-8") if len(sys.argv) >= 4 else ""
            books = scan_directory(target_dir, is_recursive=True)
            books.sort(key=lambda x: x[0].lower())
            print_items(books)
        except Exception:
            sys.exit(0)
    elif mode == "root-hex":
        try:
            target_dir = bytes.fromhex(sys.argv[3]).decode("utf-8") if len(sys.argv) >= 4 else ""
            books = scan_directory(target_dir, is_recursive=False)
            books.sort(key=lambda x: x[0].lower())
            print_items(books)
        except Exception:
            sys.exit(0)
    else:  # "all"
        all_items = []
        seen = set()

        # Recientes primero
        for display, path in get_recent_books():
            all_items.append((display, path))
            seen.add(path)

        # Toda la biblioteca
        books_list = []
        for sdir in search_dirs:
            if not os.path.isdir(sdir):
                continue
            base_name = os.path.basename(sdir)
            for display, path in scan_directory(sdir, is_recursive=True):
                if path not in seen:
                    rel = os.path.relpath(path, sdir)
                    parent = os.path.dirname(rel)
                    tag = f" [{base_name} » {parent}]" if parent and parent != "." else f" [{base_name}]"
                    title = os.path.splitext(os.path.basename(path))[0].replace("\n", " ")
                    books_list.append((f"{title}{tag}", path))
                    seen.add(path)

        books_list.sort(key=lambda x: x[0].lower())
        all_items.extend(books_list)
        print_items(all_items)


def build_dynamic_modes(script_path):
    """Detecta dinámicamente las carpetas existentes y genera los modos de Rofi."""
    modes = []
    modes.append(f"Todos:{script_path} --mode all")
    modes.append(f"Recientes:{script_path} --mode recent")

    detected_categories = []

    for sdir in search_dirs:
        if not os.path.isdir(sdir):
            continue

        base_name = os.path.basename(sdir)

        # 1. Comprobar si hay libros sueltos en la raíz directa
        root_books = scan_directory(sdir, is_recursive=False)
        if root_books:
            label = "Libros" if base_name == "Libros" else "Cristianos"
            hex_path = sdir.encode("utf-8").hex()
            detected_categories.append((label, f"{script_path} --mode root-hex {hex_path}"))

        # 2. Descubrir subcarpetas con libros
        try:
            with os.scandir(sdir) as it:
                for entry in it:
                    if entry.is_dir() and not entry.name.startswith("."):
                        if has_valid_books(entry.path):
                            hex_path = entry.path.encode("utf-8").hex()
                            detected_categories.append(
                                (entry.name, f"{script_path} --mode dir-hex {hex_path}")
                            )
        except Exception:
            pass

    # Ordenar las categorías detectadas
    detected_categories.sort(key=lambda x: x[0].lower())

    # Evitar nombres duplicados en pestañas si existieran en ambas bibliotecas
    seen_labels = {}
    for label, cmd in detected_categories:
        count = seen_labels.get(label, 0)
        seen_labels[label] = count + 1
        final_label = label if count == 0 else f"{label} ({count + 1})"
        modes.append(f"{final_label}:{cmd}")

    return ",".join(modes)


def main():
    # Si fue invocado por Rofi para un modo específico
    if len(sys.argv) >= 2 and sys.argv[1] == "--mode":
        handle_mode_dispatch()
        return

    # Invocación principal (al presionar Super + L)
    script_path = os.path.expanduser("~/.local/bin/selector-libros.sh")
    if not os.path.isfile(script_path):
        script_path = os.path.abspath(__file__)

    theme_path = os.path.expanduser("~/.config/rofi/books.rasi")
    if not os.path.isfile(theme_path):
        repo_theme = os.path.expanduser("~/dotfiles-nix/raw_configs/rofi/books.rasi")
        if os.path.isfile(repo_theme):
            theme_path = repo_theme
        else:
            theme_path = os.path.expanduser("~/.config/rofi/config.rasi")

    modes_arg = build_dynamic_modes(script_path)

    # Detectar margen reservado izquierdo en el monitor enfocado (ej. compensación franja rota en eDP-1)
    res_l = 0
    try:
        mon_proc = subprocess.run(
            ["hyprctl", "monitors", "-j"],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            check=False,
        )
        if mon_proc.returncode == 0 and mon_proc.stdout:
            import json
            monitors_data = json.loads(mon_proc.stdout)
            focused_mon = next((m for m in monitors_data if m.get("focused")), monitors_data[0] if monitors_data else {})
            reserved = focused_mon.get("reserved", [0, 0, 0, 0])
            if isinstance(reserved, list) and len(reserved) > 0:
                res_l = int(reserved[0])
    except Exception:
        res_l = 0

    rofi_cmd = [
        "rofi",
        "-show", "Todos",
        "-modes", modes_arg,
        "-theme", theme_path,
    ]
    if res_l > 0:
        pad_l = 60 + res_l
        rofi_cmd.extend(["-theme-str", f"mainbox {{ padding: 30px 60px 20px {pad_l}px; }}"])

    os.execvp("rofi", rofi_cmd)


if __name__ == "__main__":
    main()
