# Skill Inventory Redesign
**Date:** 2026-03-30
**Status:** Approved — pending implementation

## Context

The AIOS skill set has grown organically. Skills like `daily-brief` and `session-close` form a natural loop, but most skills lack explicit handoffs to their neighbors. Additionally, several local skills duplicate gstack/superpowers equivalents, creating ambiguity about which to use. This redesign wires the skills into intentional chains and prunes the duplicates.

---

## Approach: Connection-first

Map every skill into workflow chains → add hard handoffs and soft cross-refs → prune duplicates as a second pass. Track all work in a living backlog at `data/skill-improvement-backlog.md`.

---

## Skill Chains

Each chain gets:
- **Hard wiring:** explicit `→ invoke [skill]` or "next step" callout in the skill's markdown
- **Soft refs:** `see also` section listing related skills

| Chain | Ordered Skills |
|---|---|
| **Session loop** | `daily-brief` → (work) → `note` → `session-close` → `daily-brief` (next day) |
| **Dev pipeline** | `dev-audit` → `qa` → `cso` → `ship` → `retro` |
| **Project setup** | `init` → `system-architect` → `business-setup` or dev pipeline |
| **Business** | `business-setup` → `pod-mapper` → (execution) |
| **Multi-agent** | `pod` → `pod-review` → `finishing-a-development-branch` |
| **UX** | `ux-gate` → (build) → `ux-scan` → `dev-audit` |

**Meta-layer (no wiring needed):** `skill-navigator` (always-on router), `skills-map` (reference doc)

---

## Duplicates to Resolve

| Skill | Action | Reason |
|---|---|---|
| `skills/browse.md` | **Remove** | gstack `/browse` is Playwright-based and more capable |
| `skills/cso.md` | **Remove** | gstack `/cso` has full OWASP scan |
| `skills/qa.md` | **Remove** | gstack `/qa` integrates with test runner |
| `skills/ship.md` | **Remove** | gstack `/ship` has version bump + changelog |
| `skills/retro.md` | **Keep + harden** | Reads AIOS session logs — gstack version lacks this context |
| `skills/office-hours.md` | **Keep + merge** | Local version routes to debugging; absorb gstack's open-ended format |
| `skills/conductor.md` vs `superpowers:dispatching-parallel-agents` | **Keep both** | Different tools: conductor = headless Claude sessions, dispatching = Agent SDK |

---

## Backlog File

**Location:** `data/skill-improvement-backlog.md`
**Format:** Checkbox list with three sections:
1. **Wiring tasks** — one item per chain link needing a handoff
2. **Cleanup tasks** — one item per duplicate to remove or merge
3. **Open questions** — skills needing more thought before acting

Each item: `[ ]` status, skill name, action, one-line reason.
`skill-navigator` should surface this file when user asks "what should I improve."

---

## Verification

1. After wiring: invoke `daily-brief` and confirm it references `note` and `session-close`
2. After wiring: invoke `dev-audit` and confirm it points to `qa`
3. After cleanup: confirm removed skill files are gone, gstack equivalents still work
4. After all: run `skill-navigator` and confirm routing still works end-to-end
5. Check `data/skill-improvement-backlog.md` is populated and checkboxes are actionable
