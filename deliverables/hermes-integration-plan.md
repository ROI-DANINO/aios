# AIOS × Hermes Integration Plan
**Created:** 2026-03-30
**Status:** In progress — Phase 0 next
**Goal:** Build a personal multi-agent OS where Claude Code (AIOS) is the cockpit and Hermes is the engine.

---

## What Each Side Brings

### Hermes gives AIOS:
- 40+ real tools: code execution, browser, web search, file ops
- Actual skill invocation (not text handoffs)
- Cross-session memory via Honcho + SQLite
- Self-improving skill loop (reviews convos → creates/updates skills)
- Context compression at 85% + prompt caching (~75% token cost savings)
- MoA: 4 parallel models for complex reasoning
- Multi-platform access: Telegram, Discord, Slack

### AIOS gives Hermes:
- Workflow chains (daily-brief → note → session-close loop)
- Business context (my-voice, my-goals, my-business, ICP)
- UX validation gates (ux-gate, ux-scan)
- Approval gates in dev flow (Dev Pod Gate 1/2)
- Sprint retro and session logs
- skill-navigator silent routing

---

## The Integration Model

```
Claude Code (AIOS) ← main cockpit
      ↓ when you need real tools, memory, or multi-agent
Hermes CLI ← engine layer, runs locally
      ↓ results, memory updates, skill improvements
feed back into AIOS via shared files + MEMORY.md
```

---

## Phases

### Phase 0 — Setup & Orientation
**Effort:** ~2h
**Goal:** Clone, install, run Hermes locally. Know what actually works before planning further.

- [ ] Clone `NousResearch/hermes-agent` into `~/Desktop/Projects/hermes-agent`
- [ ] Install: `pip install -e ".[all]"` with Python 3.11
- [ ] Configure `.env` with Anthropic key
- [ ] Run `hermes chat` — poke around, test a few tools
- [ ] Read `skills/` directory — understand SKILL.md format
- [ ] Audit: what works out of the box vs. what needs config
- [ ] Write `data/hermes-setup-notes.md` — working config + first impressions

**Don't do yet:** Don't port skills, don't touch memory bridge, don't modify Hermes code.

---

### Phase 1 — Memory Bridge
**Effort:** ~3h
**Goal:** AIOS memory files become Hermes's starting context. One source of truth.

- [ ] Adopt `shared-memory-mcp` as the memory bridge — replaces manual sync script
  - ⚠️ **Verify storage backend before committing** — confirm SQLite vs. other backend fits AIOS needs
- [ ] Configure shared-memory-mcp to read AIOS memory/ + context/ as its source
- [ ] Add `/memory-sync` AIOS skill that triggers shared-memory-mcp sync
- [ ] Update `session-close` skill to call `/memory-sync` before ending

**What this unlocks:** Hermes knows who you are and what you're building without re-explaining every session.
**Don't do yet:** Honcho integration — overkill until you need cloud/multi-device.

---

### Phase 2 — Skill Portability + Real Chaining
**Effort:** ~4h
**Goal:** Your most important AIOS skills exist in Hermes format. Skills actually call each other.

**Port these 3 first (highest daily value):**
1. `daily-brief` → Hermes skill
2. `dev-audit` → Hermes skill
3. `session-close` → Hermes skill

**Each becomes** `skills/<name>/SKILL.md` in Hermes YAML frontmatter format.
**Chaining:** In Hermes, a skill can instruct the agent to invoke another skill via tool use — actual execution, not text handoffs.

**Don't port yet:** `pod-mapper`, `business-setup`, `system-architect` — setup-time skills, not daily-use.

---

### Phase 3 — Tool Access from AIOS
**Effort:** ~3h
**Goal:** AIOS skills can invoke Hermes tools when they need real execution (browser, code eval, search).

- [ ] Adopt `steipete/claude-code-mcp` — replaces hermes-tool.sh wrapper approach
- [ ] Configure claude-code-mcp so AIOS skills can invoke it for real tool execution (browser, code eval, search)
- [ ] Update `pod.md` Coder agent to delegate execution steps via claude-code-mcp when needed

**This is not a full merge** — AIOS says "I need browser control, hand off to Hermes for this step."

---

### Phase 4 — Self-Improvement Loop
**Effort:** ~3h
**Goal:** Hermes's learning loop feeds your AIOS skill improvement backlog.

- [ ] After Hermes sessions, auto-generated skills land in `hermes-agent/skills/`
- [ ] Create `/skill-review` AIOS skill — reads Hermes learnings, decides what to promote to formal AIOS skills
- [ ] Add check to `skill-scan`: "orphaned Hermes learnings not yet in AIOS"
- [ ] `session-close` prompts: "Any Hermes patterns worth formalizing?"

**Compound value:** Over time the system encodes your patterns.

---

### Phase 5 — Multi-Agent Coordination
**Effort:** ~2h _(reduced from ~4h — Phase 3's claude-code-mcp adoption covers the core tool bridge; this phase now focuses on orchestration wiring only)_
**Goal:** Dev Pod delegates execution to Hermes agents. AIOS orchestrates, Hermes executes.

- [ ] Dev Pod stays as orchestrator (planning, gates, PR review)
- [ ] Hermes agents become executors (code runs, test runs, browser checks)
- [ ] `pod.md` Scheduler: route tasks needing `code_execution_tool`/`browser_tool` to Hermes subagents
- [ ] `conductor.md` upgraded: spawns both Claude Code sessions AND Hermes headless sessions
- [ ] Gate 2 ambiguous reviews: invoke Hermes MoA (4 models) for synthesis opinion

---

## What NOT to Do

- Don't rewrite AIOS in Python — markdown-native is a feature
- Don't replace Claude Code with Hermes — Claude Code for interactive dev, Hermes for execution
- Don't auto-sync all memory both ways — start one-way: AIOS → Hermes at session-close
- Don't install Honcho yet — it's for multi-user/cloud deployments
- Don't port all 19 AIOS skills — port 3-5 daily-use skills only

---

## Open Questions (decide before Phase 1)

1. **Primary interface:** Hermes CLI as main terminal, or Claude Code stays primary?
2. **Model config:** Claude exclusively in Hermes, or let it route across providers?
3. **Persistence:** Hermes as always-on daemon or per-task invocations?
4. **Mobile access:** Telegram/Discord integration — early or later?

---

## Phase Log

| Phase | Status | Date | Notes |
|-------|--------|------|-------|
| 0 | Not started | — | — |
| 1 | Not started | — | — |
| 2 | Not started | — | — |
| 3 | Not started | — | — |
| 4 | Not started | — | — |
| 5 | Not started | — | — |
