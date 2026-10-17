#!/usr/bin/env python3
"""
Lab 1 (extra) — Memoria de LARGO PLAZO con Agent Platform Memory Bank.

Contraste con `test_local.py`:
  - Sessions  = memoria de CORTO plazo (dentro de una conversación). Se pierde al cambiar de sesión.
  - Memory Bank = memoria de LARGO plazo (persiste ENTRE sesiones).

💡 Igual que las sessions, Memory Bank **NO** se cablea dentro del agente: se pasa al
   **Runner** como `memory_service`. El agente sigue siendo declarativo y sin estado.

Flujo del demo:
  1. Sesión 1: el usuario revela una preferencia ("los reembolsos a mi tarjeta").
  2. Se ingesta esa sesión en Memory Bank  →  `memory_service.add_session_to_memory(session)`.
  3. Sesión 2 (nueva): el agente recuerda la preferencia gracias a la memoria de largo plazo.

Nota (ADK 2.x): el `Runner` **no** inyecta memorias por sí solo. El agente recibe las
memorias relevantes mediante la tool `preload_memory` (declarada en `agent.py`), que
consulta el `memory_service` del Runner. La memoria sigue viviendo en el servicio, no
en el agente.

Requiere:
  - `AGENT_ENGINE_ID` definido (el agente del Lab 1, desplegado).
  - Autenticación ADC:  gcloud auth application-default login

Docs: https://docs.cloud.google.com/gemini-enterprise-agent-platform/scale/memory-bank
"""
from __future__ import annotations

import asyncio
import os
import sys

# --- Carga automática del .env del Lab 0 (sin dependencias externas) ---
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
try:
    from _env import load_env

    load_env(__file__)
except Exception:  # noqa: BLE001
    pass

from google.adk import Runner
from google.adk.memory import VertexAiMemoryBankService
from google.adk.sessions import InMemorySessionService
from google.genai import types as genai_types

from agent import root_agent

PROJECT_ID = os.environ.get("PROJECT_ID", "")
LOCATION = os.environ.get("LOCATION", "us-central1")
AGENT_ENGINE_ID = os.environ.get("AGENT_ENGINE_ID", "")
APP_NAME = "gdg-workshop"
USER_ID = "tester"

# Preferencia que queremos que sobreviva ENTRE sesiones.
PREFERENCE_MSG = (
    "Recuerda esta preferencia para el futuro: si hay un reembolso, "
    "prefiero recibirlo en mi tarjeta de crédito, nunca como crédito de tienda."
)
RECALL_MS = "¿Cómo prefiero recibir los reembolsos? Responde solo con mi preferencia."


async def turn(runner: Runner, session_id: str, text: str) -> None:
    content = genai_types.Content(role="user", parts=[genai_types.Part(text=text)])
    print(f"\n🧑 {text}\n")
    async for event in runner.run_async(
        user_id=USER_ID, session_id=session_id, new_message=content
    ):
        if event.content and event.content.parts:
            for part in event.content.parts:
                if getattr(part, "text", None):
                    print(f"🤖 {part.text}")


async def main_async() -> None:
    # memory_service apunta al Memory Bank gestionado del Agent Runtime.
    # Nótese: se conecta al RUNNER, no al agente.
    print("🔗 Conectando Memory Bank (service gestionado)…")
    memory_service = VertexAiMemoryBankService(
        agent_engine_id=AGENT_ENGINE_ID,
        project=PROJECT_ID,
        location=LOCATION,
    )
    session_service = InMemorySessionService()
    runner = Runner(
        agent=root_agent,
        app_name=APP_NAME,
        session_service=session_service,   # corto plazo
        memory_service=memory_service,     # largo plazo  <-- la diferencia
    )

    # --- Sesión 1: el usuario revela la preferencia ---
    s1 = await session_service.create_session(app_name=APP_NAME, user_id=USER_ID)
    print(f"\n📂 Sesión 1 ({s1.id[:8]}…)")
    await turn(runner, s1.id, "Hola, quiero gestionar una devolución.")
    await turn(runner, s1.id, PREFERENCE_MSG)

    # --- Persistir la sesión en Memory Bank ---
    print("\n💾 Ingestando la Sesión 1 en Memory Bank…")
    # En ADK 2.x la ingesta vive en el *memory service* (no en el Runner):
    # `Runner.add_session_to_memory` ya no existe. Releemos la sesión para
    # incluir los eventos registrados durante la conversación.
    s1_full = await session_service.get_session(
        app_name=APP_NAME, user_id=USER_ID, session_id=s1.id
    )
    await memory_service.add_session_to_memory(session=s1_full)
    print("   ✅ memoria generada")

    # (Opcional) Ver qué se guardó:
    try:
        memories = await memory_service.search_memory(
            app_name=APP_NAME, user_id=USER_ID, query="preferencia de reembolso"
        )
        print(f"   🔎 memorias encontradas: {len(getattr(memories, 'memories', []) or [])}")
    except Exception as exc:  # noqa: BLE001
        print(f"   (search_memory no disponible en esta versión: {exc})")

    # --- Sesión 2: sesión NUEVA, el agente debe recordar la preferencia ---
    s2 = await session_service.create_session(app_name=APP_NAME, user_id=USER_ID)
    print(f"\n🆕 Sesión 2 ({s2.id[:8]}…) — sesión nueva, sin contexto previo:")
    await turn(runner, s2.id, RECALL_MS)

    print(
        "\n✅ Si el agente recordó tu preferencia en la Sesión 2, Memory Bank funcionó.\n"
        "   Eso es memoria de LARGO plazo: no viajó en la conversación, viajó en el servicio.\n"
    )


def main() -> None:
    if not PROJECT_ID:
        raise SystemExit("❌ Define PROJECT_ID (crea ../lab-00-setup/.env con 'cp .env.example .env').")
    if not AGENT_ENGINE_ID:
        raise SystemExit(
            "❌ Falta AGENT_ENGINE_ID. Corre primero ../lab-01-agente-adk/deploy.py "
            "y exporta el ID (o usa el agente de respaldo del instructor)."
        )
    asyncio.run(main_async())


if __name__ == "__main__":
    main()
