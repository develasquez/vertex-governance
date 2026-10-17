#!/usr/bin/env python3
"""
Lab 1 — Invoca el agente ya desplegado en Agent Runtime (ex Agent Engine).

Cliente mínimo para conversar con el agente del Lab 1 después del deploy.

Uso:
    python invoke_remote.py "¿estado del pedido A-1001?"   # lee ../lab-00-setup/.env (AGENT_ENGINE_ID)
    python invoke_remote.py                                 # usa una pregunta por defecto
"""
from __future__ import annotations

import os
import sys

# --- Carga automática del .env del Lab 0 (sin dependencias externas) ---
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
try:
    from _env import load_env

    load_env(__file__)
except Exception:  # noqa: BLE001
    pass

import agentplatform

PROJECT_ID = os.environ.get("PROJECT_ID", "")
LOCATION = os.environ.get("LOCATION", "us-central1")
AGENT_ENGINE_ID = os.environ.get("AGENT_ENGINE_ID", "")


def main() -> None:
    if not PROJECT_ID:
        sys.exit("❌ Define PROJECT_ID (crea ../lab-00-setup/.env con 'cp .env.example .env').")
    if not AGENT_ENGINE_ID:
        sys.exit("❌ Falta AGENT_ENGINE_ID. Corre deploy.py y exporta el ID (o usa el agente de respaldo).")

    client = agentplatform.Client(project=PROJECT_ID, location=LOCATION)
    name = f"projects/{PROJECT_ID}/locations/{LOCATION}/reasoningEngines/{AGENT_ENGINE_ID}"
    remote = client.runtimes.get(name=name)

    message = " ".join(sys.argv[1:]) or "¿Cuál es el estado del pedido A-1001?"
    print(f"🧑 {message}\n")
    for event in remote.stream_query(user_id="tester", message=message):
        # El formato del evento puede variar por versión del SDK; lo imprimimos tal cual.
        print(event)


if __name__ == "__main__":
    main()
