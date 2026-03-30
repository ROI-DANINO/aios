---
name: session-close
description: >
  End-of-session wrap-up. Derives what happened from git log, session context, and
  conversation history — no questions asked. Accepts an optional note as an argument.
  Writes a session log to data/session-log-YYYY-MM-DD.md and extracts memory.
  Use when user says "/session-close", "wrap up", "I'm done for today",
  "closing out", "end session", "signing off", "bye", or similar.
user-invocable: true
argument-hint: "[optional note]"
---

# Session Close

End clean. Know where you stopped. Come back faster.

## When to Trigger

- User says "/session-close", "wrap up", "I'm done", "closing out", "end session", "signing off", "bye"
- End of any working session
- Before stepping away for more than a few hours

## Process

### Phase 1: Derive session context (silent)

Do NOT ask questions. Infer from:

1. **Conversation history** — what was discussed, built, or decided this session
2. **`git log --oneline -10`** in any active project dirs mentioned this session
3. **`data/daily-brief-YYYY-MM-DD.md`** — what was the stated focus for today
4. **Argument passed** — if user passed a note (e.g. `/session-close fixed the auth bug`), include it verbatim in the Notes field

### Phase 2: Write the session log

Write `data/session-log-YYYY-MM-DD.md`:

```markdown
# Session Log — YYYY-MM-DD

## What Shipped
[Inferred from conversation and git log]

## Blocked / Unresolved
[Anything left open or explicitly flagged — or "None"]

## Next Session — First Task
[Last open thread or stated next step — or "Not specified"]

## Notes
[Argument passed by user, or "None"]
```

If a file for today already exists (multiple sessions in one day), append with timestamp:

```markdown
---

## Session 2 — HH:MM

## What Shipped
...
```

### Phase 3: Update notes.md

If a clear next task was inferred, append to `data/notes.md`:

```
### [YYYY-MM-DD] — [Project]
[next task] #next
```

Skip if nothing actionable was inferred.

### Phase 4: Memory extraction

Scan the session for anything that should persist across sessions. Extract only what's non-obvious and wouldn't be derivable from the code or git log.

**Extract if present:**
- A decision that was made and the reasoning behind it (→ `project` memory)
- A pattern that worked or failed (→ `feedback` memory)
- A project milestone completed or new blocker surfaced (→ `project` memory)
- Something learned about how Roi likes to work (→ `user` memory)

**Skip:**
- Routine task completions — these are in the session log
- Anything already in MEMORY.md
- Vague observations with no actionable consequence

For each item worth saving: write it to `memory/[type]_[topic].md` using the standard frontmatter format, then add a pointer line to `memory/MEMORY.md`.

### Phase 5: Close out

Confirm in two lines:

```
Session logged. [next task or "Nothing queued"] is up next.
Come back fresh.
```

No summary. No motivational sign-off. Log and done.

## Edge Cases

- **Nothing in conversation history** — Log: "No activity recorded this session."
- **Multiple blockers** — List all.
- **Multiple sessions in one day** — Append, never overwrite.
- **`data/` doesn't exist** — Create it. Never fail.

## Next Step

After closing: start the next session with `/daily-brief` to pick up the queued next task.

## See Also

- `/daily-brief` — run at the start of the next session to pick up where you left off
- `/note` — mid-session capture that feeds into this log
