# Workshop: Gobierno de agentes en GCP y Optimización de agentes en Vertex

> **GDG Cloud Santiago** · Sesión hands-on de ~3 horas · Audiencia mixta (developers + arquitectos)
> Última actualización del material: **octubre 2026**

Este repositorio contiene todo el material del workshop: el diseño pedagógico, el mapa de
features de Google Cloud a 2026, y **cuatro laboratorios hands-on con código ejecutable**.

---

## ⚠️ Antes de empezar: el cambio de nombre que lo cambia todo

En 2026 Google renombró **Vertex AI → Gemini Enterprise Agent Platform**. El producto sigue
siendo el mismo, pero ahora está organizado en **4 pilares** que son la columna vertebral
de este workshop:

| Pilar | Qué cubre | Features clave |
|---|---|---|
| **Build** | Construir agentes | ADK, Agent Studio, Agent Garden, Managed Agents API, RAG Engine, Vector Search |
| **Scale** | Desplegar y operar | **Agent Runtime (ex Agent Engine)**, Sessions, Memory Bank, Code Execution, Sandbox |
| **Govern** | Seguridad y control | **Agent Identity**, **Agent Registry**, **Agent Gateway**, **Policies**, **Model Armor**, Threat Scan |
| **Optimize** | Calidad y eficiencia | **Agent Evaluation**, User Simulation, Online Monitors, Observability (Unified Traces), Prompt Optimization, Example Store |

Términos que cambiaron y que verás en el material: *Agent Engine → Agent Runtime*,
*Vertex AI Agent Builder → Gemini Enterprise Agent Platform*, *Gen AI Evaluation Service →
Agent Platform Evaluation*. Usamos el nombre nuevo con el antiguo entre paréntesis cuando ayuda.

---

## 📁 Estructura del repositorio

```
vertex-gobern/
├── README.md                        ← estás aquí (índice general)
├── teardown.sh                      ← borra los recursos del workshop (evita cargos)
├── docs/
│   ├── 00-documento-maestro.md      ← diseño completo del workshop (objetivos, narrativa, agenda)
│   ├── 01-agenda.md                 ← agenda minuto a minuto para las 3 horas
│   ├── 02-mapa-features-gcp.md      ← tabla de referencia: pilar → feature → cuándo usar
│   └── 03-slides-outline.md         ← guion de slides (título/bajada/foco por slide)
├── labs/
│   ├── README.md                    ← índice de labs + instrucciones de ambiente
│   ├── lab-00-setup/                ← preparar proyecto, APIs y credenciales
│   ├── lab-01-agente-adk/           ← construir un agente con ADK y desplegarlo en Agent Runtime
│   ├── lab-02-model-armor/          ← guardrails: sanear prompts/respuestas (prompt injection, PII)
│   ├── lab-03-evaluacion/           ← evaluar el agente (metricas, AutoRaters, user simulation)
│   └── lab-04-gobierno-gateway/     ← gobierno runtime: Identity + Registry + Gateway + Policies
└── recursos/
    └── bibliografia.md              ← todas las fuentes oficiales con enlaces
```

---

## 🚀 Cómo usar este material

**Si vas a dar el workshop (instructor/a):**
1. Lee `docs/00-documento-maestro.md` completo — es el guion pedagógico.
2. Sigue `docs/01-agenda.md` para los tiempos.
3. Ejecuta los labs tú mismo/a primero en un proyecto limpio (`labs/README.md`).
4. Usa `docs/03-slides-outline.md` para montar las slides.

**Si eres asistente (participante):**
1. Empieza por `labs/lab-00-setup/` para preparar tu entorno.
2. Luego lab-01 → lab-02 → lab-03 → lab-04 en orden.

**Si solo quieres el panorama técnico:**
- Lee `docs/02-mapa-features-gcp.md` (tabla de referencia rápida).

---

## 🧹 Limpieza (importante)

El workshop **deja recursos vivos** y facturables: un agente en **Agent Runtime**, una plantilla de
**Model Armor**, un **Agent Gateway** y registros en **Agent Registry**. Al terminar, bórralos:

```bash
./teardown.sh          # lee labs/lab-00-setup/.env automáticamente; pide confirmación
```

> Define además `REMOVE_BUCKET=1` si quieres borrar también el bucket de staging.

---

## 🎯 Objetivos del workshop

Al terminar, cada participante será capaz de:

1. **Explicar** la arquitectura de la Gemini Enterprise Agent Platform y sus 4 pilares.
2. **Construir y desplegar** un agente con Agent Development Kit (ADK) sobre Agent Runtime.
3. **Aplicar gobierno runtime**: Agent Identity (SPIFFE), Agent Registry, Agent Gateway y políticas.
4. **Blindar** un agente contra prompt injection, fuga de datos y contenido dañino con **Model Armor**.
5. **Evaluar** la calidad de un agente (Task Success, Safety, traysectorias) con autoraters y simulación de usuario.
6. **Optimizar** costo/calidad: context caching, prompt optimization y observabilidad con trazas unificadas.

---

## 🧰 Prerrequisitos

- Cuenta de Google Cloud con un proyecto (ver `labs/lab-00-setup/`).
- Python 3.11+ y `gcloud`/`gcloud beta` CLI.
- Familiaridad básica con Python. No se requiere experiencia previa en Vertex AI.
- (Recomendado) ganas de romper un agente a propósito para ver los guardrails actuar.

---

## 🤝 Créditos y uso

Material educativo para la comunidad **GDG Cloud Santiago**. Los features y APIs de Google Cloud
cambian rápido: cada documento incluye enlaces a la documentación oficial vigente en
`recursos/bibliografia.md`. Verifica siempre contra la documentación antes de usarlo en producción.
