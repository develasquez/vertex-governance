"""Carga de `.env` sin dependencias externas, para los scripts de los labs.

¿Por qué existe? Para que ningún alumno pierda tiempo con "PROJECT_ID no está definido":
cada script llama a `load_env(__file__)` y este módulo busca el `.env` del Lab 0 y lo carga
en `os.environ` (como haría `set -a; source .env`). No sobreescribe variables que ya existan
en el entorno, así que exportar a mano sigue mandando.

Busca `.env` desde el directorio del script hacia arriba, incluyendo `<raíz>/lab-00-setup/.env`
y `<raíz>/labs/lab-00-setup/.env`.
"""
from __future__ import annotations

import os
import re
from pathlib import Path

__all__ = ["load_env"]

_VAR = re.compile(r"\$\{([A-Za-z_][A-Za-z0-9_]*)\}")


def _configure_vertex_ai() -> None:
    """Hace que ADK/google-genai usen el backend de **Vertex AI** (ADC), no la API pública.

    Sin esto, ADK intenta la API de Gemini y falla con "No API key was provided".
    Respeta lo que ya esté definido en el entorno o en el `.env`.
    """
    os.environ.setdefault("GOOGLE_GENAI_USE_VERTEXAI", "true")
    if "GOOGLE_CLOUD_PROJECT" not in os.environ and os.environ.get("PROJECT_ID"):
        os.environ["GOOGLE_CLOUD_PROJECT"] = os.environ["PROJECT_ID"]
    if "GOOGLE_CLOUD_LOCATION" not in os.environ and os.environ.get("LOCATION"):
        os.environ["GOOGLE_CLOUD_LOCATION"] = os.environ["LOCATION"]


def _unquote(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        return value[1:-1]
    return value


def _parse(path: Path) -> None:
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, val = line.partition("=")
        key = key.strip()
        if key.startswith("export "):
            key = key[len("export ") :].strip()
        val = _unquote(val)
        # Expande ${VAR} con lo que ya esté en el entorno (p. ej. STAGING_BUCKET usa ${PROJECT_ID}).
        val = _VAR.sub(lambda m: os.environ.get(m.group(1), m.group(0)), val)
        os.environ.setdefault(key, val)


def load_env(
    start: str | os.PathLike,
    levels: int = 4,
    configure_vertex_ai: bool = True,
) -> Path | None:
    """Carga el primer `.env` encontrado. Devuelve la ruta o `None` si no hay ninguno.

    Con `configure_vertex_ai=True` (por defecto) además configura ADK/google-genai para
    usar Vertex AI, de modo que no pida API key.
    """
    p = Path(start).resolve()
    d = p.parent if p.is_file() else p
    candidates: list[Path] = []
    cur = d
    for _ in range(levels):
        candidates += [
            cur / ".env",
            cur / "lab-00-setup" / ".env",
            cur / "labs" / "lab-00-setup" / ".env",
        ]
        cur = cur.parent
    found: Path | None = None
    for candidate in candidates:
        if candidate.is_file():
            _parse(candidate)
            found = candidate
            break
    if configure_vertex_ai:
        _configure_vertex_ai()
    return found
