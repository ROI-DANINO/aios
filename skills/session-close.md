---
name: session-close
description: >
  End-of-session wrap-up. Asks what got done, what's blocked, and what's next.
  Writes a session log to data/session-log-YYYY-MM-DD.md, appends open threads tagged
  #next to data/notes.md, and optionally flags anything that should become a formal
  deliverable. Use when user says "/session-close", "wrap up", "I'm done for today",
  "closing out", "end session", or "signing off".
user-invocable: true
argument-hint: "[optional]"
---

# Session Close

End clean. Know where you stopped. Come back faster.

## When to Trigger

- User says "/session-close", "wrap up", "I'm done", "closing out", "end session", "signing off"
- End of any working session
- Before stepping away for more than a few hours

## Process

### Phase 1: Three questions

Ask in one block:

> **Closing out. Three quick ones:**
> 1. What did you ship or move forward today?
> 2. What's blocked or unresolved?
> 3. What's the first thing you're picking up next session?

Accept short answers. One follow-up max if something is too vague to be actionable: "On what specifically?"

### Phase 2: Check for deliverable (optional)

Scan the answers. If anything sounds like a decision locked or a plan finalized, ask once:

> "Sounds like [X] might be worth formalizing — should I save that as a deliverable?"

If yes: create `deliverables/plan-[topic]-YYYY-MM-DD.md` with a one-paragraph summary. If no: skip. Don't ask twice.

### Phase 3: Write the session log

Write `data/session-log-YYYY-MM-DD.md`:

```markdown
# Session Log — YYYY-MM-DD

## What Shipped
[Roi's answer to Q1]

## Blocked / Unresolved
[Roi's answer to Q2, or "None"]

## Next Session — First Task
[Roi's answer to Q3]

## Notes
[Any extra context, or "None"]
```

If a file for today already exists (multiple sessions in one day), append with timestamp:

```markdown
---

## Session 2 — HH:MM

## What Shipped
...
```

### Phase 4: Update notes.md

Append to `data/notes.md` for each next task:

```
### [YYYY-MM-DD] — [Project]
[next task text] #next
```

### Phase 5: Memory extraction

Scan the session answers for anything that should persist across sessions. Extract only what's non-obvious and wouldn't be derivable from the code or git log.

**Extract if present:**
- A decision that was made and the reasoning behind it (→ `project` memory)
- A pattern that worked or failed that you'd want to repeat or avoid (→ `feedback` memory)
- A project milestone completed or a new blocker surfaced (→ `project` memory)
- Something learned about how Roi likes to work (→ `user` memory)

**Skip:**
- Routine task completions ("fixed the bug") — these are in the session log
- Anything already in MEMORY.md
- Vague observations with no actionable consequence

For each item worth saving: write it to `memory/[type]_[topic].md` using the standard frontmatter format (`name`, `description`, `type`), then add a pointer line to `memory/MEMORY.md`.

If nothing worth extracting: skip silently. Don't note the absence.

### Phase 6: Close out

Confirm in two lines:

```
Session logged. [next task] is queued for tomorrow.
Come back fresh.
```

No summary. No motivational sign-off. Log and done.

## Edge Cases

- **One-word answers** — Log as-is. Don't pad.
- **Nothing shipped** — Log honestly: "No features shipped. Research/debugging session."
- **Multiple blockers** — List all. Don't prioritise for Roi.
- **"Not sure" on deliverable question** — Skip it. Don't push.
- **Multiple sessions in one day** — Append, never overwrite.
- **`data/` doesn't exist** — Create it. Never fail.
