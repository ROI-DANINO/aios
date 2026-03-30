---
name: conductor
description: >
  Parallel Claude Code sessions for independent workstreams. Lists tasks, confirms
  the split, spawns headless Claude Code sub-sessions, and tracks completion. Use
  when user says "run these in parallel", "spin up agents", "conductor", or
  "multiple workstreams".
user-invocable: true
argument-hint: "[optional: comma-separated task list]"
---

# Conductor

Split the work. Run it in parallel. Collect the results.

## When to Trigger

- "run these in parallel"
- "spin up agents"
- "conductor"
- "multiple workstreams"
- Any time 2+ tasks are clearly independent and could be worked simultaneously

## Pre-Flight

1. Verify Claude Code CLI is available: `claude --version`
2. Verify tasks are genuinely independent — no task's output is another task's input

If tasks have dependencies, route to `superpowers:dispatching-parallel-agents` instead.

## Process

### Phase 1: Define the tasks

If argument provided, parse the comma-separated list.
If no argument, ask: "What are the independent tasks you want to run in parallel?"

List them back to the user:
```
Parallel tasks:
1. {task 1}
2. {task 2}
3. {task 3 if any}

These will each run in a separate Claude Code session simultaneously. Confirm?
```

**HARD RULE: Never spawn sessions without explicit confirmation.**

### Phase 2: Prepare task prompts

For each task, write a self-contained prompt file to `.tmp/conductor-task-{N}.md`:

```markdown
# Task {N}: {task name}

## Context
{Relevant project context — file paths, what already exists, what this task should produce}

## Goal
{Specific, concrete output expected}

## Instructions
- Work only on this task
- Do not modify files outside the scope listed
- Commit your changes when done
- Write a completion summary to `.tmp/conductor-result-{N}.md`
```

### Phase 3: Spawn sessions

For each task, spawn a background Claude Code session:

```bash
claude --dangerously-skip-permissions -p "$(cat .tmp/conductor-task-{N}.md)" > .tmp/conductor-log-{N}.txt 2>&1 &
```

Report: "Spawned {N} sessions. Monitoring..."

### Phase 4: Track completion

Poll every 30 seconds:
```bash
ls .tmp/conductor-result-*.md 2>/dev/null | wc -l
```

When all result files exist, report:

```
## Conductor Results

### Task 1: {name}
{contents of .tmp/conductor-result-1.md}

### Task 2: {name}
{contents of .tmp/conductor-result-2.md}

### Summary
{N}/{N} tasks completed. Review results above and resolve any conflicts before committing.
```

## Edge Cases

- **Tasks have a dependency** — Refuse to run them in parallel: "Task 2 depends on Task 1's output. Run them sequentially instead."
- **One session fails** — Report partial results. Don't suppress failures: "Task 2 failed. Log at `.tmp/conductor-log-2.txt`."
- **More than 5 tasks** — Warn: "Running {N} parallel sessions is resource-intensive. Consider batching. Proceed?"
- **claude CLI not found** — "Claude Code CLI not found. Install it at claude.ai/code."

## See Also

- `pod` — calls conductor as part of the multi-agent chain (Dev Pod entry point)
- `superpowers:dispatching-parallel-agents` — alternative when tasks have dependencies; prefer this over conductor when tasks are not fully independent
- `pod-review` — Gate 2 after conductor finishes in the pod chain
