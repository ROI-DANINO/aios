# AIOS Health Report — 2026-03-30

## Executive Summary

AIOS is in good structural health. Memory is clean (0 orphans, 0 stale), data is well within thresholds (no archives needed, no context-clean trigger), and all 5 marketplace plugins are properly registered. The main actionable findings are: one missing frontmatter field in `skills-map.md`, eight skill files that exceed the 150-line threshold (with `aios-health` at 420 lines being the most bloated), and three `#idea` entries in notes.md that have no corresponding backlog items. No automated fixes were applied — the system is healthy enough that no Tier A/B actions were triggered.

---

## 1. Skill Health
**Summary:** 1 critical · 1 warning · 3 info

### Critical
- [ ] `skills/skills-map.md` — frontmatter missing `user-invocable` field (has `name`, `description`, `type` but not `user-invocable`)

### Warning
- [ ] `skills/dev-audit.md` — `## Next Step` points to `/qa`, `/cso`, `/ship` which are gstack skills not in local `skills/` dir; chain works in practice (gstack plugin provides them) but agent flagged as unverifiable locally

### Info
- All 22 local AIOS skills have complete frontmatter (name, description, user-invocable)
- All 5 marketplace.json plugins have corresponding directories: skill-scan, git-audit, context-clean, session-redo, aios-health
- All documented workflow chains have proper handoff links (session loop, project setup, business, multi-agent, UX, health audit)

---

## 2. Memory & Context
**Orphan pointers (MEMORY.md → missing file):** None
**Orphan files (no MEMORY.md pointer):** None
**Stale memory files:** None
**Context file flags:** my-goals.md, gtm-profile.md, my-business.md, my-voice.md, my-icp.md — no date stamp or last-updated field in any context/ file
**Dedup candidates:** `feedback_session_close.md` + `feedback_subagent_session_close.md` (both address session-close behavior; distinct contexts — main session vs. subagent — but worth reviewing if they drift)

---

## 3. Data Hygiene
**Daily-briefs:** 2 total (both kept — well under threshold of 7)
**Skill-scan reports:** 1 total (kept — well under threshold of 2)
**notes.md:** 39 non-archive lines — 11 #next, 2 #idea, 0 #blocker

**Stale #next items (14+ days):** None (all dated 2026-03-29 or 2026-03-30)

**Backlog:** 0 open cleanup, 0 open wiring, 3 open questions

```
TRIGGER_CONTEXT_CLEAN: DAILY_BRIEFS_OVER=false, SCANS_OVER=false, NOTES_BLOAT=false (39 lines)
```

---

## 4. Self-Improvement
**Backlog:** 3 open, 10 closed
**Oldest open item:** "system-architect — clarify whether it's a standalone entry point or always follows `init`"
**Stale ideas (in notes.md, not in backlog):**
- Build a skill that automatically creates skills when needed
- Build an agent skill to spawn multiple subagents with dependency/blocking support
- Paperclip integration for Captionate v3

**Scan-to-backlog gaps:** None (all Scan 4 findings resolved)

**Patterns:**
Core maintenance loop (skill-scan, git-audit, session-redo, context-clean) dominates completed work, all structural fixes (wiring/documentation). No performance or scaling tasks have been attempted. Hermes integration and Paperclip UI research are active in notes.md but completely absent from backlog — high-priority exploration work is untracked.

---

## 5. Token & Context Efficiency
**Bloated skills (>150 lines):**
- aios-health.md — 420 lines, 35 headings
- git-audit.md — 361 lines, 21 headings
- business-setup.md — 237 lines, 30 headings
- system-architect.md — 217 lines, 17 headings
- skill-scan.md — 200 lines, 23 headings
- init.md — 199 lines, 12 headings
- context-clean.md — 179 lines, 7 headings (acceptable)
- pod-mapper.md — 177 lines, acceptable scope

**Heavy context loaders:** None
**Broken chain links:** None
**Duplicate map entries:** None
**skills-map.md line count:** 146
**CLAUDE.md skill refs:** 33

**Efficiency flags:**
- `aios-health` (35 headings) — consolidate phases into table-driven format
- `git-audit` (21 headings) — could be broken into modular sub-skills (setup, branches, commits, pr/issue)
- `business-setup` (30 headings) — move Phase 6+ to /offer-engine
- `system-architect` (17 headings) — move section templates to deliverables/templates/
- `skill-scan` (23 headings) — move Known Duplicate Pairs table to separate reference
- `ux-gate` (21 headings) — consider splitting Gate Mode and Audit Mode into two files

---

## Actions Taken
No automated actions taken — no Tier A or Tier B triggers met.

---

## Actions Skipped
None.

**Requires Manual Review:**
- context/ files have no freshness signal — consider adding a `last-updated` field to each
- Dedup review: `feedback_session_close.md` vs `feedback_subagent_session_close.md`
- 3 idea notes not yet in backlog (see Self-Improvement above)

---

## Suggested Improvement Tasks

### Immediate (Critical findings)
- [ ] Add `user-invocable: true` to frontmatter of `skills/skills-map.md` — _source: skill-health_

### This week (Warning findings)
- [ ] Add `last-updated` field to all 5 `context/` files — _source: memory-context_
- [ ] Convert 3 stale #ideas into scoped backlog items (skill-creator, parallel-agents dispatch, Paperclip) — _source: self-improvement_
- [ ] Create Hermes Phase 0 backlog section linked to open questions in hermes-integration status — _source: self-improvement_

### When time allows (Info / efficiency)
- [ ] Trim `aios-health.md` (420 lines, 35 headings) — consolidate phase descriptions into table format — _source: token-efficiency_
- [ ] Trim `git-audit.md` (361 lines) — modularize into sub-skills or See Also refs — _source: token-efficiency_
- [ ] Trim `business-setup.md` (237 lines) — move Phase 6+ content to /offer-engine — _source: token-efficiency_
- [ ] Resolve system-architect entry-point ambiguity (standalone vs. always after `init`) — _source: self-improvement_
- [ ] Consider splitting `ux-gate` Gate Mode / Audit Mode into two files — _source: token-efficiency_

---

## Next Session Recommendations
1. Fix `skills-map.md` frontmatter (1-min fix) then convert the 3 stale ideas into backlog items
2. Add `last-updated` to `context/` files — quick win for memory hygiene
3. Start trimming `aios-health.md` — at 420 lines/35 headings it's the most bloated skill and loads every session via `/aios-health`

---

_context-clean: not triggered — data within healthy thresholds (2 daily-briefs, 1 skill-scan, 39 notes lines)_

---
_Generated by /aios-health on 2026-03-30. Subagents: skill-health, memory-context, data-hygiene, self-improvement, token-efficiency._
