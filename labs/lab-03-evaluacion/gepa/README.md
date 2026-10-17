# Demo ejecutable de GEPA — `adk optimize`

Ejemplo **autocontenido y reproducible** de refinamiento de instrucciones con **GEPA**
(*Genetic-Pareto*, el optimizador que trae ADK 2.x). Vive aquí, en el **Lab 3 (Evaluación)**,
porque el refinamiento es la última fase del *Quality Flywheel*:

```
Design → Execution → Scoring → Refinement → (repeat)
```

```
gepa/
├── support_agent/                 # carpeta del agente (nombre válido => app_name)
│   ├── __init__.py                #   expone el módulo `agent`
│   ├── agent.py                   #   root_agent (mínimo, con 1 tool)
│   └── basic.evalset.json         #   eval set: 3 casos (formato legacy ADK)
├── sampler_config.json            # LocalEvalSamplerConfig (eval_config + eval set)
├── optimizer_config.json          # GEPARootAgentPromptOptimizerConfig (tope de evaluaciones)
├── run_gepa.sh                    # wrapper de bash → delega en run_gepa.py
├── run_gepa.py                    # launcher: importa las variables y llama a `adk optimize`
└── README.md                      # este archivo
```

## Cómo correrlo

```bash
cd labs/lab-03-evaluacion/gepa
./run_gepa.sh          # ~2-3 minutos
```

> 🧩 **Reutiliza el venv del Lab 1** (que ya trae ADK 2.x + los extras de evaluación) e **importa
> las variables necesarias** desde el loader compartido `labs/_env.py` — no duplica configuración.
> El `run_gepa.py` (que corre con el python del Lab 1) llama a `adk optimize` del venv del Lab 1.

## Qué hace exactamente

1. Toma la **instrucción pobre** del `root_agent` (*"Eres un agente de soporte. Responde a lo que
   pida el usuario."*).
2. Evalúa el agente contra `basic.evalset.json` (3 casos) con dos métricas:
   - `tool_trajectory_avg_score` (¿llamó a `get_order_status` con los argumentos correctos?),
   - `response_match_score` (similitud ROUGE con la respuesta de referencia, umbral 0.8).
3. **Reflexiona** sobre los resultados (modelo `gemini-2.5-flash`) y **muta** la instrucción.
4. Repite hasta agotar `max_metric_calls` y devuelve la mejor instrucción.

## Resultado observado

```
Optimized root agent instructions:
  Eres un agente de soporte. [...] Para cada consulta de estado de pedido, DEBES utilizar la
  herramienta `get_order_status` con el `order_id` [...] formula la respuesta [...] siguiendo
  ESTRICTAMENTE [...] `Estado de [order_id]: [status]. ETA: [eta].` [...]

val_aggregate_scores: [0.0, 1.0]   # [baseline, optimizado]
best_idx: 1
```

GEPA pasó de **0.0 → 1.0** en validación, descubriendo por sí solo el formato exacto que estaba
codificado en las referencias del eval set.

## Archivos clave

### `sampler_config.json`
```json
{
  "app_name": "support_agent",
  "train_eval_set": "basic",
  "eval_config": { "criteria": { "tool_trajectory_avg_score": 1.0, "response_match_score": 0.8 } }
}
```

### `optimizer_config.json`
```json
{ "optimizer_model": "gemini-2.5-flash", "max_metric_calls": 20, "reflection_minibatch_size": 2 }
```

⚠️ **`max_metric_calls` = número de evaluaciones reales.** Cada unidad es una corrida del agente
+ métricas → **consume cuota y tiempo**. Por defecto ADK usa `100`; aquí lo bajamos a `20`.

## Requisitos previos

- Venv del **Lab 1** con ADK 2.x y el extra de evaluación:
  ```bash
  cd labs/lab-01-agente-adk
  python3 -m venv .venv && source .venv/bin/activate
  pip install -r requirements.txt
  pip install "google-adk[eval]"      # gepa + nltk + rouge-score (para `adk optimize`)
  ```
- `.env` del Lab 0 (`labs/lab-00-setup/.env`) y ADC (`gcloud auth application-default login`).
  El launcher lo carga solo (vía `labs/_env.py`).

## Cómo adaptarlo a *tu* agente

Reemplaza `support_agent/agent.py` por una versión reducida de tu agente (evita subagentes,
memoria y búsqueda para que la corrida sea rápida) y ajusta `basic.evalset.json` con tus casos y
referencias. Cuanto más **estricto** sea el formato de las referencias, más margen tendrá GEPA para
mejorar.
