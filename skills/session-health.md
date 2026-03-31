---
name: session-health
description: >
  30-second session-start sanity check — memory index intact, notes/logs in sync, open
  #next threads, all 8 agents present. Use when user says "/session-health", "quick health check",
  "is my session state okay", "anything broken before we start".
user-invocable: true
tools:
  - Read
  - Glob
---

# Session Health

Thirty seconds. Five checks. Green light or flag.

## When to Trigger

- User types `/session-health`
- User says "quick health check", "is my session state okay", "anything broken before we start"
- Before starting a long or high-stakes session
- After returning from a break of several days

## Process

Run all 5 checks, then output a single structured health summary.

### Check 1 — Memory index

Read `memory/MEMORY.md`. Count the number of `[Title](file.md)` link entries.
- OK: file exists and is readable
- Warn: >20 entries (index may be bloated — consider `/memory-audit`)
- Flag: file missing

### Check 2 — Recent session log

Glob `data/session-log-*.md`. Identify the most recent file by filename date (YYYY-MM-DD).
Read it. Extract:
- Date of the log
- Any `#next` tagged items (open threads)

Report: date of last session, count of open `#next` items.
- Warn if last session was >7 days ago
- Warn if >3 open `#next` items

### Check 3 — Notes backlog

Read `data/notes.md`. Count lines or entries tagged `#next`.
- OK: 0-5 `#next` items
- Recommend `/context-clean` if >5

### Check 4 — Agent roster

Glob `.claude/agents/*.md`. Check that all 8 expected agents are present:
`analyst`, `pm`, `architect`, `developer`, `qa`, `scrum-master`, `session-agent`, `health-agent`

Match by filename (case-insensitive, ignore extension). Report any missing.

### Check 5 — Assemble health summary

Output:

```
## Session Health — YYYY-MM-DD

| Check | Status | Detail |
|-------|--------|--------|
| Memory index | ✓ OK / ⚠ WARN / ✗ FLAG | N entries |
| Last session log | ✓ OK / ⚠ WARN | YYYY-MM-DD, N open #next |
| Notes backlog | ✓ OK / ⚠ WARN | N #next items |
| Agent roster | ✓ OK / ✗ FLAG | All 8 present / Missing: X, Y |

**Recommendation:** [One-line summary — e.g., "All clear. Start working." or "Run /context-clean before this session — notes backlog is heavy."]
```

## Skill Orientation

If this is the start of a working session and you're not sure which skill to run next, append this line to the health summary output:

> **Not sure where to start?** Run `/skills-map` for a full indexed skill reference — organized by session phase, dev workflow, and AIOS system tools.

Only append this line if the user has NOT passed any intent (e.g., they just typed `/session-health` with nothing else). If they said "session-health then I want to work on X", skip this line — they already know what they're doing.

## Edge Cases

- **data/ dir empty or missing** — Flag and note: "No session logs found. This may be a fresh install."
- **notes.md missing** — Note as OK (no backlog to clear).
- **agents/ dir missing** — Flag: "`.claude/agents/` not found — agent roster cannot be verified."
- **All checks OK** — Output: "All clear. Good to go."

## See Also

- `/skills-map` — full indexed skill reference, organized by workflow phase
- `/memory-audit` — deeper memory health check with pointer verification
- `/context-clean` — clears notes backlog and archives stale data
- `/agent-config` — add or fix missing agents
- `/aios-health` — full system audit (run monthly or when something feels off)
