---
name: context-clean
description: >
  Periodic AIOS data maintenance. Archives stale daily-briefs (keep last 7 days),
  archives old skill-scan reports (keep last 2), compacts notes.md by inferring
  which #next/#idea entries shipped via session-logs and git, checks MEMORY.md
  for broken pointers and dedup candidates, then outputs a terse summary.
  Run every 3-5 sessions or when /daily-brief surfaces 5+ open #next threads.
  Use when user says "/context-clean", "clean up AIOS data", "prune data",
  "compact notes", "AIOS maintenance", or "data is getting fat".
user-invocable: true
argument-hint: "[--dry-run | --notes-only | --memory-only]"
tools:
  - Read
  - Write
  - Edit
  - Glob
  - Bash
---

# Context Clean

Periodic maintenance. Archive stale files, compact notes, check memory health.

## When to Trigger

- User says "/context-clean", "clean up AIOS data", "prune data", "compact notes", "AIOS maintenance", "data is getting fat"
- `/daily-brief` surfaces a maintenance flag (5+ open #next threads)
- Every 3-5 sessions as routine upkeep

## Arguments

- No argument — full run (all five phases)
- `--dry-run` — show all proposed actions, execute nothing, write no report
- `--notes-only` — skip archive phases, run only notes compaction + memory check
- `--memory-only` — run Phase 4 only (memory health check)

## Process

### Phase 1: Inventory (silent — do not narrate)

1. List all `data/daily-brief-*.md` files. Sort by date descending. Mark the 7 most recent as KEEP. All others are ARCHIVE candidates.
2. List all `data/skill-scan-*.md` files. Sort by date descending. Mark the 2 most recent as KEEP. All others are ARCHIVE candidates.
3. Read `data/notes.md` in full. Extract every entry tagged `#next` or `#idea`. Record: date, project, note text.
4. Read all `data/session-log-*.md` files. Extract every "What Shipped" section. Build a flat list of shipped items.
5. For each project referenced in notes (aios, hermes-integration, captionate, etc.), run `git log --oneline -30` in `~/Desktop/Projects/<project>/` if the directory exists. Collect commit messages as shipped evidence. If a project dir doesn't exist, skip and note it.
6. Read `memory/MEMORY.md`. For each pointer in the index, check whether the referenced file exists in `memory/`. For each file in `memory/` (except MEMORY.md itself), check whether it is referenced in MEMORY.md. Scan all pointer labels for semantic topic overlap.

### Phase 2: Propose and confirm archive

Skip this phase if `--notes-only` or `--memory-only` is passed.

Present this block:

```
**Context Clean — Proposed Actions**

Daily briefs to archive (keep last 7 days):
- [list of files → ~/.aios-archive/daily-briefs/ — or "None within 7-day window."]

Skill-scan reports to archive (keep last 2):
- [list of files → ~/.aios-archive/skill-scans/ — or "None within limit."]

Confirm? [y / n / skip-archives]
```

Wait for response.
- **y** — execute moves. Use `mkdir -p` to create archive dirs if missing. Move files with `mv`. Never use `rm`.
- **n** — skip archive entirely, move to Phase 3.
- **skip-archives** — same as n.
- **dry-run mode** — show block, add `(dry run — no changes made)`, execute nothing.

### Phase 3: Notes compaction

Skip this phase if `--memory-only` is passed.

**Step 3a: Inference (silent)**

For each `#next` or `#idea` entry from Phase 1, apply rules in order:

1. **ARCHIVE (shipped)** — verb+noun in the note text matches a "What Shipped" item from any session log, or matches a git commit message. Record the source: `(shipped — seen in session-log YYYY-MM-DD / git)`.
2. **ARCHIVE (superseded)** — a newer note on the same project explicitly covers the same task or next step and is more specific.
3. **FLAG (stale)** — entry is 14+ days old AND no session log or git activity references that project in the past 14 days.
4. **KEEP** — does not meet any rule above.

Special rule for `#idea` entries: only mark ARCHIVE if explicitly shipped or superseded. Age alone never archives an idea.

When inference is ambiguous, default to KEEP.

**Step 3b: Present and confirm**

```
**Notes compaction — proposed:**

Archive (shipped / superseded):
- [date] [project] — "[note text]" → [reason]
[or "None — all entries are active or ambiguous."]

Flag for your review (stale, uncertain):
- [date] [project] — "[note text]" → [reason]
[or "None."]

Keep (active):
- [date] [project] — "[note text]"
[list]

Proceed? [y / n / edit]
```

Wait for response.
- **y** — rewrite `data/notes.md`, removing ARCHIVE entries. Keep KEEP and FLAG entries. Never silently remove a FLAG entry.
- **n** — skip notes compaction, move to Phase 4.
- **edit** — present the list again. Accept per-item overrides: "keep [partial text]" or "archive [partial text]". Re-confirm full list before writing.
- **archive all flagged** — remove all FLAG entries too. Confirm count before writing.
- **dry-run mode** — show block, add `(dry run — no changes made)`, execute nothing.

### Phase 4: Memory health check (report only — no auto-action)

Run checks silently. Then output:

```
**Memory health:**

Orphan pointers (MEMORY.md points to missing files):
- [list or "None"]

Orphan files (memory/*.md not referenced in MEMORY.md):
- [list or "None"]

Dedup candidates (possible overlapping topics):
- [list pairs with overlapping labels, or "None"]
```

No automatic action. Roi decides what to do with the flags.

If MEMORY.md has no index section or is malformed: output `MEMORY.md structure unexpected — skipping memory health check.`

### Phase 5: Summary report

Skip writing the report if `--dry-run` is passed.

Write `data/context-clean-YYYY-MM-DD.md`. If a file for today already exists, append a timestamped section rather than overwriting.

```markdown
# Context Clean — YYYY-MM-DD

## Archived
- Daily briefs: N files → ~/.aios-archive/daily-briefs/
- Skill-scan reports: N files → ~/.aios-archive/skill-scans/
- Notes entries removed: N (shipped/superseded)

## Flagged for Review
- Notes (stale, unconfirmed): [list or "None"]
- Memory orphan pointers: [list or "None"]
- Memory orphan files: [list or "None"]
- Memory dedup candidates: [list or "None"]

## Kept
- Daily briefs: N (within 7-day window)
- Skill-scan reports: N (within limit)
- Notes entries kept: N active
```

Confirm: `Context clean complete. [N items archived, N flagged for review.]`

## Edge Cases

- **Archive dirs don't exist** — create with `mkdir -p ~/.aios-archive/daily-briefs/` and `mkdir -p ~/.aios-archive/skill-scans/` before moving
- **All daily-briefs within 7-day window** — output "Nothing to archive — all briefs within 7 days." Skip that item in the confirmation block
- **No tagged notes in notes.md** — output "No tagged notes found — notes.md is already clean." Skip Phase 3 confirmation
- **Project git dir not accessible** — skip git check for that project; note "git not checked for [project]" in inference output
- **Session log "What Shipped" is empty** — that log provides no shipment evidence
- **data/ doesn't exist** — create it before writing the report
- **--dry-run** — run all phases, show all proposed actions, add "(dry run — no changes made)" to every block, execute nothing, write no report file

## Next Step

After clean completes: run `/daily-brief` if starting a session, or `/session-close` if ending one.

## See Also

- `/note` — mid-session capture
- `/session-close` — end of session log and memory extraction
- `/skill-scan` — skill registry audit; also feeds `data/skill-improvement-backlog.md`
- `/daily-brief` — surfaces maintenance flag when 5+ open #next threads
