#!/usr/bin/env bash
# Lab 4 — Gobierno runtime: Agent Identity + Agent Registry + Agent Gateway.
#
# EJECUCIÓN DIRECTA: corre los comandos de verdad (idempotente: no recrea lo que ya existe).
#
#   ./governance_setup.sh          # ejecuta
#   ./governance_setup.sh --help   # ayuda
#
# Requiere: PROJECT_ID (y opcional AGENT_ENGINE_ID del Lab 1).
# Docs:
#   https://docs.cloud.google.com/gemini-enterprise-agent-platform/govern/gateways/set-up-agent-gateway
#   https://docs.cloud.google.com/agent-registry/overview
#   https://docs.cloud.google.com/gemini-enterprise-agent-platform/scale/runtime/agent-identity
#
# ⚠️ Agent Registry y Agent Gateway requieren una CLI reciente. Si falta algún grupo, el script
#    lo detecta y te dice cómo habilitarlo (no aborta). La identidad (paso 1) usa REST como fallback.
set -euo pipefail

# Carga automática del .env del Lab 0 (si existe).
ENV_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/../lab-00-setup" && pwd)/.env"
if [ -f "${ENV_FILE}" ]; then
  set -a; set +u
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set -u; set +a
fi

# --------------------------------------------------------------------------- #
# Configuración
# --------------------------------------------------------------------------- #
PROJECT_ID="${PROJECT_ID:?Define PROJECT_ID — crea labs/lab-00-setup/.env con 'cp .env.example .env'}"
LOCATION="${LOCATION:-us-central1}"
AGENT_ENGINE_ID="${AGENT_ENGINE_ID:-}"
GATEWAY_NAME="${GATEWAY_NAME:-gdg-agent-gateway}"
REGISTRY_AGENT="${REGISTRY_AGENT:-gdg-support-agent}"
MCP_NAME="${MCP_NAME:-internal-crm-mcp}"
MCP_URI="${MCP_URI:-https://mcp.internal.example.com}"
AGENT_URL="${AGENT_URL:-}"

# --------------------------------------------------------------------------- #
# Ayuda
# --------------------------------------------------------------------------- #
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Lab 4 — Gobierno runtime: Agent Identity + Agent Registry + Agent Gateway.

Uso:
  ./governance_setup.sh     ejecuta los comandos (idempotente).

Variables de entorno:
  PROJECT_ID        (obligatoria) tu proyecto GCP.
  LOCATION          (opcional) región, por defecto us-central1.
  AGENT_ENGINE_ID   (opcional) id del agente del Lab 1 (para la identidad y el registro).
  AGENT_URL         (opcional) URL del agente para el registro (por defecto, el endpoint del Lab 1).
  MCP_URI           (opcional) URL del MCP server aprobado.

Orden que ejecuta: APIs → Identidad → Registry → Gateway.
EOF
  exit 0
fi

# --------------------------------------------------------------------------- #
# Helpers
# --------------------------------------------------------------------------- #
cmd_ok() { gcloud "$@" --help >/dev/null 2>&1; }
step() { echo ""; echo "───────────────────────────────────────────────"; echo "$1"; echo "───────────────────────────────────────────────"; }
GCLOUD_VERSION="$(gcloud --version 2>/dev/null | sed -n 's/^Google Cloud SDK //p' | head -1)"
[ -z "${GCLOUD_VERSION}" ] && GCLOUD_VERSION="$(gcloud --version 2>/dev/null | head -1)"

# Lee la identidad efectiva (principal SPIFFE) del agente.
#   1) Si el componente 'alpha' está instalado, usa `gcloud alpha ai reasoning-engines describe`.
#   2) Si no, cae a REST (v1beta1) — sin alpha y sin venv.
effective_identity() {
  local tok
  if cmd_ok alpha; then
    gcloud alpha ai reasoning-engines describe "${AGENT_ENGINE_ID}" \
      --project="${PROJECT_ID}" --location="${LOCATION}" \
      --format='value(spec.effectiveIdentity)' 2>/dev/null && return 0
  fi
  tok="$(gcloud auth print-access-token 2>/dev/null)" || return 1
  curl -s -H "Authorization: Bearer ${tok}" \
    "https://${LOCATION}-aiplatform.googleapis.com/v1beta1/projects/${PROJECT_ID}/locations/${LOCATION}/reasoningEngines/${AGENT_ENGINE_ID}" \
    | python3 -c "import sys,json; print(json.load(sys.stdin).get('spec',{}).get('effectiveIdentity',''))" 2>/dev/null
}

# --------------------------------------------------------------------------- #
# Derivar identificadores
# --------------------------------------------------------------------------- #
PROJECT_NUMBER="$(gcloud projects describe "${PROJECT_ID}" --format='value(projectNumber)' 2>/dev/null || true)"
# ⚠️ El organization id NO es el `parent` directo (puede ser un folder). Subimos por los ancestros.
ORG_ID="$(gcloud projects get-ancestors "${PROJECT_ID}" --format='value(type,id)' 2>/dev/null \
          | awk '$1=="organization"{print $2; exit}' || true)"

# URL del agente para el registro (por defecto, el endpoint del Lab 1).
if [[ -z "${AGENT_URL}" ]]; then
  if [[ -n "${AGENT_ENGINE_ID}" ]]; then
    AGENT_URL="https://${LOCATION}-aiplatform.googleapis.com/v1beta1/projects/${PROJECT_ID}/locations/${LOCATION}/reasoningEngines/${AGENT_ENGINE_ID}"
  else
    AGENT_URL="https://example.com/agent"
  fi
fi

echo "🏛️  Gobierno runtime — ${PROJECT_ID} (nº ${PROJECT_NUMBER:-?}) · ${LOCATION}"
echo "ℹ️  Organización: ${ORG_ID:-<sin organización>}"
echo "ℹ️  gcloud: ${GCLOUD_VERSION:-?}"

if [[ -n "${ORG_ID}" ]]; then
  TRUST_DOMAIN="agents.global.org-${ORG_ID}.system.id.goog"
elif [[ -n "${PROJECT_NUMBER}" ]]; then
  TRUST_DOMAIN="agents.global.proj-${PROJECT_NUMBER}.system.id.goog"
else
  TRUST_DOMAIN=""
fi

MISSING_TOOLS=0   # para el resumen final

# --------------------------------------------------------------------------- #
# 0) APIs necesarias (idempotente)
# --------------------------------------------------------------------------- #
step "0️⃣  APIs necesarias — registry + gateway"
echo "▶️  Habilitando (idempotente): agentregistry, networkservices, networksecurity, iap…"
if gcloud services enable \
     agentregistry.googleapis.com networkservices.googleapis.com \
     networksecurity.googleapis.com iap.googleapis.com \
     --project="${PROJECT_ID}" >/dev/null 2>&1; then
  echo "   ✅ APIs habilitadas"
else
  echo "   ⚠️  No pude habilitar alguna API (revisa permisos de serviceusage). Continúo."
fi

# --------------------------------------------------------------------------- #
# 1) AGENT IDENTITY
# --------------------------------------------------------------------------- #
step "1️⃣  AGENT IDENTITY — identidad del agente y permisos base"

if [[ -n "${AGENT_ENGINE_ID}" ]]; then
  echo "▶️  Identidad efectiva del agente:"
  EFFECTIVE_IDENTITY="$(effective_identity || true)"
  if [[ -n "${EFFECTIVE_IDENTITY}" ]]; then
    echo "   ${EFFECTIVE_IDENTITY}"
    # Fuente de verdad: el trust domain viene DENTRO de la identidad real del agente.
    TRUST_DOMAIN="${EFFECTIVE_IDENTITY%%/resources/*}"
    echo "   ↳ trust domain (de la identidad): ${TRUST_DOMAIN}"
  else
    echo "   ⚠️  No pude leerla. Instala el componente alpha ('gcloud components install alpha')"
    echo "       o revisa permisos/ADC. Uso el trust domain derivado: ${TRUST_DOMAIN:-?}"
  fi
else
  echo "⚠️  AGENT_ENGINE_ID no definido: se omite la inspección de identidad del agente."
  echo "    (Corre ../lab-01-agente-adk/deploy.py y exporta AGENT_ENGINE_ID.)"
fi

if [[ -z "${PROJECT_NUMBER}" || -z "${TRUST_DOMAIN}" ]]; then
  echo "⚠️  Faltan número de proyecto o trust domain; se omite el otorgamiento de roles base."
else
  AGENTS_PRINCIPAL_SET="principalSet://${TRUST_DOMAIN}/attribute.platformContainer/aiplatform/projects/${PROJECT_NUMBER}"
  echo "▶️  Otorgando roles base a TODOS los agentes del proyecto (el principalSet sobrevive redeploys):"
  echo "   member: ${AGENTS_PRINCIPAL_SET}"
  for role in \
    roles/aiplatform.expressUser \
    roles/serviceusage.serviceUsageConsumer \
    roles/cloudapiregistry.viewer \
    roles/logging.logWriter \
    roles/monitoring.metricWriter; do
    echo "   → ${role}"
    gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
      --member="${AGENTS_PRINCIPAL_SET}" \
      --role="${role}" \
      --condition=None >/dev/null
  done
  echo "   ✅ roles base aplicados"
fi

# --------------------------------------------------------------------------- #
# 2) AGENT REGISTRY
# --------------------------------------------------------------------------- #
step "2️⃣  AGENT REGISTRY — allowlist de destinos aprobados"

# El registro se hace con `services create` (los recursos Agent/McpServer son read-only).
# protocolBinding válidos: grpc | http-json | jsonrpc | protocol-binding-unspecified.
#   - Agente  → http-json
#   - MCP server → jsonrpc  (MCP habla JSON-RPC)
if cmd_ok agent-registry services create; then
  if gcloud agent-registry services describe "${REGISTRY_AGENT}" \
       --location="${LOCATION}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
    echo "ℹ️  El servicio ${REGISTRY_AGENT} ya existe (se omite)."
  else
    echo "▶️  Registrando agente: ${REGISTRY_AGENT}"
    gcloud agent-registry services create "${REGISTRY_AGENT}" \
      --location="${LOCATION}" --project="${PROJECT_ID}" \
      --display-name="Agente de soporte GDG" \
      --agent-spec-type=no-spec \
      --interfaces="url=${AGENT_URL},protocolBinding=http-json"
  fi

  if gcloud agent-registry services describe "${MCP_NAME}" \
       --location="${LOCATION}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
    echo "ℹ️  El servicio ${MCP_NAME} ya existe (se omite)."
  else
    echo "▶️  Registrando MCP server aprobado: ${MCP_NAME}"
    gcloud agent-registry services create "${MCP_NAME}" \
      --location="${LOCATION}" --project="${PROJECT_ID}" \
      --display-name="MCP CRM interno" \
      --mcp-server-spec-type=no-spec \
      --interfaces="url=${MCP_URI},protocolBinding=jsonrpc"
  fi
else
  MISSING_TOOLS=1
  echo "⚠️  'gcloud agent-registry' no existe en tu gcloud (${GCLOUD_VERSION:-?})."
  echo "    Actualiza la CLI:  gcloud components update"
  echo "    Doc: https://docs.cloud.google.com/agent-registry/overview"
fi

# --------------------------------------------------------------------------- #
# 3) AGENT GATEWAY
# --------------------------------------------------------------------------- #
step "3️⃣  AGENT GATEWAY — punto de enforcement (egress)"

if cmd_ok network-services agent-gateways import; then
  if gcloud network-services agent-gateways describe "${GATEWAY_NAME}" \
       --location="${LOCATION}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
    echo "ℹ️  El gateway ${GATEWAY_NAME} ya existe (se omite creación)."
  else
    YAML_FILE="$(mktemp -t agent-gateway.XXXXXX.yaml)"
    cat > "${YAML_FILE}" <<EOF
name: ${GATEWAY_NAME}
protocols:
  - MCP
googleManaged:
  governedAccessPath: AGENT_TO_ANYWHERE
registries:
  - //agentregistry.googleapis.com/projects/${PROJECT_ID}/locations/${LOCATION}
EOF
    echo "▶️  Creando gateway ${GATEWAY_NAME} (Agent-to-Anywhere / egress)…"
    gcloud network-services agent-gateways import "${GATEWAY_NAME}" \
      --source="${YAML_FILE}" --location="${LOCATION}" --project="${PROJECT_ID}" \
      || echo "   ⚠️  No se pudo crear (¿APIs habilitadas? ¿permisos? ¿registry existe?)"
    rm -f "${YAML_FILE}"
  fi
  echo "   (modo egress · registries: //agentregistry.googleapis.com/projects/${PROJECT_ID}/locations/${LOCATION})"
else
  MISSING_TOOLS=1
  echo "⚠️  'gcloud network-services agent-gateways' no existe en tu gcloud (${GCLOUD_VERSION:-?})."
  echo "    Actualiza la CLI:  gcloud components update"
  echo "    Doc: https://docs.cloud.google.com/gemini-enterprise-agent-platform/govern/gateways/set-up-agent-gateway"
fi

echo "   → Siguientes pasos (dependen de tu red; ver doc):"
echo "       • Adjuntar IAM Unified Access Policy (liga identidad → destinos del Registry)."
echo "       • Adjuntar Model Armor al gateway (guardrails de contenido)."
echo "       • (Opcional) Semantic Governance policy en lenguaje natural."
echo "       • Rutear el tráfico de Agent Runtime por el gateway."

# --------------------------------------------------------------------------- #
# Cierre
# --------------------------------------------------------------------------- #
step "✅ FIN"
if [[ "${MISSING_TOOLS}" -eq 1 ]]; then
  echo "⚠️  Faltan herramientas en la CLI para los pasos 2/3. Para habilitarlas:"
  echo "       gcloud components update           # trae 'agent-registry' y 'network-services agent-gateways'"
  echo ""
fi
echo "Resumen de recursos gobernados:"
echo "   • Identidad : ${TRUST_DOMAIN:-?}"
echo "              ↳ principalSet para roles base (sobrevive redeploys)"
echo "   • Registry  : services/${REGISTRY_AGENT}, services/${MCP_NAME}   (location=${LOCATION})"
echo "   • Gateway   : agentGateways/${GATEWAY_NAME}                      (egress, AGENT_TO_ANYWHERE)"
echo ""
echo "Verifica el tráfico egress del agente en:"
echo "   Console → Agent Platform → Govern → Agent Gateway → Monitor"
echo "   Console → Optimize → Observability (trazas)"
echo "Orden lógico del gobierno: Identidad → Registry → Políticas → Gateway."
