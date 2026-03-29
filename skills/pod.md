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

## Phase 4: Dispatch via Scheduler

Update manifest status to `in-progress`.

Spawn the Scheduler agent as a Claude Code Agent Team lead session:

```bash
claude --dangerously-skip-permissions -p "$(cat <<'PROMPT'
You are the Scheduler agent in the AIOS Dev Pod. Read your role definition at agents/dev-pod/scheduler.md and follow it exactly.

Manifest: memory/pod-manifest.md
Project root: /home/roking/Desktop/Projects/aios
PROMPT
)" > .tmp/pod-scheduler-log.txt 2>&1 &
```

The Scheduler will:
- Read the manifest dependency DAG
- Spawn Coder and Tester agents as Claude Code teammates with correct blockedBy relationships
- Surface decisions to this session as they arise
- Message you when all agents complete

Report: "Scheduler running. Agents will be dispatched with dependency ordering. You'll receive updates as work progresses."

## Phase 5: Receive Updates

Unlike the old polling model, you do NOT need to wait silently. The Scheduler pushes updates to you:

- **Progress messages**: Scheduler messages you when each sub-task completes
- **Decision requests**: Agents surface questions directly to you via Scheduler
- **Completion**: When all agents finish, Scheduler messages: "All agents complete. Run /pod-review."

**While agents run, you can:**
- Continue working on other tasks
- Answer any decision requests that come in
- Check `.tmp/pod-scheduler-log.txt` if you want raw progress

When you receive "All agents complete", run `/pod-review` to proceed to Gate 2.

## Edge Cases

- **Planner produces > 4 sub-tasks** — "Manifest has {N} sub-tasks. This is complex — consider breaking into two pod runs. Proceed anyway? (yes / split)"
- **Agent session fails** — "Agent {N} failed. Log at `.tmp/conductor-log-{N}.txt`. Fix the issue and re-run `/pod` or continue with passing agents."
- **Tester reports failing tests** — Report clearly in the Phase 5 summary. Do not block — let Gate 2 handle the decision.
- **manifest.md already exists with status in-progress** — Block with: "A pod run is already in progress. Check `.tmp/conductor-log-*.txt` or run `/pod-review`."

---

## Next Step

When all agents report complete: run `/pod-review` to review diffs at Gate 2, approve, and open the PR.

## See Also

- `/pod-review` — Gate 2 review and PR creation
- `/pod-mapper` — maps the workflows that feed into pod tasks
- `superpowers:dispatching-parallel-agents` — Agent SDK alternative for parallel work (no headless sessions)
