---
name: note
description: >
  Quick mid-session capture. Takes one line of text as an argument and appends it to
  data/notes.md with today's date and the current project. Supports optional inline tags
  (#idea, #blocker, #decision, #next). When called with no argument, surfaces the last
  10 notes. Use when user says "/note", "log this", "capture this", "remember this",
  "quick note", or wants to flag something without losing flow.
user-invocable: true
argument-hint: '"your note text here #tag"'
---

# Note

Quick capture. One command. Back to work.

## When to Trigger

- User types `/note "..."` with a note in quotes or inline
- User says "log this", "capture this", "quick note", "remember this"
- User types `/note` with no argument — surface recent notes
- Mid-session, user flags something they don't want to lose

## Process

### When called with an argument

1. Parse the argument. Extract any inline tags (#idea, #blocker, #decision, #next). If no tag present, write the note untagged.
2. Determine today's date (YYYY-MM-DD format).
3. Determine the current project. Check `memory/MEMORY.md` for active project. Default to "Captionate v3" if not set.
4. Format the note entry:

```
### [YYYY-MM-DD] — [Project]
[note text] [#tags if present]
```

5. Append to `data/notes.md`. If the file doesn't exist, create it with a header:

```markdown
# Notes Log

Raw captures. Tagged by project and date.
```

6. Confirm in one line: `Logged. [tag if present]`

Do not summarise. Do not add commentary. Just confirm and stop.

### When called with no argument

1. Read `data/notes.md`.
2. Show the last 10 entries, most recent first.
3. Ask: "Anything you want to add?"

## Edge Cases

- **Multiple tags** — Keep all. `/note "retry logic broken #blocker #decision"` logs both.
- **Note is a fragment** — Log as-is. It's a capture, not a draft.
- **`data/notes.md` doesn't exist** — Create it. Never fail silently.
- **No project context** — Default to "Captionate v3".
- **Just a tag, no text** — Ask: "What's the note?"
- **Very long note** — Log without truncation. If 3+ sentences, suggest: "This might belong in a deliverable — want me to save it there instead?"
