"""Launcher del demo GEPA (Lab 3 — Evaluación).

Reutiliza el venv del **Lab 1** (que ya trae ADK 2.x + los extras de evaluación) e importa
las variables necesarias desde el **loader compartido** de los labs (`labs/_env.py`), en vez
de duplicar la lógica de `.env` / Vertex.

Uso:
    ./run_gepa.sh            # wrapper recomendado (resuelve el venv del Lab 1)
    # o, con el python del Lab 1:
    ../../lab-01-agente-adk/.venv/bin/python run_gepa.py
"""
from __future__ import annotations

import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

HERE = Path(__file__).resolve().parent
LABS = HERE.parents[1]                     # <repo>/labs
LAB1 = LABS / "lab-01-agente-adk"          # el venv vive aquí
ADK = LAB1 / ".venv" / "bin" / "adk"

# ---------------------------------------------------------------------------
# 1) Importamos las variables necesarias (PROJECT_ID, LOCATION, Vertex + ADC)
#    desde el loader compartido, igual que el resto de los labs. Nada duplicado.
# ---------------------------------------------------------------------------
sys.path.insert(0, str(LABS))
from _env import load_env  # noqa: E402

env_used = load_env(__file__)

print(f"▶️  GEPA (Lab 3) — optimizando 'support_agent'   ({datetime.now():%H:%M:%S})", flush=True)
print(f"    .env    : {env_used}", flush=True)
print(f"    proyecto: {os.environ.get('GOOGLE_CLOUD_PROJECT')}  "
      f"location: {os.environ.get('GOOGLE_CLOUD_LOCATION')}", flush=True)
print(f"    adk     : {ADK}", flush=True)
print(flush=True)

# ---------------------------------------------------------------------------
# 2) Verificaciones con mensajes de ayuda (en vez de un traceback críptico).
# ---------------------------------------------------------------------------
if not ADK.exists():
    sys.exit(
        "❌ No encuentro el `adk` del venv del Lab 1.\n"
        f"   Créalo:  cd {LAB1} && python3 -m venv .venv && source .venv/bin/activate \\\n"
        '            && pip install -r requirements.txt && pip install "google-adk[eval]"'
    )

try:                       # corre con el python del Lab 1, así que esto es válido
    import gepa  # noqa: F401
except ModuleNotFoundError:
    sys.exit(
        "❌ Falta GEPA en el venv del Lab 1.\n"
        f'   Instálalo:  "{LAB1}/.venv/bin/pip" install "google-adk[eval]"'
    )

# ---------------------------------------------------------------------------
# 3) `adk optimize` (GEPA) — el agente y su eval set.
# ---------------------------------------------------------------------------
cmd = [
    str(ADK), "optimize", str(HERE / "support_agent"),
    "--sampler_config_file_path", str(HERE / "sampler_config.json"),
    "--optimizer_config_file_path", str(HERE / "optimizer_config.json"),
    "--print_detailed_results",
    *sys.argv[1:],
]
raise SystemExit(subprocess.call(cmd))
