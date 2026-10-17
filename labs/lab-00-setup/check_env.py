#!/usr/bin/env python3
"""Lab 0 — verifica que el entorno esté listo para los labs."""
from __future__ import annotations

import os
import shutil
import subprocess
import sys

# --- Carga automática del .env del Lab 0 (sin dependencias externas) ---
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
try:
    from _env import load_env

    load_env(__file__)
except Exception:  # noqa: BLE001
    pass


def run(cmd: list[str]) -> tuple[int, str]:
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        return p.returncode, (p.stdout or p.stderr).strip()
    except Exception as exc:  # noqa: BLE001
        return 1, str(exc)


def main() -> int:
    ok = True
    project_id = os.environ.get("PROJECT_ID", "")
    location = os.environ.get("LOCATION", "us-central1")
    bucket = os.environ.get("STAGING_BUCKET", f"gs://{project_id}-agent-staging")

    if not project_id:
        print("❌ PROJECT_ID no está definido. Crea el archivo: cp .env.example .env")
        return 1

    # 1. gcloud presente y autenticado
    if shutil.which("gcloud") is None:
        print("❌ gcloud no está en el PATH.")
        return 1
    code, out = run(["gcloud", "auth", "list", "--filter=status:ACTIVE", "--format=value(account)"])
    if code == 0 and out:
        print(f"✅ gcloud autenticado como: {out.splitlines()[0]}")
    else:
        print("❌ gcloud sin cuenta activa. Corre: gcloud auth login")
        ok = False

    # 2. proyecto accesible
    code, out = run(["gcloud", "projects", "describe", project_id, "--format=value(projectId)"])
    if code == 0 and out == project_id:
        print(f"✅ proyecto accesible: {project_id}")
    else:
        print(f"❌ no puedo acceder al proyecto {project_id}")
        ok = False

    # 3. ADC
    adc_path = os.path.expanduser("~/.config/gcloud/application_default_credentials.json")
    if os.path.exists(adc_path):
        print("✅ Application Default Credentials presentes")
    else:
        print("❌ ADC no encontradas. Corre: gcloud auth application-default login")
        ok = False

    # 4. bucket accesible
    code, _ = run(["gcloud", "storage", "buckets", "describe", bucket, "--project", project_id])
    if code == 0:
        print(f"✅ bucket accesible: {bucket}")
    else:
        print(f"⚠️  bucket no accesible aún: {bucket} (corre ./setup.sh)")
        ok = False

    print(f"\nℹ️  Región configurada: {location}")
    print("✅ entorno listo para los labs" if ok else "❌ hay pendientes, revisa arriba")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
