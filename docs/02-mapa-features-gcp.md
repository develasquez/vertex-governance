# Mapa de features — Gemini Enterprise Agent Platform (ex Vertex AI) · 2026

> Tabla de referencia rápida para arquitectos. Úsala como "cheat sheet" durante el workshop.
> **Nota**: los nombres de producto cambiaron en 2026 (Vertex AI → Gemini Enterprise Agent Platform).

## Leyenda de estado

- ✅ **GA** = General Availability (uso en producción)
- 🟡 **Preview** = disponibilidad previa, sujeta a cambios
- 📦 **Librería** = componente open source / librería, no servicio gestionado

---

## Pilar 1 — BUILD

| Feature | Qué es | Cuándo usarlo | Estado | Enlace |
|---|---|---|---|---|
| **Agent Development Kit (ADK)** | Framework open source code-first, model-agnóstico. Multi-agente, tools, sessions, workflows dinámicos. Lenguajes: Python, Go, Java, TypeScript, Kotlin. | Control total, arquitecturas custom. | 📦 | https://adk.dev/ |
| **Agent Studio** | Canvas visual low-code dentro de la plataforma. | Prototipado rápido, equipos de negocio. | ✅ | docs: `agent-studio` |
| **Agent Garden** | Librería de agentes/templates preconstruidos con one-click deploy. | Arrancar rápido. | ✅ | docs: `build/agent-garden` |
| **Managed Agents API** | Config-driven, REST-first. POST spec → Gemini construye y corre el agente en sandbox gestionado. | "Agent-as-a-service". | 🟡 | docs: `build/managed-agents` |
| **Interactions API** | Interfaz consistente para I/O multimodal (texto, audio, visual) a través de agentes. | Integración con apps cliente. | 🟡 | blog I/O '26 |
| **Skill Registry** | Catálogo central para gobernar y reutilizar "skills" (lógica de dominio empaquetada). | Reutilización y gobierno de capacidades. | 🟡 | docs: `build/skill-registry` |
| **RAG Engine** | Conecta datos privados a LLMs. Modos serverless y Spanner. | Reducir alucinaciones con datos propios. | ✅ | docs: `build/rag-engine` |
| **Vector Search 2.0 / Agent Retrieval** | Motor de búsqueda AI-native, embeddings autogenerados, reranking, MCP. | Retrieval de alta escala. | ✅ | docs: `build/vector-search-2` |
| **CodeMender** | Agente autónomo de seguridad de código: encuentra, verifica y corrige vulnerabilidades. | CI/CD de seguridad. | 🟡 | docs: `agents/codemender` |

## Pilar 2 — SCALE

| Feature | Qué es | Cuándo usarlo | Estado | Enlace |
|---|---|---|---|---|
| **Agent Runtime** (ex Agent Engine) | Runtime gestionado: escalado, cold starts sub-segundo, agentes de larga duración, revisiones y split de tráfico. | Desplegar agentes a producción. | ✅ | docs: `scale/runtime` |
| **Sessions** | Estado y contexto de una interacción (corto plazo). | Continuidad conversacional. | ✅ | docs: `scale/sessions` |
| **Memory Bank** | Memoria persistente entre sesiones (largo plazo), enfoque temático (ACL 2025). | Personalización, continuidad entre sesiones. | ✅ | docs: `scale/memory-bank` |
| **Code Execution** | Ejecución de Python en sandbox seguro. | Cálculos, análisis de datos. | ✅ | docs: `scale/sandbox/code-execution` |
| **Sandbox (shell, computer-use, BYOC)** | Entornos aislados; contenedores custom; computer use. | Automatización de UI, entornos controlados. | 🟡/✅ | docs: `scale/sandbox` |
| **Autonomous agent scheduling** | Ejecución programada de agentes. | Tareas periódicas autónomas. | 🟡 | docs: `scale/efficiency/autonomous-scheduling` |
| **Preços** | Runtime: $0.0864/vCPU-h (bajó desde $0.0994). Sessions/Memory/Code Exec con SKUs propios. | Estimación FinOps. | ✅ | blog governance 2025 |

## Pilar 3 — GOVERN ⭐

| Feature | Qué es | Cuándo usarlo | Estado | Enlace |
|---|---|---|---|---|
| **Agent Identity** | Identidad única por agente (SPIFFE ID `principal://...`), ligada a su ciclo de vida. mTLS + DPoP por defecto. | Least privilege y auditoría real. | ✅ | docs: `scale/runtime/agent-identity` |
| **Agent Registry** | Catálogo central de agentes, tools, MCP servers, endpoints y skills. Allowlist org. | Controlar qué herramientas existen y quién las usa. | ✅ | docs: `agent-registry` |
| **Agent Gateway** | Punto único de enforcement de red. Modos Client-to-Agent (ingress) y Agent-to-Anywhere (egress). | Todo el tráfico agéntico gobernado. | ✅ | docs: `govern/gateways` |
| **IAM Unified Access Policies + Principal Access Boundary** | Ligan identidad del agente a destinos aprobados. Default: todo bloqueado. | AuthZ determinista por agente. | ✅ | docs: `govern/policies` |
| **Semantic Governance Policies** | Reglas en lenguaje natural (NLC) sobre cómo el agente usa herramientas. | Reglas de negocio que no caben en IAM. | 🟡 | docs: `govern/policies/semantic-governance` |
| **Model Armor** | Filtros de contenido: prompt injection/jailbreak, PII (SDP), contenido dañino, CSAM, URLs maliciosas, docs e imágenes. | Blindaje de entrada y salida. | ✅ | https://cloud.google.com/security/products/model-armor |
| **Model Armor floor settings** | Baselines mínimos de protección a nivel proyecto. | Política de seguridad corporativa. | ✅ | docs: `model-armor/configure-floor-settings` |
| **AI Threat & Vulnerability Scanning** | Amenazas y vulnerabilidades específicas de agentes (SCC). | Postura de seguridad continua. | ✅ | docs: `govern/view-security-findings` |
| **Agent Anomaly Detection** | Lee logs y trazas OTel para detectar comportamiento fuera de límites. | Detección de deriva / abuso en runtime. | 🟡 | blog developers |
| **Agent Registry / Topology graphs** | Grafos de topología de agentes y tráfico. | Visibilidad de dependencias. | 🟡 | docs: `govern/topology` |

## Pilar 4 — OPTIMIZE ⭐

| Feature | Qué es | Cuándo usarlo | Estado | Enlace |
|---|---|---|---|---|
| **Agent Evaluation** | Evalúa calidad, seguridad y tareas con autoraters (Task Success, Safety). | Medir calidad real. | ✅ | docs: `optimize/evaluation/agent-evaluation` |
| **Scenario generation + User Simulation** | Genera escenarios multi-turno y simula usuarios (personas). | Empezar a testear sin dataset. | ✅ | docs: `optimize/evaluation/evaluate-simulated` |
| **Environment simulation** | Intercepta tool calls para inyectar errores/latencia. | Probar resiliencia. | 🟡 | docs: `optimize/evaluation/evaluate-offline` |
| **Online Monitors** | Evaluación continua sobre tráfico real. | Guardia de calidad en producción. | 🟡 | docs: `optimize/evaluation/evaluate-online` |
| **Observability / Unified Trace Viewer** | Trazas end-to-end (model calls, tool calls, decisiones). | Debug y análisis de regresiones. | ✅ | docs: `optimize/observability` |
| **Prompt Optimization** (`adk optimize`) | Aplica algoritmo GEPA para refinar instrucciones del root agent. | Mejorar prompts automáticamente. | 📦 | https://adk.dev/optimize/ |
| **Example Store** | Almacena ejemplos few-shot. | Mejorar in-context learning. | 🟡 | docs: `optimize/example-store` |
| **Context Caching** | Implícito (auto, ~90% dto en hits) y explícito (control, TTL). | Reducir costo/latencia con contexto repetido. | ✅ | docs: `models/context-cache` |

---

## Tabla de equivalencias de nombres (Vertex AI → 2026)

| Antes (Vertex AI) | Ahora (Gemini Enterprise Agent Platform) |
|---|---|
| Vertex AI | Gemini Enterprise Agent Platform |
| Vertex AI Agent Builder | Gemini Enterprise Agent Platform (Agents) |
| Agent Engine | Agent Runtime |
| Gen AI Evaluation Service | Agent Platform Evaluation (client.evals) |
| Vertex AI Memory Bank | Agent Platform Memory Bank |
| Vertex AI Session Service | Agent Platform Sessions |

---

## Cómo elegir el "rung" correcto (de la escalera de construcción)

Google modela la construcción de agentes como **4 rungs**, deliberadamente aditivos:

1. **Agent Studio** (low-code) — prototipado visual.
2. **Managed Agents API** — config-first, agent-as-a-service.
3. **Antigravity y amigos** — coding agents para desarrollo/orquestación.
4. **ADK 2.0** (engineering-first) — control total, cualquier modelo, cualquier arquitectura.

> Regla práctica: **empieza bajo y sube de rung cuando necesites control**, no antes. Un agente
> hecho en rung 1 puede llamarse como subagente en rung 4 vía **A2A protocol**.
