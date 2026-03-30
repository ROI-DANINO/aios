# Skills Inventory — 2026-03-30
> Foundation document for agent taxonomy design. Output of the skills audit session.

---

## Summary

| Category | Count |
|---|---|
| Core AIOS skills (keepers) | 12 |
| Duplicates (AIOS vs. plugin) | 8 |
| Branch-only (not on master) | 4 |
| Broken / disconnected chain | 4 |
| Deprecated (discard) | 3 |
| Gaps / placeholders | 6 |

---

## 1. Core AIOS Skills — KEEP

These are unique to AIOS and have no equivalent in gstack or Superpowers.

| Skill | What it does | Works with | Status |
|---|---|---|---|
| `daily-brief` | Session-start orientation — reads goals, notes, open plans, proposes agenda | note, session-close, context-clean | Chain documented, not enforced |
| `session-close` | End-of-session wrap — writes log, extracts memory, queues next task | daily-brief, note, memory, context-clean | Chain documented, not enforced |
| `note` | Mid-session quick capture with tags (#idea #blocker #next #decision) | daily-brief, session-close | Works, but project detection is hardcoded to "Captionate v3" |
| `context-clean` | Archives stale daily-briefs, compacts notes.md, checks memory health | daily-brief (trigger), aios-health | Triggered passively (5+ #next), never automatic |
| `aios-health` | Full system audit — 5 parallel subagents for skill, memory, data, backlog, token health | skill-scan, context-clean, memory | Complex, probably underused |
| `skill-scan` | Audit every skill for missing registrations, duplicates, chain gaps | skills-map, CLAUDE.md | Saves to data/, feeds backlog |
| `skills-map` | Reference index of all skills by phase and domain | skill-navigator | Reference only, not invocable |
| `dev-audit` | Phase status check — where am I in this project, what's left | git, deliverables/ | Standalone, not chained |
| `init` | Project onboarding wizard — scan dir, interview, propose structure, register in memory | memory, AIOS project dirs | Rarely used, no outbound chain |
| `system-architect` | Architecture design walkthrough (interactive) | deliverables/ | Standalone, manual trigger only |
| `ux-gate` | Blocks any new feature/UI until user answers 3 UX questions | All dev skills | Works, invoked before features |
| `ux-scan` | Audits existing codebase for purposeless features/UI | dev-audit | Standalone audit |
| `session-redo` | Fixes wrong or incomplete session log entries | session-close, data/session-log | Works, rarely needed |
| `skill-navigator` | Silent contextual skill router — fires every turn, reads skills-map | all skills | Ambitious but unreliable — reads skills-map.md every turn, expensive, likely ignored |

---

## 2. Duplicates — MERGE or DISCARD AIOS version

These exist in AIOS `skills/` AND as installed plugins (gstack or Superpowers). The plugin version is the authoritative invocable one. The AIOS markdown file becomes dead weight unless it's the plugin source.

| AIOS Skill | Duplicate In | Verdict |
|---|---|---|
| `office-hours` | gstack | Discard AIOS version — gstack is authoritative |
| `retro` | gstack | Discard AIOS version |
| `conductor` | gstack | Discard AIOS version |
| `pod-mapper` | superpowers:pod-mapper | Discard AIOS version |
| `business-setup` | superpowers:business-setup | Discard AIOS version |
| `pod` | (partial overlap with superpowers:dispatching-parallel-agents) | Evaluate — pod has Gate 1/2 workflow, not a straight duplicate |
| `pod-review` | (partial overlap) | Evaluate — part of pod system |

---

## 3. Branch-Only Skills — BRING TO MASTER

These exist only in `claude/goofy-moser` and are not on master. They're also available as gstack plugins, but the AIOS versions may have custom adaptations.

| Skill | Branch | What it does | Action |
|---|---|---|---|
| `browse` | goofy-moser | Real Chromium browser via Playwright | Confirm gstack version covers it — if so, skip merge |
| `cso` | goofy-moser | Security review — OWASP, secrets, permissions | Same |
| `qa` | goofy-moser | QA pass — runs tests, flags untested paths | Same |
| `ship` | goofy-moser | Release checklist — version, changelog, tag | Same |

**Verdict:** All 4 are covered by gstack plugins. No need to merge to master unless AIOS versions have custom logic worth keeping.

---

## 4. Broken / Disconnected Chains

The session loop (`daily-brief → note → session-close → context-clean → memory`) is documented inside each skill but not enforced anywhere. It breaks in several places:

| Break point | Problem | Impact |
|---|---|---|
| `session-close` → memory | Memory extraction is manual inference — no verification it happened, no confirmation to user | Session data lost silently |
| `daily-brief` → `context-clean` | Only triggered if 5+ #next entries — passive suggestion, not automatic | Data accumulates indefinitely |
| `note` → project detection | Project is hardcoded to "Captionate v3" — wrong for any other project | Notes filed under wrong project |
| `skill-navigator` → any skill | Fires "every turn" by reading skills-map.md — expensive, unreliable, no evidence it actually routes correctly | Silent failure, skills not triggered |

---

## 5. Deprecated — DISCARD

These are explicitly deprecated in Superpowers and replaced by newer versions.

| Skill | Replaced By |
|---|---|
| `superpowers:brainstorm` | `superpowers:brainstorming` |
| `superpowers:execute-plan` | `superpowers:executing-plans` |
| `superpowers:write-plan` | `superpowers:writing-plans` |

---

## 6. Gaps / Placeholders

Things that should exist but don't.

| Missing Skill | What it would do | Priority |
|---|---|---|
| `agent-config` | Define/edit agent roles, tools, and permissions for oh-my-pi or another platform | High — needed for multi-agent work |
| `memory-audit` | Explicit skill to read, prune, and verify memory health (separate from aios-health) | High — memory drifts silently |
| `context-loader` | Selectively load the right context files for a given task/project before starting work | Medium — reduces token waste |
| `handoff` | Structured protocol for one agent passing work to another with full context | Medium — required for real multi-agent |
| `tool-registry` | Catalog of available tools per agent role (what each agent can and cannot do) | Medium — needed for oh-my-pi agent design |
| `session-health` | Quick check at session start — are memory, notes, and logs in sync? (lighter than aios-health) | Low — aios-health partially covers this |

---

## 7. Superpowers Framework Skills (Installed, Authoritative)

These are external plugins — do not duplicate in AIOS `skills/`. Treat them as given infrastructure.

**Dev workflow chain (rigid — follow exactly in order):**
`brainstorming` → `writing-plans` → `test-driven-development` → `requesting-code-review` → `finishing-a-development-branch`

**Support skills:**
- `executing-plans` — run a written plan in a separate session
- `systematic-debugging` — structured bug investigation
- `verification-before-completion` — gates before claiming work is done
- `receiving-code-review` — process incoming review feedback
- `subagent-driven-development` — multi-agent plan execution
- `dispatching-parallel-agents` — parallelize independent tasks
- `using-git-worktrees` — isolated branch work

**Meta:**
- `using-superpowers` — session start, skill routing
- `writing-skills` — create/edit skills

---

## Next: Agent Taxonomy Design

When ready to design agent teams, this inventory gives you the clean inputs:

- **12 core AIOS skills** to assign to agents
- **~25 Superpowers + gstack skills** available as shared infrastructure
- **4 broken chain points** to fix in the session management agent
- **6 gaps** to fill with new skills
- **oh-my-pi** as the target runtime (6 agent slots: explore, plan, designer, reviewer, task, quick_task + custom)
- **MetaGPT SOP pattern** as the model for skill-to-agent assignment
