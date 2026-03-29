---
name: retro
description: >
  Sprint retrospective. Reads session logs and git log to surface what shipped,
  what didn't, one process improvement, and the next sprint focus. Use when user
  says "retro", "retrospective", "end of sprint", "what did we learn", or
  "sprint review".
user-invocable: true
argument-hint: "[sprint name or date range, e.g. 'week of Mar 24'] — defaults to last 7 days"
---

# Retro

Look back. Be honest. Move forward smarter.

## When to Trigger

- "retro"
- "retrospective"
- "end of sprint"
- "what did we learn"
- "sprint review"
- At the end of a dev cycle, after `/ship`

## Process

### Phase 1: Load context (silent)

1. Determine time range: argument if provided, else last 7 days
2. Read `data/session-log-*.md` files within the range (list files in `data/`)
3. Run: `git log --oneline --since="{start_date}" --until="{end_date}"`
4. Read `context/my-goals.md` — top 3 priorities for alignment check

### Phase 2: Build the retro

Answer these four questions from the data:

**1. What shipped?**
Pull from git tags, commits with `feat:` prefix, and session logs marked as completed.

**2. What didn't ship?**
Cross-reference session logs against git — things logged as planned but no corresponding commit. Also check for #blocker tags in notes.

**3. What slowed us down?**
Look for patterns: repeated debugging sessions, blockers mentioned multiple times, tasks that took multiple sessions.

**4. What's the one process improvement?**
Based on question 3, suggest exactly one change. Be specific. Not "communicate better" — "add a `/cso` pass before final review so security issues don't surface at ship time."

### Phase 3: Output the retro

```
## Sprint Retro — {date range}

### What Shipped ✓
{bullet list — specific features/fixes, linked to commits where possible}
{or "Nothing shipped this sprint."}

### What Didn't Ship ✗
{bullet list — planned but not done, with honest reason if visible in the data}
{or "Everything planned shipped."}

### What Slowed Us Down
{bullet list — specific friction points from session logs/notes}
{or "No major blockers this sprint."}

### One Process Improvement
{Single specific change to make next sprint better}

### Goals Alignment
{One sentence: how this sprint's output maps to the top priorities in my-goals.md}

### Next Sprint Focus
{Top 1-2 priorities for the next sprint, derived from "What didn't ship" + goals}
```

## Edge Cases

- **No session logs** — Use git log only. Note: "No session logs found — retro based on git history only."
- **No commits in range** — Report honestly: "No commits in this range. Was this a planning/thinking sprint?"
- **my-goals.md missing** — Skip goals alignment section.
- **Argument is a sprint name** — Try to match to session log filenames or notes containing the sprint name.

## Next Step

After the retrospective: update `context/my-goals.md` if priorities shifted, then start the next sprint with `/daily-brief`.

## See Also

- `/dev-audit` — feeds into retro via session logs and git history
- `/daily-brief` — next session start, picks up the sprint focus from retro output
- `/ship` (gstack) — the step before retro in the dev pipeline
