#!/usr/bin/env bash
# Teardown del workshop — elimina los recursos que quedan vivos tras la sesión.
#
# Ejecución directa. Pide confirmación antes de borrar (para no eliminar por accidente).
#
#   (lee labs/lab-00-setup/.env automáticamente si existe)
#   ./teardown.sh
#
# Qué borra (los que existan / estén definidos):
#   - Agente(s) de Agent Runtime (el del Lab 1 y, si aplica, el baseline del demo de identidad)
#   - Plantilla de Model Armor (Lab 2)
#   - Agent Gateway (Lab 4)
#   - Services registrados en Agent Registry (Lab 4)
#   - (Opcional) Bucket de staging GCS  ->  define REMOVE_BUCKET=1
#
# Nota: los IAM bindings del principalSet NO se borran automáticamente (son inocuos sin el agente).
set -uo pipefail   # sin -e: queremos intentar borrar todo aunque falte algo

# Carga automática del .env del Lab 0 (si existe).
ENV_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/labs/lab-00-setup/.env"
if [ -f "${ENV_FILE}" ]; then
  set -a; set +u
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set -u; set +a
fi

PROJECT_ID="${PROJECT_ID:?Define PROJECT_ID — crea labs/lab-00-setup/.env con 'cp .env.example .env'}"
LOCATION="${LOCATION:-us-central1}"

# Model Armor: gcloud enruta al host MULTI-REGIÓN (modelarmor.us.rep.googleapis.com) → 403.
# Forzamos el host REGIONAL para que 'describe/delete' del template funcionen.
export CLOUDSDK_API_ENDPOINT_OVERRIDES_MODELARMOR="https://modelarmor.${LOCATION}.rep.googleapis.com/"

AGENT_ENGINE_ID="${AGENT_ENGINE_ID:-}"
AGENT_BASELINE_ID="${AGENT_BASELINE_ID:-}"
TEMPLATE_ID="${TEMPLATE_ID:-gdg-basic-safety}"
GATEWAY_NAME="${GATEWAY_NAME:-gdg-agent-gateway}"
REGISTRY_AGENT="${REGISTRY_AGENT:-gdg-support-agent}"
MCP_NAME="${MCP_NAME:-internal-crm-mcp}"
STAGING_BUCKET="${STAGING_BUCKET:-gs://${PROJECT_ID}-agent-staging}"
REMOVE_BUCKET="${REMOVE_BUCKET:-0}"

echo "🧹 Teardown del workshop en ${PROJECT_ID} / ${LOCATION}"
echo ""
echo "Se intentará eliminar:"
echo "  • Agente Lab 1        : ${AGENT_ENGINE_ID:-<no definido>}"
echo "  • Agente baseline     : ${AGENT_BASELINE_ID:-<no definido>}"
echo "  • Template Model Armor: ${TEMPLATE_ID}"
echo "  • Agent Gateway       : ${GATEWAY_NAME}"
echo "  • Services Registry   : ${REGISTRY_AGENT}, ${MCP_NAME}"
[ "${REMOVE_BUCKET}" = "1" ] && echo "  • Bucket staging      : ${STAGING_BUCKET}"
echo ""
read -r -p "¿Continuar? [s/N] " ans
[[ "${ans}" =~ ^[sS]$ ]] || { echo "Cancelado."; exit 0; }
echo ""

# Agent Runtime (ex Agent Engine / reasoningEngines) no tiene grupo en gcloud → se borra por REST.
del_agent() {
  local id="$1" tok code
  [[ -z "${id}" ]] && { echo "ℹ️  (sin id de agente, se omite)"; return; }
  echo "▶️  Borrando agente ${id}..."
  tok="$(gcloud auth print-access-token 2>/dev/null)" || { echo "   ⚠️  sin token ADC"; return; }
  code="$(curl -s -o /dev/null -w '%{http_code}' -X DELETE \
    -H "Authorization: Bearer ${tok}" \
    "https://${LOCATION}-aiplatform.googleapis.com/v1beta1/projects/${PROJECT_ID}/locations/${LOCATION}/reasoningEngines/${id}?force=true")"
  case "${code}" in
    2*)  echo "   ✅ ${id} borrado" ;;
    404) echo "   ℹ️  ${id} no existe (se omite)" ;;
    *)   echo "   ⚠️  no se pudo borrar ${id} (HTTP ${code})" ;;
  esac
}

echo "── 1) Agent Runtime ──"
del_agent "${AGENT_ENGINE_ID}"
del_agent "${AGENT_BASELINE_ID}"

echo ""
echo "── 2) Model Armor ──"
if gcloud model-armor templates describe "${TEMPLATE_ID}" \
     --location="${LOCATION}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud model-armor templates delete "${TEMPLATE_ID}" \
    --location="${LOCATION}" --project="${PROJECT_ID}" --quiet \
    && echo "   ✅ template ${TEMPLATE_ID} borrado" || echo "   ⚠️  no se pudo borrar el template"
else
  echo "   ℹ️  template ${TEMPLATE_ID} no existe (se omite)"
fi

echo ""
echo "── 3) Agent Gateway ──"
if gcloud network-services agent-gateways describe "${GATEWAY_NAME}" \
     --project="${PROJECT_ID}" --location="${LOCATION}" >/dev/null 2>&1; then
  gcloud network-services agent-gateways delete "${GATEWAY_NAME}" \
    --project="${PROJECT_ID}" --location="${LOCATION}" --quiet \
    && echo "   ✅ gateway ${GATEWAY_NAME} borrado" || echo "   ⚠️  no se pudo borrar el gateway"
else
  echo "   ℹ️  gateway ${GATEWAY_NAME} no existe (se omite / o tu gcloud es viejo)"
fi

echo ""
echo "── 4) Agent Registry ──"
# El registro se hizo con `services create` → se borra con `services delete`.
if gcloud agent-registry services delete --help >/dev/null 2>&1; then
  for svc in "${REGISTRY_AGENT}" "${MCP_NAME}"; do
    gcloud agent-registry services delete "${svc}" \
      --project="${PROJECT_ID}" --location="${LOCATION}" --quiet 2>/dev/null \
      && echo "   ✅ service ${svc} eliminado" || echo "   ℹ️  ${svc} no estaba registrado"
  done
else
  echo "   ⚠️  grupo 'gcloud agent-registry' no disponible (actualiza la CLI: gcloud components update)"
fi

echo ""
echo "── 5) Bucket de staging ──"
if [ "${REMOVE_BUCKET}" = "1" ]; then
  gcloud storage rm -r "${STAGING_BUCKET}" --project="${PROJECT_ID}" --quiet \
    && echo "   ✅ bucket borrado" || echo "   ⚠️  no se pudo borrar el bucket"
else
  echo "   ℹ️  omitido (define REMOVE_BUCKET=1 si quieres borrar ${STAGING_BUCKET})"
fi

echo ""
echo "✅ Teardown terminado."
echo "   (Los IAM bindings del principalSet se dejan a propósito: son inocuos sin el agente.)"
