# Lab 0 — Setup del entorno

**Objetivo:** dejar tu proyecto listo para construir, desplegar y gobernar agentes.
**Tiempo:** ~10 min.

---

## 1. Requisitos

- Python 3.11+
- `gcloud` CLI y `gcloud beta`:
  ```bash
  gcloud --version
  gcloud components install beta   # si falta
  ```
- Un proyecto GCP. Si no tienes billing, puedes usar **Starter Tier** (los primeros deploys son gratis).

---

## 2. Configurar variables

Copia el archivo de ejemplo y edítalo:

```bash
cp .env.example .env
# edita .env con tu PROJECT_ID
```

> ✅ **No hace falta `source .env`**: los scripts (`setup.sh`, `crear_template.sh`,
> `governance_setup.sh`, `teardown.sh`) **leen `.env` automáticamente** si existe.
> Solo necesitas el archivo creado y editado.
>
> Si aun así quieres cargarlas en tu shell (p. ej. para `python`), usa `set -a; source .env; set +a`.

O expórtalas a mano:

```bash
export PROJECT_ID="tu-proyecto-gcp"
export LOCATION="us-central1"
export STAGING_BUCKET="gs://${PROJECT_ID}-agent-staging"
```

> `us-central1` es la región más segura para los labs. Si tu org impone restricciones de región,
> revisa `agent-locations` en la doc.

---

## 3. Autenticación

```bash
gcloud auth login
gcloud config set project "$PROJECT_ID"
gcloud auth application-default login
gcloud auth application-default set-quota-project "$PROJECT_ID"
```

---

## 4. Habilitar APIs

Ejecuta el script (o hazlo manual, es lo mismo):

```bash
./setup.sh
```

Equivalente manual:

```bash
gcloud services enable \
  aiplatform.googleapis.com \
  modelarmor.googleapis.com \
  agentregistry.googleapis.com \
  networkservices.googleapis.com \
  networksecurity.googleapis.com \
  iap.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com \
  storage.googleapis.com \
  cloudapiregistry.googleapis.com \
  --project="$PROJECT_ID"
```

> Si alguna API no existe en tu proyecto/región (por cambio de nombre), el comando se queja solo de
> esa; puedes continuar.

---

## 5. Crear el bucket de staging

```bash
gcloud storage buckets create "$STAGING_BUCKET" \
  --project="$PROJECT_ID" \
  --location="$LOCATION" 2>/dev/null || echo "bucket ya existe"
```

---

## 6. Verificación

```bash
python3 check_env.py
```

Deberías ver:

```
✅ gcloud autenticado
✅ proyecto: <tu-proyecto>
✅ ADC configurado
✅ bucket accesible: gs://...-agent-staging
✅ entorno listo para los labs
```

---

## Troubleshooting

| Síntoma | Causa probable | Solución |
|---|---|---|
| `Permission denied` al habilitar APIs | Falta rol `roles/serviceusage.serviceUsageAdmin` | Pídelo al admin del proyecto. |
| `ADC not found` | No corriste `application-default login` | Repite el paso 3. |
| `quota project` error | ADC sin quota project | `gcloud auth application-default set-quota-project`. |
| API inexistente | Cambió de nombre en 2026 | Omite esa API y revisa la doc de `recursos/bibliografia.md`. |
| `PROJECT_ID: Define PROJECT_ID` | No existe `.env` (o no tiene `PROJECT_ID`) | Crea el archivo: `cp .env.example .env` y edítalo. Los scripts lo leen solos. |

**Siguiente:** `labs/lab-01-agente-adk/`
