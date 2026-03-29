# Skills Map & Navigator — Design Spec

**Date:** 2026-03-29
**Status:** Approved

---

## Overview

Two deliverables:

1. **`skills/skills-map.md`** — a layered reference document organizing all AIOS and Superpowers skills by workflow phase, domain, and trigger phrases. Serves as a personal cheat sheet and the navigator's source of truth.
2. **`skills/skill-navigator.md`** — a skill that Claude invokes contextually and silently to route the right skill based on what the user is doing.

---

## skills-map.md

### Structure

A single markdown file organized into five workflow phases. Each phase contains a table of skills with four columns:

| Field | Description |
|-------|-------------|
| Skill | The slash command name (e.g. `/brainstorming`) |
| Domain | `business` · `dev` · `system` · `utility` |
| Triggers | Phrases or situations that should fire this skill |
| What it does | One-line plain-English description |

### Phases

**Phase 1 — Session Start**
Skills that orient the session before any work begins.
- `using-superpowers` (system) — establishes skill usage rules at conversation start
- `daily-brief` (business) — reads goals, surfaces yesterday's notes, proposes session agenda

**Phase 2 — Business Work**
Skills for building and operating the business side of AIOS.
- `business-setup` (business) — full onboarding wizard, captures identity/voice/ICP/GTM
- `offer-engine` (business) — build or audit a business offer from scratch
- `pod-mapper` (business) — map a business function into automatable workflows
- `system-architect` (system) — architecture design walkthrough for AIOS itself

**Phase 3 — Dev Work**
Skills that govern the full development lifecycle in order.
- `brainstorming` (dev) — explore intent and design before any implementation
- `writing-plans` (dev) — write a structured implementation plan from a spec
- `test-driven-development` (dev) — write tests before implementation code
- `executing-plans` (dev) — execute a written plan with review checkpoints
- `subagent-driven-development` (dev) — parallel implementation via independent subagents
- `dispatching-parallel-agents` (dev) — split 2+ independent tasks across agents
- `requesting-code-review` (dev) — request review after completing a feature
- `receiving-code-review` (dev) — handle review feedback with technical rigor
- `finishing-a-development-branch` (dev) — merge, PR, or cleanup after implementation
- `using-git-worktrees` (dev) — create isolated worktrees for feature work

**Phase 4 — Anytime / Utility**
Skills usable at any point in the session.
- `note` (utility) — quick mid-session capture to notes.md
- `dev-audit` (dev) — where am I in this dev phase? what's left?
- `systematic-debugging` (dev) — diagnose bugs before proposing fixes
- `verification-before-completion` (dev) — verify before claiming done
- `writing-skills` (system) — create or improve skills

**Phase 5 — Session Close**
- `session-close` (business) — wrap-up, session log, open threads

---

## skill-navigator.md

### Purpose

A skill Claude loads automatically (via `using-superpowers` trigger rules) that routes contextually to the right skill without announcement. The user never has to name the skill — Claude detects the situation and fires it silently.

### Matching Logic

The navigator reads `skills/skills-map.md` and applies four matching rules in order:

1. **Keyword match** — user message contains a phrase from the trigger list → invoke that skill
2. **Intent match** — user describes a situation that maps to a skill's purpose (even without exact trigger words)
3. **Phase awareness** — if the session is in a dev context, dev skills take priority over business skills when ambiguous
4. **No double-fire** — if a skill was already invoked this session, don't re-invoke it unless the context has clearly shifted

### Behavior

- Silent invocation — no announcement, no "I'm using X because Y"
- If no skill matches, proceed normally
- If multiple skills could match, prefer the one earlier in the dev lifecycle (e.g. brainstorming before writing-plans)

---

## Files to Create

| File | Purpose |
|------|---------|
| `skills/skills-map.md` | Layered reference — phase + domain + triggers |
| `skills/skill-navigator.md` | Navigator skill for contextual silent routing |

---

## Out of Scope

- No changes to existing skill files
- No subfolder reorganization of `skills/`
- No UI or external tooling — pure markdown
