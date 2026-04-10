# Condor: Notes for The Bot Pod Podcast

## Background

**Hummingbot** is an open source framework for crypto market makers and algo traders. **Condor** is a new open source agentic harness built by the Hummingbot team, designed specifically for building autonomous AI trading agents. It is similar in concept to OpenClaw, but purpose-built for trading rather than general productivity.

---

## Section 1: OpenClaw vs Condor Architecture

### OpenClaw
OpenClaw runs a single central server called the **gateway server**, which acts as the hub for all communications — interfacing with LLMs as well as messaging services like Twitter and Telegram.

### Condor
Condor uses a **two-server architecture**:

1. **Condor Server** — Interfaces with LLMs and uses Telegram as its primary communication channel.
2. **Hummingbot API Server** — The execution server. Handles data collection and deterministic trade execution across 50+ exchanges, blockchains, and networks.

### Why This Architecture?

Separating the LLM layer from the trading execution layer provides three key benefits:

- **Speed** — Deterministic algorithms can execute without waiting on LLM inference.
- **Token Efficiency** — Reduces the frequency and volume of LLM calls. Instead of passing raw data to the model, deterministic code executes directly via the API.
- **Isolation & Security** — The LLM does not have full machine access. The Hummingbot API defines and constrains what types of trades can be performed and tracks the P&L of all activity — critical in a live trading environment.

---

## Section 2: The Trading Standard in Condor (Combined Framework)

Also referred to as the **Combined Changes Framework**, this is the core trading engine powering Condor's multi-agent capabilities.

### The Problem It Solves
Professional market makers and individual rewards farmers typically run multiple trading strategies simultaneously. Managing multiple agents across a shared portfolio — without spinning up separate sub-accounts for each — is a core operational challenge.

### How It Works
- A **portfolio** is defined as a set of accounts across different exchanges and blockchains.
- Multiple **agents** can operate on the same portfolio simultaneously.
- Each agent:
  - Acts on its own **allocated slice** of the portfolio.
  - Tracks the **changes it makes** independently.
  - Has its own **P&L tracking**, separate from other agents.
- Agents operate independently — no sub-accounts needed.

### Why It Matters
This architecture allows you to run multiple agents or experiments in parallel, track each one's performance individually, and scale the system to **dozens or even hundreds of agents**. That scale is what enables agents to **learn and self-improve** over time — the foundation for a truly autonomous trading system.

---

*Notes compiled for The Bot Pod podcast — Hummingbot / Condor series.*
