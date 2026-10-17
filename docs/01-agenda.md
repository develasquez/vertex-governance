# Agenda detallada — 3 horas hands-on

> GDG Cloud Santiago · "Gobierno de agentes en GCP y Optimización de agentes en Vertex"

| # | Hora | Bloque | Formato | Contenido | Material |
|---|---|---|---|---|---|
| 0 | 00:00–00:15 | **Bienvenida + setup** | Charla + setup | Qué veremos, objetivos, verificación de entorno (`lab-00`). | `labs/lab-00-setup/` |
| 1 | 00:15–00:35 | **Build & Scale** | Charla | Los 4 pilares, ADK, Agent Runtime, Sessions/Memory Bank, la "escalera de rungs". | `docs/00`, `docs/02` |
| 2 | 00:35–01:05 | **LAB 1 — Agente ADK + deploy** | Hands-on | Construir un agente, probarlo local, desplegarlo en Agent Runtime **con Agent Identity**. | `labs/lab-01-agente-adk/` |
| — | 01:05–01:10 | *Break* | — | Café / preguntas rápidas. | — |
| 3 | 01:10–01:35 | **Govern** | Charla | Identity, Registry, Gateway, IAM+Semantic Policies, Model Armor, Threat Scan. | `docs/00` §6.3 |
| 4 | 01:35–02:10 | **LAB 2 + LAB 4 — Guardrails y gobierno** | Hands-on | Model Armor (inspect→block) y enrutar por Agent Gateway + registro en Registry. | `labs/lab-02-model-armor/`, `labs/lab-04-gobierno-gateway/` |
| 5 | 02:10–02:30 | **Optimize** | Charla | Evaluación, observabilidad/trazas, prompt optimization (GEPA), context caching (FinOps). | `docs/00` §6.4 |
| 6 | 02:30–02:55 | **LAB 3 — Evaluación** | Hands-on | Correr evaluación, interpretar rubricas, identificar fallas, iterar. | `labs/lab-03-evaluacion/` |
| 7 | 02:55–03:05 | **Cierre** | Charla | Takeaways, recursos, próximos pasos, **limpieza de recursos**, Q&A. | `docs/00` §11 + `teardown.sh` |

## Notas de facilitación

- **Ritmo**: si el grupo es mayoritariamente de negocio, recorta los labs 2 y 4 a demostración en vivo.
- **Riesgo de tiempo**: el deploy (Lab 1) es lo más lento (~2-4 min por deploy). Ten un agente en
  `us-central1` ya desplegado como respaldo.
- **Checkpoint a 01:05**: si el Lab 1 no terminó, pasa al bloque de Gobierno igual y deja el deploy
  corriendo en background. Retómalo antes del Lab 3 (que reutiliza el agente).
- **Regla de oro**: cada lab debe terminar con *algo observable* (una respuesta, un bloqueo, un score).
- **Cierre limpio**: recuérdale al grupo correr `./teardown.sh` antes de irse. Quien despliega en su
  propio proyecto deja un agente corriendo (y facturando) si no lo hace.

## Opción "serie de 2 sesiones"

Si el meetup se divide en dos:

- **Sesión 1 (90 min)**: Bloques 0–4 → Build/Scale + Govern + Labs 1, 2, 4.
- **Sesión 2 (90 min)**: Bloques 5–7 → Optimize + Lab 3 + cierre + caso integrador.
