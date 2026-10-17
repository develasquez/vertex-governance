#!/usr/bin/env bash
# Lanza el demo GEPA del Lab 3 (refinamiento de instrucciones con `adk optimize`).
#
# Reutiliza el venv del Lab 1 (ADK 2.x + extras de evaluación) e importa las variables
# necesarias desde `labs/_env.py` (vía run_gepa.py). No duplica configuración.
#
# Uso:  ./run_gepa.sh
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB1="$(cd "${HERE}/../../lab-01-agente-adk" && pwd)"
PY="${LAB1}/.venv/bin/python"

if [ ! -x "${PY}" ]; then
  echo "❌ No encuentro el venv del Lab 1 (${LAB1}/.venv)." >&2
  echo "   Créalo:  cd ${LAB1} && python3 -m venv .venv && source .venv/bin/activate" >&2
  echo "            pip install -r requirements.txt && pip install \"google-adk[eval]\"" >&2
  exit 1
fi

# run_gepa.py carga el .env (loader compartido) e invoca `adk optimize`.
exec "${PY}" "${HERE}/run_gepa.py" "$@"
