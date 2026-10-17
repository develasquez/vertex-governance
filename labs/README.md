# Laboratorios hands-on

Cuatro labs progresivos que construyen **un mismo agente**, capa por capa: primero lo construyes y
despliegas, luego lo blindas y lo gobiernas, y al final lo evalúas y optimizas.

| Lab | Título | Qué lograrás | Tiempo |
|---|---|---|---|
| **0** | Setup | Proyecto, APIs, credenciales y bucket listos. | 10 min |
| **1** | Agente ADK + deploy con identidad | Un agente corriendo en Agent Runtime con **Agent Identity**. | 30 min |
| **2** | Guardrails con Model Armor | Un template que bloquea prompt injection y PII. | 20 min |
| **3** | Evaluación del agente | Un scorecard con Task Success y Safety + fallas agrupadas. | 25 min |
| **4** | Gobierno runtime (Gateway + Registry) | Tráfico del agente gobernado por Agent Gateway. | 15 min |

> ⚠️ **Aviso de APIs en evolución.** Estamos en 2026 y la plataforma renombró Vertex AI →
> Gemini Enterprise Agent Platform. Algunos SDKs cambian de nombre rápido (`vertexai` →
> `agentplatform`, nombres de métodos, flags). El código de los labs es una plantilla **funcional de
> referencia**: si un import o parámetro falla, revisa la doc enlazada en `recursos/bibliografia.md`
> y ajústalo. La lógica y los conceptos se mantienen.

---

## Prerrequisitos comunes

- Python **3.11+**
- Google Cloud CLI (`gcloud`) con `gcloud beta` disponible
- `pip` y (recomendado) un entorno virtual
- Acceso a un proyecto GCP con billing **o** Starter Tier

## Orden recomendado

```
lab-00-setup  →  lab-01-agente-adk  →  lab-02-model-armor  →  lab-03-evaluacion  →  lab-04-gobierno-gateway
```

Los labs 2, 3 y 4 **reutilizan el agente** creado en el Lab 1 (o el agente de respaldo del instructor).

## Variables de entorno compartidas

Todos los labs usan estas variables. **Crea una sola vez `labs/lab-00-setup/.env`**
(`cp .env.example .env` y edítalo) y listo: **los scripts `.sh` y `.py` lo cargan automáticamente** —
no necesitas `source .env`.

```bash
export PROJECT_ID="tu-proyecto-gcp"
export LOCATION="us-central1"
export STAGING_BUCKET="gs://${PROJECT_ID}-agent-staging"
export AGENT_ENGINE_ID=""   # se rellena tras el Lab 1
```

> 🐍 **macOS / Linux sin alias:** usa `python3` (en macOS el comando `python` no existe por defecto).
> Para los labs con venv, créalo con `python3 -m venv .venv`.

## Estructura de cada lab

Cada carpeta contiene:

- `README.md` — objetivo, pasos, puntos de verificación y troubleshooting.
- Código ejecutable (`.py`, `.sh`) con comentarios.
- `requirements.txt` cuando aplica.

## Convenciones

- Todos los scripts leen `PROJECT_ID` y `LOCATION` del entorno **o del `.env` del Lab 0** (que
  cargan solos); no hardcodees tu proyecto.
- Los scripts imprimen un **checkpoint observable** ("✅ ...") al terminar bien.
- No borres recursos entre labs: el agente del Lab 1 se reutiliza en los labs 2, 3 y 4.

## Limpieza (al terminar)

El workshop deja recursos vivos (agente en Agent Runtime, template de Model Armor, gateway, registros
en Agent Registry). Bórralos al final con:

```bash
./teardown.sh   # lee labs/lab-00-setup/.env automáticamente
```
