---
name: session-redo
description: >
  Use when a session log entry is wrong, incomplete, or doesn't reflect what actually happened.
  Triggers on: "redo the session log", "fix the session log", "the log is wrong",
  "update what really happened", or any correction to a prior session-close entry.
user-invocable: true
argument-hint: "[optional: session number or date to redo — defaults to latest]"
tools:
  - Read
  - Write
  - Edit
  - Glob
---

# Session Redo

Fix the record. Don't let a bad log mislead the next session.

## When to Trigger

- User says the session log is wrong, incomplete, or missing something
- A session-close ran with bad information (e.g. subagents didn't log, ambiguous "already done" results)
- User says "redo the session log", "fix the log", "that's not what happened"

## Process

### Phase 1: Identify which entry to fix

If an argument was passed (session number or date), target that entry.
Otherwise, default to the most recent session entry in `data/session-log-YYYY-MM-DD.md`.

### Phase 2: Gather evidence (silent)

1. Read the current session log — find the target entry.
2. Run `git log --oneline -20` — identify commits from this session.
3. Check `data/notes.md` for any `#next`, `#blocker`, or `#decision` tags from today.
4. If subagents were involved, note what was reported (done vs already-existing vs blocked).

### Phase 3: Rewrite the entry

Replace the target session entry with an accurate one. Use the standard format:

```markdown
## Session N — closing

## What Shipped
[What was actually done — backed by git commits or direct observation]

## Blocked / Unresolved
[What didn't happen, what's still open]

## Next Session — First Task
[First unblocked task for next session]

## Notes
[Any lessons, ambiguities, or corrections from the original entry]
```

Rules:
- **Be specific about what's confirmed vs ambiguous.** If you can't tell whether something was done now or pre-existing, say so.
- **Don't invent.** If git has no commits for something, say "no commit found — may have been pre-existing."
- **Preserve prior entries.** Only rewrite the targeted entry — don't touch the rest of the file.

### Phase 4: Confirm

After writing: show the user the rewritten entry and confirm: "Session log updated."

## Edge Cases

- **No git commits this session** — note it explicitly. Log what was discussed or decided even if no code changed.
- **Subagents did work with no session-close** — note the gap. Log what they reported + that no subagent log exists.
- **Multiple entries need fixing** — ask which ones, fix one at a time.
- **Log file doesn't exist yet** — run `/session-close` instead.

## Next Step

After the log is corrected: run `/session-close` again if needed, or continue with `/daily-brief` next session.

## See Also

- `/session-close` — writes the original entry; run this at end of every session
- `/daily-brief` — reads the session log at start of next session to pick up context
