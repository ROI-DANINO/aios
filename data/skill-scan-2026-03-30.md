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
