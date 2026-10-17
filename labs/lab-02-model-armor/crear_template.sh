#!/usr/bin/env bash
# Lab 2 — crea un template de Model Armor con filtros razonables para empezar.
#
# Estrategia de umbrales (ver docs): prompt injection en MEDIUM_AND_ABOVE (preferimos no dejar
# pasar) y responsible-AI en HIGH (minimizar falsos positivos). El SDP usa la config BÁSICA
# (set predefinido: tarjeta de crédito, SSN, contraseñas, IBAN).
#
# Uso: ./crear_template.sh
set -euo pipefail

# Carga automática del .env del Lab 0 (si existe).
ENV_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/../lab-00-setup" && pwd)/.env"
if [ -f "${ENV_FILE}" ]; then
  set -a; set +u
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set -u; set +a
fi

: "${PROJECT_ID:?Define PROJECT_ID — crea labs/lab-00-setup/.env con 'cp .env.example .env'}"
LOCATION="${LOCATION:-us-central1}"
TEMPLATE_ID="${TEMPLATE_ID:-gdg-basic-safety}"

# ⚠️ gcloud enruta 'model-armor' al host MULTI-REGIÓN (modelarmor.us.rep.googleapis.com),
# que en este proyecto responde 403. Forzamos el host REGIONAL vía override de endpoint.
# (El SDK de Python de sanitize_demo.py ya usa el host regional y no necesita esto.)
export CLOUDSDK_API_ENDPOINT_OVERRIDES_MODELARMOR="https://modelarmor.${LOCATION}.rep.googleapis.com/"

if gcloud model-armor templates describe "${TEMPLATE_ID}" \
     --location="${LOCATION}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
  echo "ℹ️  El template '${TEMPLATE_ID}' ya existe en ${LOCATION} — no se recrea."
else
  echo "🛡️  Creando template de Model Armor: ${TEMPLATE_ID} en ${LOCATION}"

  gcloud model-armor templates create "${TEMPLATE_ID}" \
    --location="${LOCATION}" \
    --project="${PROJECT_ID}" \
    --template-metadata-log-sanitize-operations \
    --malicious-uri-filter-settings-enforcement=enabled \
    `# --- Responsible AI: umbral HIGH para reducir falsos positivos ---` \
    --rai-settings-filters='[
      {"filterType":"HATE_SPEECH","confidenceLevel":"HIGH"},
      {"filterType":"HARASSMENT","confidenceLevel":"HIGH"},
      {"filterType":"SEXUALLY_EXPLICIT","confidenceLevel":"HIGH"},
      {"filterType":"DANGEROUS","confidenceLevel":"HIGH"}
    ]' \
    `# --- Prompt injection / jailbreak: umbral medium-and-above ---` \
    --pi-and-jailbreak-filter-settings-enforcement=enabled \
    --pi-and-jailbreak-filter-settings-confidence-level=medium-and-above \
    `# --- Sensitive Data Protection: config BASICA (tarjeta, SSN, contrasenas, IBAN). ---` \
    `# NO cubre API keys de GCP; para eso usa la config 'advanced' (inspect template de ---` \
    `# DLP), mutuamente excluyente con la basica. ---` \
    --basic-config-filter-enforcement=enabled

  echo ""
  echo "✅ Template creado."
fi

echo "▶️  Exporta la variable para el demo:"
echo "   export MODEL_ARMOR_TEMPLATE=\"projects/${PROJECT_ID}/locations/${LOCATION}/templates/${TEMPLATE_ID}\""
echo ""
echo "ℹ️  Enforcement: por defecto el template puede operar en modo 'inspect only' o 'inspect and block'"
echo "    según lo configure el gateway/integración. Para el demo usamos la API directamente (bloquea el veredicto)."
