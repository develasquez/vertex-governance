#!/usr/bin/env python3
"""
Lab 1 (extra) — Agent Identity: el gobierno también vive en el RUNTIME, no en el agente.

Igual que Sessions/Memory Bank, la IDENTIDAD no está en `agent.py`: el código del agente es
idéntico y solo cambia la **configuración del runtime** (`identity_type`).

Este demo contrasta:

  - Agente del Lab 1, desplegado CON `identity_type=AGENT_IDENTITY`
        → identidad SPIFFE propia:  principal://agents.global.org-.../reasoningEngines/<id>
        → least privilege por agente + auditoría real.

  - Agente "baseline", desplegado SIN `identity_type`
        → usa la service account / service agent del proyecto.
        → permisos compartidos, sin trazabilidad por agente.

Uso:
    python identity_demo.py                    # inspecciona el agente del Lab 1
    python identity_demo.py --deploy-baseline  # además despliega el baseline sin identidad
    python identity_demo.py --cleanup          # borra el baseline

Requiere: AGENT_ENGINE_ID (Lab 1) + ADC.
Docs: https://docs.cloud.google.com/gemini-enterprise-agent-platform/scale/runtime/agent-identity
"""
from __future__ import annotations

import argparse
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
from agentplatform import types
from agentplatform.frameworks import AdkApp

from agent import root_agent
from deploy import REQUIREMENTS  # mismas dependencias que el deploy del Lab 1

PROJECT_ID = os.environ.get("PROJECT_ID", "")
LOCATION = os.environ.get("LOCATION", "us-central1")
STAGING_BUCKET = os.environ.get("STAGING_BUCKET", f"gs://{PROJECT_ID}-agent-staging")
AGENT_ENGINE_ID = os.environ.get("AGENT_ENGINE_ID", "")
BASELINE_NAME = os.environ.get("AGENT_BASELINE_NAME", "gdg-workshop-agent-baseline")


def make_client() -> "agentplatform.Client":
    return agentplatform.Client(
        project=PROJECT_ID,
        location=LOCATION,
        http_options=dict(api_version="v1beta1"),
    )


def classify(identity: str) -> str:
    """Clasifica una identidad efectiva como Agent Identity o service account."""
    if not identity or identity == "no disponible":
        return "❓ no disponible"
    if (
        identity.startswith("principal://")
        or identity.startswith("agents.global.")
        or "id.goog" in identity
    ):
        return "✅ Agent Identity (SPIFFE) — least privilege por agente + auditoría"
    return "⚠️  Service account / service agent del proyecto — permisos compartidos"


def effective_identity(resource) -> str:
    spec = getattr(resource, "spec", None) or getattr(resource, "api_resource", None)
    if spec is not None and hasattr(spec, "spec"):
        spec = spec.spec
    return getattr(spec, "effective_identity", "no disponible") if spec else "no disponible"


def describe_agent(agent_id: str) -> str:
    client = make_client()
    name = f"projects/{PROJECT_ID}/locations/{LOCATION}/reasoningEngines/{agent_id}"
    remote = client.runtimes.get(name=name)
    identity = effective_identity(remote.api_resource)
    print(f"\n🔎 Agente del Lab 1  (id={agent_id})")
    print(f"   effective_identity = {identity}")
    print(f"   → {classify(identity)}")
    return identity


def deploy_baseline() -> tuple[str, str]:
    """Despliega un agente SIN identity_type (usa la service account del proyecto)."""
    client = make_client()
    print("\n🚀 Desplegando agente BASELINE sin identidad (usa service account)…")
    remote = client.runtimes.create(
        agent=AdkApp(agent=root_agent),
        config={
            "display_name": BASELINE_NAME,
            # ⬅️ A PROPÓSITO: sin "identity_type" → no tiene identidad propia.
            "requirements": REQUIREMENTS,
            # El pickle referencia el módulo `agent`; hay que enviarlo (ver deploy.py).
            "extra_packages": ["agent.py"],
            "staging_bucket": STAGING_BUCKET,
        },
    )
    resource = remote.api_resource
    agent_id = resource.name.split("/")[-1]
    identity = effective_identity(resource)
    print(f"\n🔎 Agente BASELINE  (id={agent_id})")
    print(f"   effective_identity = {identity}")
    print(f"   → {classify(identity)}")
    return agent_id, identity


def cleanup(agent_id: str) -> None:
    client = make_client()
    name = f"projects/{PROJECT_ID}/locations/{LOCATION}/reasoningEngines/{agent_id}"
    print(f"\n🧹 Borrando baseline {agent_id}…")
    client.runtimes.delete(name=name)
    print("   ✅ borrado")


def main() -> None:
    parser = argparse.ArgumentParser(description="Demo de Agent Identity vs service account")
    parser.add_argument("--deploy-baseline", action="store_true", help="despliega un agente sin identidad")
    parser.add_argument("--cleanup", action="store_true", help="borra el baseline")
    args = parser.parse_args()

    if not PROJECT_ID:
        sys.exit("❌ Define PROJECT_ID (crea ../lab-00-setup/.env con 'cp .env.example .env').")

    if args.cleanup:
        # Necesitamos el id del baseline; lo pedimos al usuario.
        baseline_id = input("ID del baseline a borrar: ").strip()
        cleanup(baseline_id)
        return

    if not AGENT_ENGINE_ID:
        sys.exit(
            "❌ Falta AGENT_ENGINE_ID. Corre ../lab-01-agente-adk/deploy.py y exporta el ID."
        )

    _ = describe_agent(AGENT_ENGINE_ID)

    if args.deploy_baseline:
        baseline_id, _ = deploy_baseline()
        print(
            "\n--- Comparación ---\n"
            "   Lab 1   → principal://... (identidad propia del agente)\n"
            "   Baseline→ service account del proyecto (sin identidad propia)\n"
            "\n💡 El código del agente es EL MISMO. Lo único que cambió fue la config del runtime.\n"
            "   La identidad, como la memoria, vive en el runtime — no en el agente.\n"
            f"\n🧹 Para limpiar:  python identity_demo.py --cleanup   (id={baseline_id})\n"
        )
    else:
        print(
            "\nℹ️  Corre con --deploy-baseline para comparar contra un agente sin identidad.\n"
            "   Alternativa solo-lectura (REST; no requiere componente alpha):\n"
            "   curl -s -H \"Authorization: Bearer $(gcloud auth print-access-token)\" \\\n"
            f"     \"https://{LOCATION}-aiplatform.googleapis.com/v1beta1/projects/{PROJECT_ID}"
            f"/locations/{LOCATION}/reasoningEngines/{AGENT_ENGINE_ID}\" | python3 -m json.tool\n"
            "   # busca 'spec.effectiveIdentity'  →  el principal SPIFFE del agente\n"
        )


if __name__ == "__main__":
    main()
