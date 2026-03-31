---
name: context-loader
description: >
  Selectively load only the context files relevant to the current task — reduces token waste
  by reading context/ files matched to task keywords. Use when user says "/context-loader",
  "load context for X", "what context is relevant for Y".
user-invocable: true
argument-hint: '"task or topic description"'
tools:
  - Read
  - Glob
---

# Context Loader

Load only what you need. Skip what you don't.

## When to Trigger

- User types `/context-loader "task description"`
- User says "load context for X", "what context is relevant for Y"
- Before starting business-adjacent work (offers, comms, GTM, strategy)
- When context feels stale or underdefined for the current workstream

## Process

### Step 1 — Parse the task

Extract keywords from the user's argument or question. Normalize to lowercase.

### Step 2 — Match to context files

Use this keyword-to-file mapping:

| File | Load when task mentions |
|------|------------------------|
| `context/my-voice.md` | writing, copy, email, communications, tone, message, content, user-facing, announcement, post |
| `context/my-goals.md` | strategy, prioritization, what to work on, goals, roadmap, focus, what matters, OKR |
| `context/my-icp.md` | product decisions, offer design, targeting, customer, who is this for, audience, persona, ICP |
| `context/my-gtm.md` | marketing, launch, distribution, GTM, growth, channels, acquisition, go-to-market |
| `context/my-tools.md` | tech stack, tool recommendations, what tools, which software, integrations, stack |

Match is loose — if the task description contains or implies any keyword in the list, include that file.

### Step 3 — Read matched files

For each matched file, Read it. If a file is missing, note it and skip (do not error).

### Step 4 — Output

For each loaded file, output one line:

```
Loaded context/my-voice.md — [one-line summary of what it contains]
```

If no files matched: "No context files matched. Try being more specific (e.g., 'writing copy', 'planning strategy')."

If all 5 matched: Note "Loading all context files — consider narrowing the task description to reduce token usage."

## Edge Cases

- **No argument** — Ask: "What task or topic are you loading context for?"
- **context/ dir missing** — Warn: "context/ directory not found. Run `/business-setup` to initialize it."
- **File exists but is empty** — Note: "[file] is empty — may need to be filled in."

## See Also

- `/business-setup` — populates context/ from scratch
- `/daily-brief` — loads goals context for session orientation
- `/context-clean` — archives stale context data (not context/ files, but data/)
