# Bibliografía y recursos — Workshop Gobierno y Optimización de agentes en GCP

> Fuentes oficiales consultadas en **octubre 2026**. Verifica siempre contra la documentación vigente.

## Panorama de la plataforma (Build / Scale / Govern / Optimize)

- **Agent Platform overview** — la figura de los 4 pilares y el mapa completo.
  https://docs.cloud.google.com/gemini-enterprise-agent-platform/overview
- **What Google I/O '26 means for developing agents on Google Cloud** — los 4 rungs, Managed Agents API, ADK 2.0, Agents CLI.
  https://cloud.google.com/blog/topics/developers-practitioners/io26-news-for-agent-developers-on-google-cloud
- **Announcing advanced governance capabilities for Vertex AI Agent Builder** (dic. 2025) — tool governance con Cloud API Registry, GA de Sessions/Memory Bank, precios de Agent Engine.
  https://cloud.google.com/blog/products/ai-machine-learning/new-enhanced-tool-governance-in-vertex-ai-agent-builder
- **Vertex AI Agent Builder: 2026 guide** — guía de tercero útil con los 4 pilares.
  https://uibakery.io/blog/vertex-ai-agent-builder

## Build

- **Agent Development Kit (ADK)** — documentación oficial.
  https://adk.dev/ · https://docs.cloud.google.com/gemini-enterprise-agent-platform/build/adk
- **Build zero-trust AI agents with Google's ADK** — blog de developers.
  https://developers.googleblog.com/build-zero-trust-ai-agents-with-googles-agent-development-kit/
- **Next '26 codelab: Building ADK Agents with Skills and Tools**.
  https://codelabs.developers.google.com/next26/dev-keynote/building-agents-with-skills
- **Managed Agents API** — docs.
  https://docs.cloud.google.com/gemini-enterprise-agent-platform/build/managed-agents
- **Skill Registry** (preview).
  https://docs.cloud.google.com/gemini-enterprise-agent-platform/build/skill-registry
- **Agent Garden** · **RAG Engine** · **Vector Search 2.0**.
  docs: `build/agent-garden`, `build/rag-engine/rag-overview`, `build/vector-search-2/overview`

## Scale

- **Agent Runtime** (ex Agent Engine) — deploy, revisiones, tráfico.
  https://docs.cloud.google.com/gemini-enterprise-agent-platform/scale/runtime/deploy-an-agent
- **Sessions** · **Memory Bank** (GA).
  docs: `scale/sessions`, `scale/memory-bank`
- **Precios Agent Engine** (tabla de cambio de precios dic. 2025 / ene. 2026).
  https://cloud.google.com/vertex-ai/pricing#vertex-ai-agent-engine

## Govern

- **Agent Gateway overview** — modos ingress/egress, componentes de gobierno.
  https://docs.cloud.google.com/gemini-enterprise-agent-platform/govern/gateways/agent-gateway-overview
- **Use Agent Identity with Agent Runtime** — SPIFFE IDs, IAM, PAB, CAA/mTLS/DPoP.
  https://docs.cloud.google.com/gemini-enterprise-agent-platform/scale/runtime/agent-identity
- **Agent Registry overview**.
  https://docs.cloud.google.com/agent-registry/overview
- **Semantic Governance policies overview**.
  https://docs.cloud.google.com/gemini-enterprise-agent-platform/govern/policies/semantic-governance-overview
- **Give Your AI Agent a Security Policy in Plain English with Semantic Governance** (Medium).
  https://medium.com/google-cloud/give-your-ai-agent-a-security-policy-in-plain-english-with-semantic-governance-872718e6325a
- **Model Armor overview** — filtros, templates, umbrales, enforcement, floor settings.
  https://docs.cloud.google.com/model-armor/overview
- **Model Armor (producto)**.
  https://cloud.google.com/security/products/model-armor
- **Codelab: Building a secure agent system with Model Armor** — el mejor hands-on end-to-end.
  https://codelabs.developers.google.com/secure-agent-modelarmor
- **Testing Google Cloud Model Armor with Promptfoo** — ejemplos YAML de red team.
  https://www.promptfoo.dev/docs/guides/google-cloud-model-armor/
- **View security findings** (SCC: Vulnerability Assessment, AI threats).
  https://docs.cloud.google.com/gemini-enterprise-agent-platform/govern/view-security-findings
- **Agent Anomaly Detection** (Private Preview) — blog de developers.
  https://developers.googleblog.com/agent-anomaly-detection-now-in-private-preview-on-the-gemini-enterprise-agent-platform/
- **Codelab: Govern agentic workloads with Agent Platform**.
  https://codelabs.developers.google.com/cloudnet-agent-gateway

## Optimize

- **Agent evaluation** — fases (Design/Execution/Scoring/Refinement), capacidades.
  https://docs.cloud.google.com/gemini-enterprise-agent-platform/optimize/evaluation/agent-evaluation
- **Gen AI evaluation service overview** (client.evals).
  https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/evaluation-overview
- **Introducing agent evaluation in Vertex AI Gen AI evaluation service** (blog).
  https://cloud.google.com/blog/products/ai-machine-learning/introducing-agent-evaluation-in-vertex-ai-gen-ai-evaluation-service
- **Optimize agent prompts** — Quality Flywheel + algoritmo GEPA.
  https://docs.cloud.google.com/gemini-enterprise-agent-platform/optimize/evaluation/optimize-agent
  https://adk.dev/optimize/
- **Observability / View agent traces** (Unified Trace Viewer).
  https://docs.cloud.google.com/gemini-enterprise-agent-platform/optimize/observability/overview
  https://docs.cloud.google.com/gemini-enterprise-agent-platform/optimize/observability/traces
- **Context caching overview** — implícito vs explícito, límites, costos.
  https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/context-cache/context-cache-overview
- **Vertex AI context caching** (blog) — descuento 90% en Gemin 2.5+.
  https://cloud.google.com/blog/products/ai-machine-learning/vertex-ai-context-caching

## Notebooks y repos útiles

- **GoogleCloudPlatform/generative-ai** (notebooks de eval).
  https://github.com/GoogleCloudPlatform/generative-ai
- **Notebook: Multi-Turn Agent Evaluation with User Simulation, Metric Registration, and Auto Loss Analysis**.
  (link en la doc de `optimize/evaluation/agent-evaluation`)
- **adk-samples** — ejemplos oficiales de ADK.
  https://github.com/google/adk-samples
- **Agent Starter Pack** — plantilla production-ready.
  https://googlecloudplatform.github.io/agent-starter-pack/
- **google/skills** — skills para coding agents (eval, cloud).
  https://github.com/google/skills

## Modelos y capacidades

- **Gemini 3 Pro / Flash** — modelos insignia para agentes.
  https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/3-pro
- **A2A protocol (Agent2Agent)** — interoperabilidad entre agentes.
  https://google.github.io/A2A/ · https://a2a-protocol.org/latest/
