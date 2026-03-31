# AI Team System — Design Spec
**Date:** 2026-03-31
**Status:** Approved — ready for implementation planning

---

## Context

Roi wants to lead a production-grade AI team without being a professional developer. The team executes work autonomously while Roi sets direction, makes decisions, and stays informed. This is a **separate system from AIOS** — AIOS remains the personal Claude Code co-pilot; the team system is a model-agnostic, configurable multi-agent setup that runs in Conduit.

---

## Two-System Architecture

| | AIOS (personal) | Team System |
|---|---|---|
| Interface | Claude Code terminal | Conduit TUI |
| Purpose | Personal co-pilot, brainstorming, planning | Production team executing work |
| Agents | Existing 8 AIOS agents | Community-built, professional frameworks |
| Models | Claude only | Model-agnostic, configurable per role |
| Built by | Roi + Claude | Community frameworks adopted |

These two systems are **independent**. AIOS is untouched by this design.

---

## Team Structure

```
Roi (Leader)
    │
    ▼
Orchestrator ("Chief of Staff")
    │
    ├── Dev Lead        sub-agents: Architect, Developer, QA
    ├── PM Lead         sub-agents: Analyst, Scrum Master
    ├── Security Lead   sub-agents: CSO auditor, pen-tester
    └── UX/UI Lead      sub-agents: UX researcher, UI designer
```

**Roi:** makes all final decisions, approves cross-team conflicts, sets direction. Always informed, never bypassed.

**Orchestrator:** chief of staff. Runs daily briefing, mediates cross-team conflicts, writes conflict reports with both sides for Roi to decide. Never makes final calls.

**Team leads:** own their domain, execute autonomously, communicate with each other directly. Escalate unresolved conflicts to Orchestrator.

**Sub-agents:** spawned by team leads for specific objectives, report back, dismissed when done.

---

## Daily Workflow

**Morning** — open Conduit → Orchestrator runs briefing:
- Decisions waiting for approval
- Unanswered questions from team leads
- Open Linear tickets assigned to Roi
- Cross-team conflicts needing resolution
- Feature suggestions
- Work health (blocked / shipped)

**During the day** — teams execute autonomously. Blockers and flags queue in shared inbox. Roi checks in when available (async by default, real-time when available).

**Conflict resolution** — team leads try to resolve → if stuck → Orchestrator writes report with both sides → Roi decides.

**Notifications** — async for now (waits for check-in). Future: Telegram for urgent items.

---

## Technical Stack

| Layer | Tool | Notes |
|-------|------|-------|
| Agent framework | Community-built (CrewAI or AutoGen — decide in Step 1) | Model-agnostic, configurable |
| Agent definitions | Community pre-built role agents | Not built from scratch |
| Cross-agent messaging | claude-peers-mcp | CC↔CC transport layer |
| Project management | Linear (API) | Backlog, sprints, tickets |
| Dashboard (Phase 1) | Enhanced `/daily-brief` in terminal | Orchestrator-fed |
| Dashboard (Phase 2) | Conduit TUI | Multi-session management |
| Dashboard (Phase 3) | Web UI | Future |
| Notifications (future) | Telegram bot | Urgent escalations |
| Memory | Existing AIOS memory (short term) | Upgrade to community tool later |

---

## Build Order

1. **Research** — evaluate CrewAI vs AutoGen vs others; identify best community agent definitions for each role
2. **Framework selection** — pick the agent framework, confirm model-agnostic config
3. **Agent definitions** — configure Orchestrator + 4 team leads using community templates
4. **Messaging layer** — install claude-peers-mcp (prerequisite for cross-agent communication)
5. **Linear integration** — wire Linear API into Orchestrator
6. **Daily briefing** — enhance `/daily-brief` to pull from Orchestrator + Linear
7. **Conduit validation** — verify Conduit manages team sessions as dashboard
8. **End-to-end test** — run a real task through the full team, Roi reviews result

---

## Deferred (noted, not in scope now)

- Upgrade memory system to community tool
- Upgrade self-improvement system to community tool
- Telegram notifications
- Web UI dashboard
- Conduit as full dashboard (validate after messaging layer works)

---

## Key Decisions

- **Approach:** AIOS structure + community tool integrations
- **PM tool:** Linear
- **Two-system split:** AIOS personal vs Team system in Conduit — independent, not merged
- **Model-agnostic:** team system configurable, not locked to Claude
- **Notifications:** async for now, Telegram later
- **Conflict resolution:** team leads try first → Orchestrator mediates → Roi decides
- **Existing AIOS agents:** kept as personal utilities, not folded into team system
