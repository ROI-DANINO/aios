# Skill Scan — Design Spec
**Date:** 2026-03-30
**Status:** Approved — pending implementation

## Context

AIOS skills have grown to 21 native + 30+ Superpowers plugins. The `skill-inventory-redesign` spec (same date) defines chains, duplicate resolutions, and a living backlog. `/skill-scan` is the enforcement mechanism: it audits every skill available in the session, surfaces inconsistencies by severity, writes a dated report, feeds the backlog, and optionally lets the user triage findings interactively.

---

## Trigger

**Slash command:** `/skill-scan`

**Optional arguments:**
- `/skill-scan triage [skill-name]` — skip full scan, go straight to interactive triage on one skill
- `/skill-scan [skill-name]` — scope scan to a single skill only

---

## Scan Scope

Scanned in this order:
1. `skills/*.md` — AIOS native skills
2. `skills/skills-map.md` — central registry
3. `~/.claude/plugins/` — Superpowers and any other installed plugins
4. `CLAUDE.md` — skill index
5. Session system reminder — live skills available to Claude this session

---

## Findings & Severity Tiers

### Critical
- Skill file exists but not registered in `skills-map.md` (or vice versa)
- Skill referenced in `CLAUDE.md` but file is missing
- Duplicate pair is active (same triggers/purpose, both present)

### Warning
- Skill belongs to a defined chain (per `skill-inventory-redesign.md`) but missing its `→ invoke` handoff or `see also` refs
- No trigger phrases defined
- Description is placeholder or empty

### Info
- Skill not in any defined chain (orphaned)
- No `user-invocable` frontmatter field
- Skill listed in `CLAUDE.md` but not in `skills-map.md`

---

## Report Format

**Primary output:** `data/skill-scan-YYYY-MM-DD.md`

```
# Skill Scan — YYYY-MM-DD

## Summary
- N critical · N warnings · N info
- Scanned: N AIOS skills, N Superpowers skills

## Critical
- [ ] [skill] — [finding description]

## Warning
- [ ] [skill] — [finding description]

## Info
- [ ] [skill] — [finding description]

---
_Notes added during triage will appear below each item._
```

**Secondary output:** New critical and warning items are appended to `data/skill-improvement-backlog.md` under the appropriate section (Wiring tasks / Cleanup tasks / Open questions), following the format defined in `skill-inventory-redesign.md`.

---

## Interactive Triage (Optional)

After the report is saved, Claude prompts:

> "Scan complete — report saved to `data/skill-scan-YYYY-MM-DD.md`. Want to triage any findings interactively? Give me a skill name or finding number."

**Triage loop per finding:**
1. Show full finding detail
2. Ask: *"What's your note on this?"*
3. Append note inline to report under that item
4. Ask: *"Next one, or done?"*

User can exit triage at any time by saying "done."

---

## Skill Chains Reference

Defined in `docs/superpowers/specs/2026-03-30-skill-inventory-redesign.md`. Used during the Warning scan phase to detect missing handoffs.

| Chain | Skills |
|---|---|
| Session loop | `daily-brief` → `note` → `session-close` |
| Dev pipeline | `dev-audit` → `qa` → `cso` → `ship` → `retro` |
| Project setup | `init` → `system-architect` → `business-setup` or dev pipeline |
| Business | `business-setup` → `pod-mapper` |
| Multi-agent | `pod` → `pod-review` → `finishing-a-development-branch` |
| UX | `ux-gate` → (build) → `ux-scan` → `dev-audit` |

---

## Verification

1. Run `/skill-scan` — confirm report written to `data/skill-scan-YYYY-MM-DD.md`
2. Confirm critical findings include known duplicates (browse, cso, qa, ship)
3. Confirm warning findings include chain gaps (e.g. `daily-brief` missing `→ note` handoff)
4. Confirm new items appended to `data/skill-improvement-backlog.md`
5. Run `/skill-scan triage browse` — confirm triage loop activates for that skill
6. Add a note during triage — confirm it appears inline in the report file
