#!/usr/bin/env python3
"""
Lab 1 — Despliegue del agente en Agent Runtime (ex Agent Engine) CON Agent Identity.

Agent Identity le da al agente una identidad SPIFFE propia (principal://...), ligada a su
ciclo de vida, con mTLS + DPoP por defecto (Context-Aware Access). Es la base del gobierno:
sin identidad por agente no hay least privilege ni auditoría real.

Docs: https://docs.cloud.google.com/gemini-enterprise-agent-platform/scale/runtime/agent-identity

Uso:
    python deploy.py   # lee ../lab-00-setup/.env automáticamente
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

# SDK actual de la plataforma (ex vertexai). Si tu versión aún expone `vertexai`,
# ajusta el import según la doc del laboratorio.
import agentplatform
from agentplatform import types
from agentplatform.frameworks import AdkApp

from agent import root_agent

PROJECT_ID = os.environ["PROJECT_ID"]
LOCATION = os.environ.get("LOCATION", "us-central1")
STAGING_BUCKET = os.environ.get("STAGING_BUCKET", f"gs://{PROJECT_ID}-agent-staging")
DISPLAY_NAME = os.environ.get("AGENT_DISPLAY_NAME", "gdg-workshop-agent")

# Dependencias que se instalan en el Agent Runtime.
REQUIREMENTS = [
    "google-cloud-agentplatform[adk,runtimes]",
    # El framework ADK del runtime importa `google.cloud.aiplatform.utils`
    # (para resolver nº de proyecto → ID en `_get_project_id`). No viene incluido
    # con `agentplatform`; sin él, el engine falla al levantar.
    "google-cloud-aiplatform",
]


def main() -> None:
    # v1beta1 es necesario para Agent Identity en el momento de escribir este lab.
    client = agentplatform.Client(
        project=PROJECT_ID,
        location=LOCATION,
        http_options=dict(api_version="v1beta1"),
    )

    # Envolvemos el agente ADK para el runtime.
    app = AdkApp(agent=root_agent)

    print("🚀 Desplegando agente en Agent Runtime (esto tarda ~2-4 min)...")
    remote_app = client.runtimes.create(
        agent=app,
        config={
            "display_name": DISPLAY_NAME,
            "identity_type": types.IdentityType.AGENT_IDENTITY,  # <-- identidad propia
            "requirements": REQUIREMENTS,
            # El agente se serializa con cloudpickle, que guarda las funciones/tools
            # por referencia a su módulo (`agent`). Hay que enviar el módulo junto al
            # pickle, si no el runtime falla al deserializar con
            # "No module named 'agent'". `extra_packages` se sube como
            # dependencies.tar.gz y se extrae en el runtime.
            "extra_packages": ["agent.py"],
            "staging_bucket": STAGING_BUCKET,
            # Telemetría para el Lab 3 (observabilidad / trazas)
            "env_vars": {
                "GOOGLE_CLOUD_AGENT_ENGINE_ENABLE_TELEMETRY": "true",
                "OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT": "true",
            },
        },
    )

    resource = remote_app.api_resource
    agent_id = resource.name.split("/")[-1] if hasattr(resource, "name") else "desconocido"
    identity = getattr(resource.spec, "effective_identity", "no disponible")

    print("\n✅ Agente desplegado")
    print(f"   AGENT_ENGINE_ID = {agent_id}")
    print(f"   Identidad efectiva (SPIFFE) = {identity}")
    print("\n👉 Exporta estas variables para los siguientes labs:")
    print(f'   export AGENT_ENGINE_ID="{agent_id}"')
    print("\n   (guarda el ID en tu .env)")


if __name__ == "__main__":
    main()
