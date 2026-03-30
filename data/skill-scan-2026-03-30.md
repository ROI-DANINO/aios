# Skill Scan — 2026-03-30

## Summary
- 1 critical · 3 warnings · 2 info
- Scanned: 16 AIOS skills (skills/*.md), 1 skills-map registry, CLAUDE.md, session system reminder (gstack + superpowers plugins)

---

## Critical

- [x] `skill-navigator` — file exists in `skills/` but is not registered in `skills-map.md` ✓ fixed: added to Phase 4 table in skills-map.md

---

## Warning

- [x] `skill-navigator` — no trigger phrases defined anywhere in the file; it fires automatically but the mechanism is not documented in frontmatter ✓ fixed: added `user-invocable: false` to frontmatter; auto-fire documented in skill body
- [x] `conductor` — no `## Next Step` or `## See Also` section; it is invoked by `pod` in the multi-agent chain but has no documented handoff back ✓ fixed: added `## See Also` section with pod, dispatching-parallel-agents, pod-review
- [x] `system-architect` — chain handoff is ambiguous ✓ was already resolved: file has `## Next Step` and `## See Also` referencing `/business-setup` (false alarm from Scan 1)

---

## Info

- [x] `skill-navigator` — `user-invocable` frontmatter field is absent ✓ fixed: added `user-invocable: false`
- [ ] CLAUDE.md skill index includes many gstack-only skills (`/plan-ceo-review`, `/plan-eng-review`, `/design-consultation`, `/qa-only`, `/canary`, etc.) with no local file in `skills/`. This is by design but creates a gap — if gstack is uninstalled, CLAUDE.md references skills that no longer exist. No immediate action needed; flagged for awareness.

---

_Notes added during triage will appear below each item._

---

## Scan 2 — 2026-03-30 (second run)

### Summary
- 1 critical · 3 warnings · 2 info (all carryover — no new findings)
- Scanned: 18 skill files (skills/*.md includes skill-scan.md added since Scan 1), skills-map.md, CLAUDE.md, session system reminder
- **Resolved since Scan 1:** `skill-scan` added, registered in skills-map.md, plugin installed — clean on all checks

### Critical (carryover)
- [x] `skill-navigator` — file exists in `skills/` but not registered in `skills-map.md` ✓ fixed

### Warning (carryover)
- [x] `skill-navigator` — no trigger phrases / auto-fire mechanism not documented ✓ fixed
- [x] `conductor` — no `## See Also` section ✓ fixed
- [x] `system-architect` — was a false alarm; file already had correct `## See Also` ✓ closed

### Info (carryover)
- [x] `skill-navigator` — missing `user-invocable: false` ✓ fixed
- [ ] gstack-only skills in CLAUDE.md (`/plan-ceo-review`, `/design-consultation`, `/canary`, etc.) have no local file in `skills/` — by design, flagged for awareness if gstack is ever removed

_Notes added during triage will appear below each item._

---

## Scan 3 — 2026-03-30 (third run)

### Summary
- 0 critical · 1 warning · 1 info
- Scanned: 19 skill files (skills/*.md — `git-audit` added since Scan 2), skills-map.md, CLAUDE.md, session system reminder
- **New since Scan 2:** `git-audit` skill file added and plugin installed

### Critical
_None._

### Warning
- [x] `git-audit` — no trigger phrases in frontmatter description or skill body ✓ fixed: added "Use when user says..." triggers to frontmatter description

### Info
- [x] `git-audit` — missing `user-invocable: true` frontmatter field ✓ fixed: added `user-invocable: true` and `argument-hint`

_Notes added during triage will appear below each item._

---

## Scan 4 — 2026-03-30 (fourth run)

### Summary
- 2 critical · 3 warnings · 4 info
- Scanned: 20 AIOS skill files (skills/*.md), skills-map.md, CLAUDE.md, session system reminder
- **New since Scan 3:** `context-clean`, `session-redo`, `skill-scan` added since Scan 3; now 20 skill files total

### Critical

- [x] `pod-mapper` — AIOS local (`skills/pod-mapper.md`) AND `superpowers:pod-mapper` both active in session. Same purpose, same triggers. Not in known-duplicates table — no resolution documented. ✓ documented in known-duplicates table: keep local — AIOS version has chain handoffs superpowers copy lacks
- [x] `business-setup` — AIOS local (`skills/business-setup.md`) AND `superpowers:business-setup` both active in session. Same purpose, same triggers. Not in known-duplicates table — no resolution documented. ✓ documented in known-duplicates table: keep local — same reason

### Warning

- [x] `superpowers:brainstorm` — deprecated skill still active in session; replaced by `superpowers:brainstorming`. Stale plugin registration. ✓ no action needed — managed redirect stub in superpowers plugin package (v5.0.6) with `disable-model-invocation: true`; cannot be removed from this side
- [x] `superpowers:execute-plan` — deprecated skill still active in session; replaced by `superpowers:executing-plans`. Stale plugin registration. ✓ no action needed — same reason
- [x] `superpowers:write-plan` — deprecated skill still active in session; replaced by `superpowers:writing-plans`. Stale plugin registration. ✓ no action needed — same reason

### Info

- [x] `git-audit` — missing both `## Next Step` and `## See Also`; no chain connections for discoverability ✓ added `## See Also` section
- [x] `skill-scan` — missing `## Next Step` (has `## See Also`); not in a formal chain but maintenance loop is documented in skills-map ✓ added `## Next Step`
- [x] `session-redo` — missing `## Next Step` (has `## See Also`); orphaned from session-loop chain ✓ added `## Next Step`
- [x] `context-clean` — missing `## Next Step` (has `## See Also`); maintenance chain is informal ✓ added `## Next Step`

_Notes added during triage will appear below each item._
