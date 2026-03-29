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

## Auto-Update Mechanism

The skills map stays current via two complementary mechanisms:

### 1. Claude Code Hook (file-watcher)

A `PostToolUse` hook in `.claude/settings.json` watches for Write/Edit operations on files matching `skills/*.md`. When triggered, it runs a script (`scripts/update-skills-map.sh`) that:

1. Scans all files in `skills/` for frontmatter (`name`, `description`)
2. Detects any skill not already present in `skills-map.md`
3. Appends new skills to the appropriate phase section with a `# TODO: review placement` tag
4. Does not modify existing entries — only adds missing ones

The hook is non-blocking and runs in the background. It flags new skills for Roi to review placement rather than silently placing them in the wrong phase.

### 2. writing-skills Step

The `writing-skills` skill (both AIOS and Superpowers versions) includes a mandatory final step: update `skills/skills-map.md` with the new or modified skill's phase, domain, triggers, and description. This ensures intentional, accurate placement at creation time.

---

## Files to Create

| File | Purpose |
|------|---------|
| `skills/skills-map.md` | Layered reference — phase + domain + triggers |
| `skills/skill-navigator.md` | Navigator skill for contextual silent routing |
| `scripts/update-skills-map.sh` | Hook script — detects new skills, appends with review tag |

### Settings Change

Add to `.claude/settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{"type": "command", "command": "bash scripts/update-skills-map.sh"}]
    }]
  }
}
```

---

## Out of Scope

- No changes to existing skill files (except `writing-skills` gets one new step)
- No subfolder reorganization of `skills/`
- No UI or external tooling — pure markdown + one shell script
