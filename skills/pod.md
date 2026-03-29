---
name: pod
description: >
  Dev Pod entry point. Accepts a task, runs Planner agent to decompose it into a manifest,
  presents Gate 1 approval, then dispatches Coder and Tester agents via /conductor.
  Use when user says "pod", "spin up a dev team", "multi-agent this", "dispatch this feature",
  "run the dev pod", or "use the pod for X".
user-invocable: true
argument-hint: '"task description" — e.g. "add image resizing to Captionate"'
---

# Pod

One task in. A coordinated dev team out.

## When to Trigger

- "pod [task]"
- "spin up a dev team"
- "multi-agent this"
- "dispatch this feature"
- "run the dev pod on X"
- Any feature/fix that would benefit from parallel Coder + Tester execution

## Pre-Flight

1. Verify Claude Code CLI is available:
```bash
claude --version
```
If missing: "Claude Code CLI not found. Install at claude.ai/code."

2. Verify no active pod manifest is blocking:
```bash
cat memory/pod-manifest.md 2>/dev/null | grep "^**Status:**"
```
If status is `pending-gate-1` or `in-progress`: "There is an active pod manifest. Run `/pod-review` to complete it, or delete `memory/pod-manifest.md` to start fresh."

## Phase 1: Parse Task

If argument provided, use it as the task description.
If no argument, ask: "What task should the Dev Pod work on?"

## Phase 2: Run Planner Agent

Spawn the Planner agent as a headless Claude Code session:

```bash
claude --dangerously-skip-permissions -p "$(cat <<'PROMPT'
You are the Planner agent in the AIOS Dev Pod. Read your role definition at agents/dev-pod/planner.md and follow it exactly.

Task: {TASK_DESCRIPTION}

Project root: /home/roking/Desktop/Projects/aios
Write your manifest to memory/pod-manifest.md.
PROMPT
)" > .tmp/pod-planner-log.txt 2>&1
```

Wait for the session to complete (poll for `memory/pod-manifest.md` to exist, max 60 seconds).

If manifest not written after 60s: "Planner agent timed out. Check `.tmp/pod-planner-log.txt` for errors."

## Phase 3: Gate 1 — Present Manifest

Read `memory/pod-manifest.md` and present it to the user:

```
## Dev Pod — Gate 1: Task Split

**Task:** {task name from manifest}

**Sub-tasks:**
{list each sub-task with agent assignment and scope}

**Dependencies:** {from manifest}
**Out of scope:** {from manifest}

─────────────────────────────
Approve this split? (yes / revise / cancel)
```

**HARD RULE: Do not proceed until explicit approval is received.**

- **yes** → proceed to Phase 4
- **revise** → ask what to change, update `memory/pod-manifest.md`, re-present
- **cancel** → delete `memory/pod-manifest.md`, report "Pod cancelled."

## Phase 4: Dispatch via Conductor

Update manifest status to `in-progress`.

For each sub-task in the manifest, write a conductor task prompt to `.tmp/conductor-task-{N}.md`:

```markdown
# Task {N}: {sub-task name}

## Context
You are the {agent role} in the AIOS Dev Pod.
Read your role definition at agents/dev-pod/{role}.md and follow it exactly.
Read the pod manifest at memory/pod-manifest.md — your assigned sub-task is: {sub-task name}

Project root: /home/roking/Desktop/Projects/aios

## Goal
Complete your assigned sub-task as defined in the manifest.
Write your result to .tmp/conductor-result-{N}.md when done.

## Worktree
First, create and switch to your worktree:
```bash
git worktree add ../{worktree-name} -b {worktree-branch}
cd ../{worktree-name}
```

## Instructions
- Work only within the files listed in your sub-task scope
- Follow your role definition exactly
- Write .tmp/conductor-result-{N}.md before exiting
```

Then invoke `/conductor` with these pre-written task files (do not re-ask the user for tasks — pass the files directly by reading them as the task list).

Spawn each session:
```bash
claude --dangerously-skip-permissions -p "$(cat .tmp/conductor-task-{N}.md)" > .tmp/conductor-log-{N}.txt 2>&1 &
```

Report: "Dispatched {N} agents. Monitoring completion..."

## Phase 5: Monitor and Handoff

Poll every 30 seconds for all result files:
```bash
ls .tmp/conductor-result-*.md 2>/dev/null | wc -l
```

When all results exist, update manifest status to `pending-gate-2`.

Report:
```
## Dev Pod — Agents Complete

All {N} agents finished. Results:
{for each result file: show status line and summary}

Run `/pod-review` to review the diff and approve or reject the merge.
```

## Edge Cases

- **Planner produces > 4 sub-tasks** — "Manifest has {N} sub-tasks. This is complex — consider breaking into two pod runs. Proceed anyway? (yes / split)"
- **Agent session fails** — "Agent {N} failed. Log at `.tmp/conductor-log-{N}.txt`. Fix the issue and re-run `/pod` or continue with passing agents."
- **Tester reports failing tests** — Report clearly in the Phase 5 summary. Do not block — let Gate 2 handle the decision.
- **manifest.md already exists with status in-progress** — Block with: "A pod run is already in progress. Check `.tmp/conductor-log-*.txt` or run `/pod-review`."

---
