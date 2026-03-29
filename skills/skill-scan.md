---
name: skill-scan
description: >
  Full audit of every skill available in the current session. Scans AIOS skills/,
  skills-map.md, Superpowers plugins, CLAUDE.md, and the session context to find
  inconsistencies across three severity tiers: critical (missing files, active duplicates,
  broken registrations), warning (missing chain handoffs, no triggers, empty descriptions),
  and info (orphaned skills, missing metadata). Saves a dated tiered report to
  data/skill-scan-YYYY-MM-DD.md and feeds new findings into data/skill-improvement-backlog.md.
  Optionally triages findings interactively — one skill at a time, user adds notes inline.
  Use when user says "/skill-scan", "audit skills", "scan skills", "skill audit",
  "check skills", "what skills are broken", "what skills are missing", or any time
  the user wants to understand the health of the AIOS skill inventory.
  Also use for /skill-scan triage [skill-name] (skip full scan, go straight to interactive
  triage on one skill) and /skill-scan [skill-name] (scope scan to a single skill only).
user-invocable: true
argument-hint: "[skill-name] | triage [skill-name]"
---

# Skill Scan

Audit every skill in the session. Surface what's broken, missing, or misaligned. Write the report. Feed the backlog.

## When to Trigger

- `/skill-scan` — full scan of all skills
- `/skill-scan [skill-name]` — scoped scan of a single skill
- `/skill-scan triage [skill-name]` — skip scan, go straight to interactive triage on that skill
- Any time the user wants to know the health of their skill inventory

---

## Phase 1: Scan

> **Scope of this scan:** registration, chain membership, and metadata completeness. Not skill quality, content correctness, or edge case coverage — those belong in a code review, not a skill audit.

Scan in this order. Collect raw findings — don't classify yet.

### 1. `skills/*.md` — AIOS native skills

For each skill file:
- Does it have a `name` and `description` in frontmatter?
- Does it have `user-invocable: true`?
- Does it have trigger phrases (either in frontmatter description or skill body)?
- Does it have a `## Next Step` or `## See Also` section (for chain skills)?

### 2. `skills/skills-map.md` — central registry

- List every skill registered here
- Cross-reference against `skills/*.md` — flag any skill in the map but missing a file, or in a file but missing from the map

### 3. `~/.claude/plugins/` — Superpowers and other installed plugins

List available plugins and their skills. Note which skills have the same trigger phrases as AIOS native skills — those are potential duplicates.

### 4. `CLAUDE.md` — skill index

- List every skill referenced in CLAUDE.md
- Flag any referenced in CLAUDE.md but missing a file in `skills/`

### 5. Session system reminder — live skills available this session

Note which skills Claude has access to in the current session. Compare against what's registered in CLAUDE.md and skills-map.md.

---

## Phase 2: Classify

Bucket each finding by severity:

### Critical
- Skill file exists in `skills/` but not registered in `skills-map.md` (or vice versa)
- Skill referenced in `CLAUDE.md` but the file is missing
- Duplicate pair is active: same trigger phrases AND same purpose, both files present simultaneously

### Warning
- Skill belongs to a defined chain (see Chains Reference below) but is missing its `## Next Step` handoff or `## See Also` section
- No trigger phrases defined anywhere in the skill
- Description is placeholder, empty, or clearly not updated

### Info
- Skill not in any defined chain (orphaned — not necessarily broken, just unconnected)
- Missing `user-invocable` frontmatter field
- Skill listed in `CLAUDE.md` but not in `skills-map.md` (registered in one place but not the other)

---

## Phase 3: Write Report

Write `data/skill-scan-YYYY-MM-DD.md`:

```
# Skill Scan — YYYY-MM-DD

## Summary
- N critical · N warnings · N info
- Scanned: N AIOS skills, N Superpowers plugins

## Critical
- [ ] [skill-name] — [finding description]

## Warning
- [ ] [skill-name] — [finding description]

## Info
- [ ] [skill-name] — [finding description]

---
_Notes added during triage will appear below each item._
```

If a scan report for today already exists, append a timestamped section rather than overwriting.

---

## Phase 4: Feed the Backlog

Read `data/skill-improvement-backlog.md`. For each **Critical** and **Warning** finding not already present in the backlog:

- Critical findings → append under `## Cleanup tasks`
- Warning findings about missing chain handoffs → append under `## Wiring tasks`
- Warning findings about triggers/descriptions → append under `## Cleanup tasks`

Format each item as:
```
- [ ] `[skill-name]` — [action to take] — [one-line reason from finding]
```

Do not duplicate items already in the backlog.

---

## Phase 5: Triage Prompt

After the report is saved, prompt:

> "Scan complete — report saved to `data/skill-scan-YYYY-MM-DD.md`. Want to triage any findings interactively? Give me a skill name or finding number."

**Triage loop per finding:**
1. Show the full finding detail
2. Ask: "What's your note on this?"
3. Append the note inline in the report file directly under that item
4. Ask: "Next one, or done?"

User exits triage by saying "done." Never push them to continue.

---

## Chains Reference

Used in Phase 2 to detect missing handoffs (Warning tier). A skill "belongs to a chain" if it appears in this table. Check for `## Next Step` pointing to the next skill in the chain, and `## See Also` listing chain neighbors.

| Chain | Sequence |
|---|---|
| **Session loop** | `daily-brief` → `note` → `session-close` |
| **Dev pipeline** | `dev-audit` → `qa` → `cso` → `ship` → `retro` |
| **Project setup** | `init` → `system-architect` → `business-setup` or dev pipeline |
| **Business** | `business-setup` → `pod-mapper` → `pod` |
| **Multi-agent** | `pod` → `pod-review` → `finishing-a-development-branch` |
| **UX** | `ux-gate` → (build) → `ux-scan` → `dev-audit` |

Note: `qa`, `cso`, and `ship` in the dev pipeline refer to gstack equivalents — check `dev-audit` and `retro` for handoffs to those gstack skills.

---

## Known Duplicate Pairs

Use this table in Phase 2 Critical detection. If both sides of a pair are present and active, flag as Critical.

| Local skill | Gstack/Superpowers equivalent | Resolution |
|---|---|---|
| `skills/browse.md` | gstack `/browse` | Remove local — gstack is more capable |
| `skills/cso.md` | gstack `/cso` | Remove local — gstack has full OWASP scan |
| `skills/qa.md` | gstack `/qa` | Remove local — gstack integrates with test runner |
| `skills/ship.md` | gstack `/ship` | Remove local — gstack has version bump + changelog |
| `skills/retro.md` | gstack `/retro` | Keep local — reads AIOS session logs |
| `skills/office-hours.md` | gstack `/office-hours` | Keep local — routes to debugging |

---

## Edge Cases

- **Single-skill scan (`/skill-scan [name]`)** — Run all five scan phases but filter findings to that skill only. The scan checks *registration and chain membership* — not skill quality, content correctness, or edge case coverage. Still write a full report and feed the backlog.
- **Triage-only (`/skill-scan triage [name]`)** — Skip scan phases. Read the most recent `data/skill-scan-*.md` and go straight to the triage loop for that skill.
- **No scan report exists yet for triage-only** — Tell the user: "No scan report found. Run `/skill-scan` first to generate one."
- **`data/` doesn't exist** — Create it. Never fail silently.
- **Backlog file missing** — Create it with the three-section template before appending.
- **Finding already in backlog** — Skip it. Check by skill name + action text match.

## See Also

- `/skill-navigator` — always-on router that uses `skills-map.md`; scan findings affect its accuracy
- `data/skill-improvement-backlog.md` — living backlog fed by this scan
- `docs/superpowers/specs/2026-03-30-skill-inventory-redesign.md` — chains and duplicate resolution spec
