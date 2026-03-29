---
name: ux-scan
description: >
  Use when you want to audit an existing codebase for UX problems — features with
  no clear purpose, UI with no clear user, or flows with no clear outcome. More
  aggressive than ux-gate audit: reads actual code to infer intent, not just file names.
  Triggers: "ux scan", "find ux issues", "audit ux", "what features are unclear",
  "scan for ux problems", "ux problems".
user-invocable: true
argument-hint: "[path to scan, defaults to current project]"
---

# UX Scan

Read the code. Find every feature. Flag what has no clear purpose, user, or outcome.

## When to Trigger

- User runs `/ux-scan` or asks to audit UX in an existing project
- After inheriting or returning to a codebase — before adding anything new
- When something feels off but it's unclear what

Do NOT use this instead of `ux-gate`. Gate prevents new problems. Scan finds existing ones.

---

## Process

### Phase 1: Anchor on documentation

Read in this order. Build a list of **declared features** — what the project says it does.

1. `README.md`
2. `CLAUDE.md` or `AGENTS.md`
3. `ux-decisions.md` (if it exists)
4. Anything in `docs/`

If none of these exist, declared features = zero. Everything in code is a candidate.

### Phase 2: Extract actual features from code

Do NOT just list files. Read source files and identify **feature units** — logical capabilities, not individual functions or components.

Look for:

**Entry points** (things users reach directly):
- Routes and pages (`pages/`, `app/`, `routes/`, `views/`)
- CLI commands (commander, argparse, yargs, slash command definitions)
- Exported top-level functions with domain names

**UI surfaces** (things users interact with):
- Named screens, modals, drawers, forms
- Buttons and actions with non-generic names (`ExportButton`, `DeleteAccountModal`)
- Skip generic utility components (`Spinner`, `Button`, `Input`)

**Data mutations** (things with consequences):
- Any write, update, delete, or send operation
- These always represent a user intent — flag them if that intent is unclear

**Named workflows**:
- Functions or classes with domain language (`onboardUser`, `exportInvoice`, `archiveProject`)
- These are features even if they have no UI yet

Group everything into feature units. One feature unit may span multiple files.

### Phase 3: Cross-reference and flag

For each feature unit, ask four questions:

1. **Declared?** — Does it appear in README, CLAUDE.md, or `ux-decisions.md`?
2. **Purpose clear?** — Can you state in one sentence what problem it solves for a user?
3. **User clear?** — Can you name who triggers this and why?
4. **Flow complete?** — Does it have an entry point, a clear action, and a defined outcome?

Assign severity:
- `missing` — not declared anywhere AND purpose is unclear from code
- `vague` — some intent exists but who/why/how are ambiguous
- `incomplete` — starts a flow but dead-ends or has no clear outcome

Skip: internal utilities, helpers, pure data transformations, dev tooling.

### Phase 4: Report

```
## UX Scan — [project name] — [date]

### Summary
Features found: X | Covered: Y | Issues: Z

### No Issues
- [feature name] — [one-line purpose]

### Issues

#### [feature name or inferred name] — [missing | vague | incomplete]
- Found at: [file:line or file]
- What it does (inferred): [one sentence]
- UX gap: [what's missing — purpose / user / flow outcome]
- Suggested action: [run /ux-gate to fill in | delete if unused | clarify intent first]
```

After the report, ask: "Want to work through any of these now? I can run `/ux-gate` on each one."

---

## What to Skip

Do not flag:
- Files named `utils`, `helpers`, `lib`, `hooks` unless they contain domain logic
- Generic UI primitives (`Button`, `Input`, `Layout`, `Spinner`)
- Config files, build files, test files
- Internal state management (reducers, stores) unless they represent a named user action

When unsure whether something is a feature: if a real user would ever notice it exists, it counts.

---

## Edge Cases

- **Large codebase** — Scan by directory or feature area. Report scope clearly: "Scanned `src/features/` — did not scan `src/lib/`."
- **No documentation at all** — Note this at the top of the report. Every extracted feature is a candidate.
- **Unfamiliar framework** — State your confidence: "Inferred from file structure, not confirmed by reading all routes."
- **Everything is undocumented** — Don't flag 50 issues at once. Group by area and prioritize: which missing UX records carry the most risk?
