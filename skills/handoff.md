---
name: handoff
description: >
  Structured agent-to-agent handoff — writes a handoff artifact summarizing what was done,
  decisions made, artifacts produced, what the next agent needs, and the next action.
  Use when user says "/handoff", "hand this off", "pass to QA", "ready for developer", "handoff protocol".
user-invocable: true
argument-hint: '[from <agent> to <agent>]'
tools:
  - Read
  - Write
  - Glob
---

# Handoff

Clean handoffs between agents. No context lost.

## When to Trigger

- User types `/handoff`
- User says "hand this off", "pass to QA", "ready for developer", "handoff protocol"
- At a phase boundary in a multi-agent workflow (e.g., Analyst → PM, PM → Developer, Developer → QA)
- After `/pod` or `/pod-review` completes a stage

## Process

### Step 1 — Gather handoff info

Ask the following (can be provided as inline argument or answered interactively):

1. **From:** "Which agent or role is handing off? (e.g., Analyst, PM, Developer, QA)"
2. **To:** "Which agent or role is receiving? (e.g., PM, Developer, QA, Reviewer)"
3. **Completed:** "What was completed in this stage? (brief summary)"

If argument was provided in format `from <A> to <B>`, parse from/to from it and ask only for completed.

### Step 2 — Gather artifact context

Read `data/notes.md` (last 10 entries) and glob `deliverables/` to surface relevant recent artifacts. List them for inclusion in the handoff.

### Step 3 — Write handoff artifact

Determine today's date (YYYY-MM-DD). Write to:
`deliverables/handoff-<from>-to-<to>-YYYY-MM-DD.md`

Use this structure:

```markdown
# Handoff: <From> → <To>
Date: YYYY-MM-DD

## What Was Done
[Summary of completed work — what was built, analyzed, decided, or produced]

## Key Decisions
- [Decision 1 — include rationale if available]
- [Decision 2]

## Artifacts Produced
- [List of files, reports, or deliverables created — with paths]

## What Next Agent Needs
- [Prerequisite knowledge, context, or access the receiving agent requires]
- [Any blockers to resolve before starting]

## Next Action
[The single clearest first step the receiving agent should take]

## Open Questions
- [Anything unresolved that the next agent may need to address]
```

### Step 4 — Confirm

Output: "Handoff artifact written to `deliverables/handoff-<from>-to-<to>-YYYY-MM-DD.md`. Ready for <To>."

## Edge Cases

- **Multiple handoffs same day** — Append `-2`, `-3` suffix to filename to avoid collision.
- **No deliverables found** — Leave Artifacts Produced section as "None produced in this stage."
- **Open questions unknown** — Leave as "None identified — receiving agent should confirm scope before starting."

## See Also

- `/pod` — multi-agent dev pod (this skill is called at pod stage boundaries)
- `/pod-review` — Gate 2 review after Developer handoff to Reviewer
- `/dev-audit` — understand current phase before initiating handoff
