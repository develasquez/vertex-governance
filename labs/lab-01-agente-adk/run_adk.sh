#!/usr/bin/env bash
# Lanza las herramientas CLI de ADK (web/run) para ESTE agente.
#
# ¿Por qué este script?
#   ADK exige que la CARPETA del agente sea un identificador Python válido
#   (letras, dígitos y guion_bajo). Esta carpeta se llama "lab-01-agente-adk"
#   (con guiones), así que `adk web` / `adk run` la rechazan con:
#       Invalid agent name: 'lab-01-agente-adk'. Agent names must be valid
#       Python identifiers (letters, digits, and underscores only).
#   Solución: creamos un directorio temporal con un nombre válido ("support_agent")
#   que re-exporta el `root_agent` real, y apuntamos ADK ahí. No se mueve nada.
#
# Uso:
#   ./run_adk.sh web               # UI web de desarrollo (por defecto)
#   ./run_adk.sh run               # conversa en la terminal
#   ./run_adk.sh web --port 8080   # argumentos extra van a `adk`
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUBCMD="${1:-web}"
shift || true

# Localiza `adk`. PREFERIMOS SIEMPRE el del venv (ADK 2.x): un `adk` global puede ser una
# versión vieja (1.x) que NO tiene comandos como `optimize`.
if [ -x "${HERE}/.venv/bin/adk" ]; then
  export PATH="${HERE}/.venv/bin:${PATH}"
elif ! command -v adk >/dev/null 2>&1; then
  echo "❌ No encuentro 'adk'. Crea el venv del Lab 1:" >&2
  echo "   python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt" >&2
  exit 1
fi

# Carga el .env del Lab 0 y apunta ADK a Vertex AI (usa tu ADC; NO pide API key).
ENV_FILE="${HERE}/../lab-00-setup/.env"
if [ -f "${ENV_FILE}" ]; then
  set -a; set +u
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set -u; set +a
fi
export GOOGLE_GENAI_USE_VERTEXAI="${GOOGLE_GENAI_USE_VERTEXAI:-true}"
export GOOGLE_CLOUD_PROJECT="${GOOGLE_CLOUD_PROJECT:-${PROJECT_ID:-}}"
export GOOGLE_CLOUD_LOCATION="${GOOGLE_CLOUD_LOCATION:-${LOCATION:-us-central1}}"

if [ -z "${GOOGLE_CLOUD_PROJECT}" ]; then
  echo "⚠️  No pude determinar el proyecto (crea labs/lab-00-setup/.env)." >&2
fi

WORK="$(mktemp -d)"
cleanup() { rm -rf "${WORK}"; }
trap cleanup EXIT

mkdir -p "${WORK}/support_agent"
cat > "${WORK}/support_agent/__init__.py" <<PY
"""Puente autogenerado por run_adk.sh (nombre de carpeta válido para ADK)."""
import importlib.util
from pathlib import Path

_real = Path("${HERE}") / "agent.py"
_spec = importlib.util.spec_from_file_location("support_agent_real", _real)
_mod = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_mod)
root_agent = _mod.root_agent
PY

cd "${WORK}"
case "${SUBCMD}" in
  web)
    echo "▶️  adk web — agente 'support_agent'  ($(date +%H:%M:%S))"
    adk web "$@"
    ;;
  run)
    echo "▶️  adk run — agente 'support_agent'"
    adk run support_agent "$@"
    ;;
  *)
    echo "Uso: $0 [web|run] [args...]" >&2
    exit 2
    ;;
esac
