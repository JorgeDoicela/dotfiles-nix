#!/opt/voxd/.venv/bin/python
"""Daemon VOXD — faster-whisper en-proceso (modelo cargado una vez)."""
import os
import sys
import threading
import tempfile
import re
from pathlib import Path

sys.path.insert(0, "/opt/voxd/src")
os.environ.setdefault("YDOTOOL_SOCKET", str(Path.home() / ".ydotool_socket"))

from voxd.core.config import AppConfig
from voxd.core.logger import SessionLogger
from voxd.core.aipp import get_final_text
from voxd.utils.core_runner import AudioRecorder, ClipboardManager, SimulatedTyper
from voxd.utils.ipc_server import start_ipc_server
from faster_whisper import WhisperModel


FW_MODEL_DIR = "/opt/voxd/models/fw-small"


def _mic_autoset(cfg):
    if not cfg.data.get("mic_autoset_enabled", True):
        return
    import subprocess, shutil
    level = float(cfg.data.get("mic_autoset_level", 0.45))
    if shutil.which("wpctl"):
        subprocess.run(["wpctl", "set-mute", "@DEFAULT_SOURCE@", "0"], capture_output=True)
        subprocess.run(["wpctl", "set-volume", "@DEFAULT_SOURCE@", f"{level:.2f}"], capture_output=True)
    elif shutil.which("pactl"):
        subprocess.run(["pactl", "set-source-mute", "@DEFAULT_SOURCE@", "0"], capture_output=True)
        subprocess.run(["pactl", "set-source-volume", "@DEFAULT_SOURCE@", f"{int(level*100)}%"], capture_output=True)


def transcribe_fw(model: WhisperModel, audio_path: str, language: str) -> str:
    """Transcribe con faster-whisper, devuelve texto limpio."""
    segments, _ = model.transcribe(
        audio_path,
        language=language,
        beam_size=1,
        vad_filter=True,
        vad_parameters=dict(min_silence_duration_ms=300),
    )
    text = " ".join(seg.text.strip() for seg in segments).strip()
    # Limpiar timestamps residuales si los hubiera
    text = re.sub(r"\[\d{2}:\d{2}[\.:]\\d{3}\]|\(\d{2}:\d{2}\)", "", text)
    return text


def main():
    cfg = AppConfig()
    _mic_autoset(cfg)

    language = cfg.data.get("language", "es")

    print(f"[voxd] Cargando faster-whisper small (int8) en RAM...", flush=True)
    fw_model = WhisperModel(
        FW_MODEL_DIR,
        device="cpu",
        compute_type="int8",
        num_workers=1,
        cpu_threads=8,
    )
    print("[voxd] Modelo listo.", flush=True)

    logger = SessionLogger(cfg.log_enabled, cfg.log_location)
    hotkey = threading.Event()
    start_ipc_server(lambda: hotkey.set())

    recorder = AudioRecorder(
        record_chunked=cfg.data.get("record_chunked", True),
        chunk_seconds=int(cfg.data.get("record_chunk_seconds", 300)),
    )
    clipboard = ClipboardManager()
    typer = SimulatedTyper(
        delay=cfg.typing_delay,
        start_delay=cfg.typing_start_delay,
        cfg=cfg,
    )

    while True:
        hotkey.wait()
        hotkey.clear()
        recorder.start_recording()

        hotkey.wait()
        hotkey.clear()

        rec_path = recorder.stop_recording(preserve=False)

        tscript = transcribe_fw(fw_model, str(rec_path), language)
        if not tscript:
            continue

        final_text = get_final_text(tscript, cfg)
        clipboard.copy(final_text)
        if cfg.typing:
            typer.type(final_text)
        logger.log_entry(final_text)

        # Eliminar el audio temporal
        try:
            Path(rec_path).unlink(missing_ok=True)
        except Exception:
            pass


if __name__ == "__main__":
    main()
