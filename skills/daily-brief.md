---
name: daily-brief
description: >
  Session-start orientation. Reads context/my-goals.md, scans data/notes.md for
  yesterday's notes, checks deliverables/ for open plans, and proposes a focused
  session agenda — 1 to 3 tasks max. Confirms focus with Roi, then writes the brief
  to data/daily-brief-YYYY-MM-DD.md. Use when user says "/daily-brief", "start my
  session", "what should I work on", "give me my brief", "orient me", or at the start
  of any working session.
user-invocable: true
argument-hint: "[optional focus area, e.g. 'backend']"
tools:
  - Read
  - Write
  - Glob
---

# Daily Brief

Session start. Cut the fog. Pick your focus before you open a file.

## When to Trigger

- User says "/daily-brief", "start my session", "orient me", "what should I work on today"
- Beginning of any working session — before any feature work or task picking
- User feels directionless or wants rails before starting

## Process

### Phase 1: Load context (silent — do not narrate this to the user)

1. Read `context/my-goals.md`. Note the top 3 priorities.
2. Read `data/notes.md`. Find all entries from yesterday. Extract any tagged #blocker, #next, or #decision.
3. List files in `deliverables/`. Flag any that look like open plans — filenames containing "plan", "pod-map", "brief", or "v3".
4. Check for a recent `data/aios-health-*.md` file (within the last 7 days). If one exists, read its **Suggested Improvement Tasks** section and extract: (a) all Immediate items, (b) up to 2 This week items. Hold these — they may surface in the agenda.
5. If an argument was passed (e.g. `/daily-brief backend`), treat it as a focus constraint.

### Phase 2: Propose the agenda

Count all `#next` entries in `data/notes.md`. If 5 or more, prepend this line before the agenda block:

> **Maintenance flag:** 5+ open #next threads — consider running `/context-clean` this session.

If a recent health report was found in Phase 1 with Immediate improvement tasks, prepend this line:

> **AIOS health flag:** [N] immediate improvement task(s) from last health report — see AIOS Health section below.

Present this in a compact block. No preamble. Lead with yesterday's threads:

```
**Yesterday's open threads:**
- [notes tagged #next or #blocker, if any — or "Nothing flagged from yesterday."]

**Open deliverables:**
- [open plans from deliverables/, or "None."]

**Proposed focus for today — pick 1:**
1. [Most important task tied to top goal in my-goals.md]
2. [Second option if genuinely ambiguous]
3. [Third option only if 1 and 2 are both blocked]

**AIOS Health** _(only if a recent health report exists)_
Immediate:
- [ ] [task from Suggested Improvement Tasks → Immediate]
This week:
- [ ] [task 1]
- [ ] [task 2]
Report: data/aios-health-YYYY-MM-DD.md
```

3 tasks max for the main focus. The AIOS Health section is supplemental — it does not replace the focus tasks, it runs alongside them. Omit the AIOS Health section entirely if no report exists within the last 7 days.

### Phase 3: Confirm or adjust

Ask exactly this:

> "Which one are you starting with — or does something else take priority today?"

Wait. Do not suggest more options.

### Phase 4: Write the brief

Write `data/daily-brief-YYYY-MM-DD.md`:

```markdown
# Daily Brief — YYYY-MM-DD

## Session Focus
[Roi's confirmed task(s)]

## Open Threads from Yesterday
[list or "None"]

## Open Deliverables
[list or "None"]

## Goals Alignment
[one sentence: how today's focus maps to 90-day priorities]

## AIOS Health Tasks
_(omit this section entirely if no health report within last 7 days)_

Immediate:
- [ ] [task]

This week:
- [ ] [task]
- [ ] [task]

_From: data/aios-health-YYYY-MM-DD.md_
```

Confirm: `Brief saved. Go build.`

## Edge Cases

- **No notes from yesterday** — Omit the section. Don't say "I couldn't find anything."
- **Roi's answer is "none of those"** — Ask: "What's the one thing that moves the needle today?" Write that in.
- **Called mid-session** — Still run it. Overwrite today's brief if it already exists.
- **`data/` doesn't exist** — Create it before writing.
- **Goals file looks stale (30+ days old)** — Flag: "my-goals.md hasn't been updated recently — brief is based on current content."
- **Argument passed but no matching threads** — Say: "Nothing in your open threads matches '[arg]' — proposing from goals instead."

## Session Chain Reminder

After presenting the agenda, always append this to your response:

---
**Session chain active:**
- Mid-session captures: `/note "your note" #tag` — use tags: #decision #blocker #idea #next
- End of session: run `/session-close` before you close Claude — session data won't be saved otherwise

---

## Next Step

After your session focus is confirmed: use `/note "text"` to capture decisions and blockers mid-session. When done, run `/session-close` to log the session and extract memory.

## See Also

- `/note` — mid-session capture
- `/session-close` — end of session log and memory extraction
