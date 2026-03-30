---
name: Hermes Integration Project
description: Multi-phase plan to integrate AIOS with NousResearch/hermes-agent for real tool execution, persistent memory, and self-improving skills
type: project
---

AIOS × Hermes integration is an active multi-phase project. Full plan at `deliverables/hermes-integration-plan.md`.

**Why:** AIOS skills are text handoffs with no real tool execution, no cross-session memory, and no self-improvement. Hermes provides all three. AIOS provides workflow chains, business context, UX gates, and dev lifecycle structure that Hermes lacks.

**Model:** Claude Code (AIOS) stays as cockpit/orchestrator. Hermes runs locally as the execution engine. Shared state via memory files.

**Current phase:** 0 — Setup & Orientation (not started as of 2026-03-30).

**Phase sequence:** 0 Setup → 1 Memory Bridge → 2 Skill Portability → 3 Tool Access → 4 Self-Improvement Loop → 5 Multi-Agent Coordination

**Project context dir:** `~/Desktop/Projects/hermes-integration/` — status.md, plan.md, log.md

**How to apply:** When user asks about hermes, skills that call each other, memory persistence, or multi-agent execution — this project is the context. Read status.md for current phase before suggesting next steps.
