---
name: memory-audit
description: >
  Targeted memory health check — verify MEMORY.md pointers, flag stale entries (>30 days
  project-type), find contradictions. Use when user says "/memory-audit", "audit memory",
  "memory health", "something off with my memory".
user-invocable: true
tools:
  - Read
  - Write
  - Edit
  - Glob
---

# Memory Audit

Verify memory integrity before it silently misleads a session.

## When to Trigger

- User types `/memory-audit`
- User says "audit memory", "memory health", "something off with my memory"
- Post-`/aios-health` if memory section flagged issues
- Before a long strategy session where memory ground truth matters

## Process

### Step 1 — Read the index

Read `memory/MEMORY.md`. Parse all markdown link entries in the format `[Title](file.md)`.

### Step 2 — Verify pointers

For each linked file, check if it exists via Read (expect an error if missing). Categorize:
- **OK** — file exists and is readable
- **Broken** — file does not exist

### Step 3 — Flag stale entries

For each file that exists, check its last modified date (read the file and look for a date header or `updated:` field). If entry type is `project` and the last update is >30 days ago, flag as **Stale**.

If no date is present in the file, note it as **Undated**.

### Step 4 — Contradiction scan

Read all project-type memory files. Look for conflicting claims:
- Two files both claiming "active" status for mutually exclusive states
- Contradictory priorities (e.g., two projects both marked "top priority")
- Deprecated decisions still marked current

Flag any pair that appears to contradict as **Contradiction**.

### Step 5 — Report

Output structured report:

```
## Memory Audit — YYYY-MM-DD

### OK (N entries)
- [Title](file.md)

### Broken Pointers (N)
- [Title](file.md) — file not found

### Stale (N — >30 days, project-type)
- [Title](file.md) — last updated YYYY-MM-DD

### Undated (N)
- [Title](file.md) — no date found

### Contradictions (N)
- [FileA](a.md) vs [FileB](b.md) — both claim X

### Recommendation
[One line summary + suggested action]
```

### Step 6 — Offer fixes

- **Broken pointers:** Ask: "Remove these broken entries from MEMORY.md? (y/n)"
  - If yes: Edit MEMORY.md to remove broken lines only.
- **Stale:** Surface them but do not auto-fix. Ask user to decide.
- **Contradictions:** Present both files, ask user to resolve manually.
- **Undated:** Note only — do not auto-fix.

## Edge Cases

- **MEMORY.md empty or missing** — Warn: "No memory index found. Run `/session-close` to start building one."
- **All entries OK** — Output: "Memory index clean. No action needed."
- **No project-type entries** — Skip stale check, note it.

## See Also

- `/context-clean` — archives stale data files, compacts notes
- `/aios-health` — full system audit including memory subagent
- `/session-health` — quick sanity check (index entry count only)
