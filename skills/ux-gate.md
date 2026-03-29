---
name: ux-gate
description: >
  Use when an agent is about to suggest or implement any new feature, UI element,
  capability, or command — blocks all implementation until the user answers the three
  UX questions (purpose, who, how). Also use when invoked with "audit" to scan the
  current repo for features that lack a UX record. Triggers: "ux gate", "ux audit",
  "loose ends", "ux check", "before we build", "who uses this", "what's the purpose of".
user-invocable: true
argument-hint: "[feature description | audit]"
---

# UX Gate

Stop before you build. Answer three questions first.

## When to Trigger

**Gate mode** (default):
- Any time an agent is about to suggest or implement a feature, component, route, command, or new capability
- User or agent says "let's add X", "build X", "implement X", "new feature", "I want X"
- Before invoking `brainstorming`, `writing-plans`, or any implementation skill for new functionality

**Audit mode** (when argument is `audit` or user asks for loose ends):
- `/ux-gate audit`
- "scan for loose ends", "what features don't have UX intent", "ux audit", "find undecided features"

---

## Gate Mode — Process

### Step 1: Pause all implementation intent

Do NOT invoke brainstorming, writing-plans, or any implementation skill yet.
Do NOT suggest an approach, estimate scope, or discuss technical tradeoffs.

State clearly:
> "Before we build this, I need three answers from you."

### Step 2: Ask the Three UX Questions

Present all three at once. Do not proceed until all are answered.

```
1. Purpose — What problem does this solve? Why does it exist?
2. Who — Who is the user of this feature? (their role, context, how often they'd use it)
3. How — How do they use it? (what triggers it, what they do, what they expect to happen)
```

If the user gives partial or vague answers, ask a single follow-up question to close the gap. Do not accept "I'll figure it out later" — that's what this gate prevents.

### Step 3: Save the UX record

Once all three questions are answered, write an entry to `ux-decisions.md` in the project root:

```markdown
## [Feature Name]
- **Added:** YYYY-MM-DD
- **Purpose:** [user's answer]
- **Who:** [user's answer]
- **How:** [user's answer]
```

If `ux-decisions.md` doesn't exist, create it with this header:

```markdown
# UX Decisions

Each entry records why a feature exists, who it's for, and how it's used.
Before building anything new, there must be an entry here.
```

### Step 4: Offer a feature working doc

Ask: "Want a working doc for this feature? I'll create `docs/ux/[feature-name].md` — useful if you plan to iterate on it over multiple sessions."

If yes, create `docs/ux/[feature-name].md`:

```markdown
# [Feature Name]

> **Status:** Planning
> **Created:** YYYY-MM-DD

## UX Foundation

- **Purpose:** [from ux-decisions.md entry]
- **Who:** [from ux-decisions.md entry]
- **How:** [from ux-decisions.md entry]

## Notes

_Design decisions, open questions, rejected approaches, iteration history._
```

If no, skip it. Do not create the file automatically.

### Step 5: Proceed

Now you may invoke `brainstorming` or the appropriate next skill.

---

## Audit Mode — Process

Scan the repo for feature-shaped code that lacks a UX record.

### Step 1: Read `ux-decisions.md`

Load the list of features with recorded UX decisions. If the file doesn't exist, note that every feature is a loose end.

### Step 2: Scan for features

Look for:
- UI components (React components, Vue SFCs, Svelte files, HTML pages)
- Routes (Next.js pages, Express routes, Flask endpoints, API routes)
- CLI commands (commander definitions, argparse commands, slash commands)
- Features explicitly named in README or CLAUDE.md

Collect a list of feature names/paths.

### Step 3: Cross-reference

For each found feature, check if a matching entry exists in `ux-decisions.md`. Match by name similarity — don't require exact string match.

### Step 4: Report loose ends

Output a table:

```
## UX Audit — [date]

### Covered (have UX decisions)
- [feature name] — [one-line purpose from record]

### Loose Ends (no UX record)
- [file path or feature name] — no UX decision recorded
  Suggested questions:
  1. Purpose: What does this do and why does it exist?
  2. Who: Who uses this?
  3. How: What triggers it and what do they expect?
```

Offer to run Gate mode on each loose end one at a time.

---

## Edge Cases

- **"Just do it, I know what I want"** — Respond: "I hear you. It'll take 2 minutes — what problem does this solve, who uses it, and how?" Hold the gate.
- **Feature is a bug fix, not a new feature** — Gate does not apply. Proceed normally.
- **Audit on a new/empty project** — Note the file doesn't exist yet, explain what it's for, and offer to create it.
- **Partial answers across multiple messages** — Track what's been answered. Don't re-ask answered questions.
- **Agent-generated feature (not user-requested)** — If an agent proactively suggests a feature, it must surface the gate before proposing the suggestion. Present as: "Before I suggest this, I want to check..."

## Next Step

After gate passes and the feature is built: run `/ux-scan` to audit the implementation for UX completeness.

## See Also

- `/ux-scan` — post-build UX audit, reviews what was gated here
- `/dev-audit` — overall project phase status, includes UX as a health signal
