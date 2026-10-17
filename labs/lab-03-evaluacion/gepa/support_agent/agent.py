"""Agente mínimo para el demo de GEPA (`adk optimize`).

Es autocontenido a propósito: **sin** subagentes, memoria ni búsqueda, para que la
optimización corra rápido y de forma reproducible. La instrucción del root agent es
**deliberadamente pobre** — GEPA la reescribe a partir del eval set de `basic.evalset.json`.
"""
from __future__ import annotations

from google.adk.agents import Agent

_ORDERS = {
    "A-1001": {"status": "en tránsito", "eta": "2 días hábiles"},
    "A-1002": {"status": "entregado", "eta": "-"},
    "A-1003": {"status": "retrasado", "eta": "5 días hábiles"},
}


def get_order_status(order_id: str) -> dict:
    """Devuelve el estado de un pedido interno.

    Args:
        order_id: Identificador del pedido, por ejemplo 'A-1001'.

    Returns:
        dict con el estado del pedido o un mensaje de error.
    """
    order = _ORDERS.get(order_id.strip().upper())
    if not order:
        return {"error": f"Pedido '{order_id}' no encontrado."}
    return {"order_id": order_id.upper(), **order}


root_agent = Agent(
    name="support_agent",
    model="gemini-2.5-flash",
    description="Agente de soporte (versión mínima para el demo de GEPA).",
    # 👇 Instrucción pobre a propósito: GEPA la optimiza contra el eval set.
    instruction="Eres un agente de soporte. Responde a lo que pida el usuario.",
    tools=[get_order_status],
)
