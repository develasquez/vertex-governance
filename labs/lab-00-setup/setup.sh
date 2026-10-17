#!/usr/bin/env bash
# Lab 0 — habilita las APIs necesarias para el workshop.
# Uso: ./setup.sh   (lee .env automáticamente si existe)

set -euo pipefail

# Carga automática de .env (si existe): no dependemos de que el alumno haga `source .env`.
ENV_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.env"
if [ -f "${ENV_FILE}" ]; then
  set -a; set +u
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set -u; set +a
fi

: "${PROJECT_ID:?Define PROJECT_ID — crea tu .env con 'cp .env.example .env'}"
LOCATION="${LOCATION:-us-central1}"
STAGING_BUCKET="${STAGING_BUCKET:-gs://${PROJECT_ID}-agent-staging}"

echo "🔧 Proyecto: ${PROJECT_ID}   Región: ${LOCATION}"

echo "▶️  Configurando gcloud..."
gcloud config set project "${PROJECT_ID}" >/dev/null

echo "▶️  Habilitando APIs (algunas pueden no existir según la región; se ignora el error)..."
APIS=(
  aiplatform.googleapis.com
  modelarmor.googleapis.com
  agentregistry.googleapis.com
  networkservices.googleapis.com
  networksecurity.googleapis.com
  iap.googleapis.com
  logging.googleapis.com
  monitoring.googleapis.com
  storage.googleapis.com
  cloudapiregistry.googleapis.com
)
for api in "${APIS[@]}"; do
  if gcloud services enable "${api}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
    echo "   ✅ ${api}"
  else
    echo "   ⚠️  ${api} (omitida — revisa nombre/región)"
  fi
done

echo "▶️  Creando bucket de staging (si no existe)..."
if gcloud storage buckets describe "${STAGING_BUCKET}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
  echo "   ℹ️  ya existe: ${STAGING_BUCKET}"
else
  gcloud storage buckets create "${STAGING_BUCKET}" \
    --project="${PROJECT_ID}" --location="${LOCATION}" >/dev/null
  echo "   ✅ creado: ${STAGING_BUCKET}"
fi

echo ""
echo "✅ Setup completo. Ahora ejecuta:  python check_env.py"
