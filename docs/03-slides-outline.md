# Guion de slides — "Gobierno de agentes en GCP y Optimización de agentes en Vertex"

> Deck narrativo: cada slide tiene **título**, **bajada** (la frase que el/la expositor/a dice)
> y **foco visual**. Diseñado para ~30 slides en 3 horas (incluye slides "de transición a lab").
> Notación de secciones: **S1** = Contexto (15'), **S2** = Build & Scale (20'),
> **S3** = Govern (25'), **S4** = Optimize (20'), **S5** = Cierre (10').

---

## Apertura (S1)

**1. Portada**
- Título: *Gobierno de agentes en GCP y Optimización de agentes en Vertex*
- Bajada: "De prototipo a producción: cómo controlar y optimizar agentes en la plataforma de Google."
- Visual: logo GDG Cloud Santiago + diagrama de 4 pilares en blanco.
- Nota: subtítulo obligatorio: *"Vertex AI ahora es Gemini Enterprise Agent Platform (2026)"*.

**2. El salto: de chatbot a agente**
- Bajada: "Un chatbot genera texto; un agente decide y actúa. Eso cambia el modelo de riesgo."
- Visual: dos columnas — Chatbot (texto) vs Agente (tools, memoria, autonomía, multi-agente).

**3. La tesis**
- Bajada: "Un agente sin gobierno es un riesgo; sin evaluación, una caja negra; sin optimización, un costo descontrolado."
- Visual: tres iconos (escudo, lupa, gráfico de costo).

**4. Qué veremos hoy**
- Bajada: "Recorremos los 4 pilares de la plataforma, con foco en Govern y Optimize."
- Visual: los 4 pilares (Build · Scale · Govern · Optimize) con tiempo asignado.

---

## Bloque Build & Scale (S2)

**5. Gemini Enterprise Agent Platform**
- Bajada: "Vertex AI evolucionó: misma base, nueva organización en 4 pilares."
- Visual: figura oficial de los 4 pilares. Nota: tabla de renames (Agent Engine → Agent Runtime).

**6. La escalera de construcción (los 4 rungs)**
- Bajada: "Empieza bajo y sube de rung cuando necesites control."
- Visual: escalera — Studio → Managed Agents → Antigravity → ADK, con A2A como base.

**7. Agent Development Kit (ADK)**
- Bajada: "Code-first, model-agnóstico. El framework para control total."
- Visual: snippet mínimo de ADK (Agent + tools).

**8. Agent Runtime (ex Agent Engine)**
- Bajada: "El runtime gestionado: cold starts sub-segundo, revisiones, tráfico, larga duración."
- Visual: diagrama deploy → revisiones → split de tráfico.

**9. Sessions y Memory Bank**
- Bajada: "Corto plazo (sessions) y largo plazo (memory) gestionados. Ya en GA."
- Visual: timeline de conversaciones con memoria persistente entre sesiones.

**10. Transición a Lab 1**
- Bajada: "Ahora construimos y desplegamos un agente con identidad propia."
- Visual: "→ labs/lab-01-agente-adk".

---

## Bloque Govern (S3)

**11. Govern: el mapa de controles**
- Bajada: "Gobernar no es un producto: es identidad + catálogo + enforcement + contenido + políticas."
- Visual: el diagrama mermaid del `docs/00` (flujo ingress→egress con Gateway).

**12. Agent Identity**
- Bajada: "Cada agente con su propia identidad SPIFFE, mTLS + DPoP por defecto."
- Visual: `principal://agents.global.org-.../reasoningEngines/...` con anotaciones.

**13. Agent Registry**
- Bajada: "La allowlist organizacional: qué agentes, tools, MCP servers y skills existen."
- Visual: catálogo con recursos registrados (Agent, McpServer, Endpoint, Skill).

**14. Agent Gateway**
- Bajada: "El chokepoint. Todo el tráfico agéntico pasa por aquí y se le aplican políticas."
- Visual: dos modos (Client-to-Agent / Agent-to-Anywhere) lado a lado.

**15. Políticas: IAM vs Semantic**
- Bajada: "IAM para acceso determinista; Semantic Governance para reglas de negocio en lenguaje natural."
- Visual: ejemplo de regla NLC ("no ejecutar pago y borrado en el mismo flujo").

**16. Model Armor**
- Bajada: "Guardrails de contenido: prompt injection, PII, dañino, URLs, docs e imágenes."
- Visual: tabla de filtros + diagrama de inspección in/out.

**17. Model Armor: inspect vs block**
- Bajada: "Empieza en inspect-only; pasa a block cuando conozcas tu tasa de falsos positivos."
- Visual: tabla de modos + recomendación de umbrales (High / Medium).

**18. Threat scan y Anomaly Detection**
- Bajada: "Seguridad específica de agentes: vulnerabilidades y detección de deriva en runtime."
- Visual: SCC widget + concepto de Anomaly Detection sobre trazas OTel.

**19. Transición a Lab 2 + Lab 4**
- Bajada: "Vamos a romper un agente a propósito y luego gobernarlo."
- Visual: "→ labs/lab-02-model-armor · labs/lab-04-gobierno-gateway".

---

## Bloque Optimize (S4)

**20. Optimize: el Quality Flywheel**
- Bajada: "Evaluar → analizar fallas → optimizar → repetir."
- Visual: rueda de 4 fases (Design, Execution, Scoring, Refinement).

**21. Agent Evaluation**
- Bajada: "Task Success y Safety con autoraters; reference-based y reference-free."
- Visual: tabla de fases y tipos de rater.

**22. Scenario generation + User Simulation**
- Bajada: "Genera escenarios multi-turno y simula usuarios: empieza a testear sin dataset."
- Visual: ejemplo de persona de usuario simulada.

**23. Observabilidad: Unified Traces**
- Bajada: "El trace te dice qué modelo, qué tool y qué decisión causó la regresión."
- Visual: traza jerárquica (request → model → tool → respuesta).

**24. Prompt Optimization (GEPA)**
- Bajada: "`adk optimize` refina tus instrucciones contra tu suite de tests."
- Visual: loop de optimización con gráfico de calidad subiendo.

**25. Context Caching (FinOps de agentes)**
- Bajada: "El mismo contexto reenviado = costo. Caché lo convierte en costo único (hasta 90% dto)."
- Visual: comparativa de tokens antes/después + tabla implícito vs explícito.

**26. Transición a Lab 3**
- Bajada: "Ahora medimos la calidad del agente y buscamos sus fallas."
- Visual: "→ labs/lab-03-evaluacion".

---

## Cierre (S5)

**27. Lo que aprendimos (Takeaways)**
- Bajada: "5 ideas para llevarte."
- Visual: lista de 5 takeaways (`docs/00` §11).

**28. Anti-patrones vs buenas prácticas**
- Bajada: "Lo que NO hacer y su reemplazo."
- Visual: tabla anti-patrón → práctica.

**29. 🧹 Limpieza — no dejes recursos corriendo**
- Bajada: "El workshop deja agente, gateway y template vivos. Borra todo con un script."
- Visual: captura de `./teardown.sh` + tabla de recursos que elimina.
- Nota: **decirlo en voz alta** — quien despliegue en su propio proyecto dejará agentes corriendo (y facturando) si no lo ejecuta.

**30. Recursos y próximos pasos**
- Bajada: "Codelabs, docs y repos para seguir."
- Visual: QR a `recursos/bibliografia.md` + links clave (adk.dev, Model Armor codelab).

**31. Gracias + Q&A**
- Bajada: "¿Preguntas? Construyamos agentes gobernados."
- Visual: contacto GDG Cloud Santiago + CTA a la comunidad.

---

## Plantilla de slide "de lab" (para reutilizar)

```
[LAB N — TÍTULO]
Objetivo: (una frase)
Qué harás: (3 bullets)
Éxito si: (1 resultado observable)
⏱ Tiempo: N min
→ carpeta: labs/lab-NN/
```

## Consejos de diseño del deck

- **Una idea por slide**. Govern tiene muchos componentes: no los amontones.
- Usa el **mismo diagrama mermaid** en 3 slides (11, 14, 20) para que la audiencia reconozca la estructura.
- Marca cada bloque charla/lab con un color distinto en el header.
- Incluye **capturas reales** de: Model Armor block, un trace, y un eval scorecard. Lo real vende.
