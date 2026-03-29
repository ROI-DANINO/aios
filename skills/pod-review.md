---
name: pod-review
description: >
  Gate 2 of the Dev Pod. Loads completed agent results and diffs, presents a review
  summary, accepts approval, then runs the Reviewer agent to open a PR. Use when user
  says "review pod results", "approve this", "pod diff", "merge pod work", or after
  /pod reports "Run /pod-review".
user-invocable: true
---

# Pod Review

Gate 2. You see the diff. You decide.

## When to Trigger

- "review pod results"
- "pod diff"
- "approve this" (when pod context is active)
- "merge pod work"
- After `/pod` reports all agents complete

## Pre-Flight

Check manifest exists and is at the right gate:
```bash
cat memory/pod-manifest.md 2>/dev/null | grep "^**Status:**"
```
If status is not `pending-gate-2`: "No completed pod run found. Run `/pod [task]` first."

## Phase 1: Load Results

Read all result files:
```bash
cat .tmp/conductor-result-*.md 2>/dev/null
```

For each Coder worktree, generate the diff summary:
```bash
git diff main...{worktree-branch} --stat
```

## Phase 2: Present Gate 2 Summary

```
## Dev Pod — Gate 2: Review

**Task:** {task name from manifest}

### Agent Results
{for each agent result file:}
**{role} — {sub-task name}:** {status}
- Files changed: {list}
- Summary: {summary from result file}
- Tests: {N passing / N failing}

### Diff Summary
{git diff --stat output for each worktree}

### Reviewer Pre-Check
{list any issues flagged by Reviewer agent if it ran}

─────────────────────────────
Decision:
  approve  — merge worktrees, open PR
  changes  — send back to Coder with notes
  abandon  — discard all worktrees, no changes to main
```

**HARD RULE: Do not merge, open PR, or delete worktrees without explicit decision.**

## Phase 3a: Approve

Update manifest status to `approved`.

Spawn Reviewer agent:
```bash
claude --dangerously-skip-permissions -p "$(cat <<'PROMPT'
You are the Reviewer agent in the AIOS Dev Pod.
Read your role definition at agents/dev-pod/reviewer.md and follow it exactly.

Approved worktrees: {list worktree names}
Target branch: main
Task name: {task name from manifest}
Tester results: .tmp/conductor-result-tester-*.md

Open a PR for the approved work.
PROMPT
)" > .tmp/pod-reviewer-log.txt 2>&1
```

Wait for `.tmp/conductor-result-reviewer.md` to exist (max 60 seconds).

Read the reviewer result and report:
```
## Reviewer Complete
{contents of .tmp/conductor-result-reviewer.md}
```

Then invoke `superpowers:finishing-a-development-branch` for final cleanup.

Clean up:
```bash
# Remove worktrees after PR is opened
git worktree remove ../{worktree-name} --force
# Archive result files
mkdir -p .tmp/pod-archive && mv .tmp/conductor-result-*.md .tmp/pod-archive/
# Clear manifest
rm memory/pod-manifest.md
```

## Phase 3b: Request Changes

Ask: "What changes are needed? (describe for the Coder)"

Write the change notes to `memory/pod-manifest.md` under a new section:
```markdown
## Change Request
**From:** Gate 2 review on {date}
{change notes}
```

Update manifest status to `pending-gate-1`.

Report: "Change request recorded. Re-run `/pod` to dispatch a new Coder session with these notes."

## Phase 3c: Abandon

Confirm: "Abandon this pod run? All worktrees will be deleted. This cannot be undone. (yes / no)"

On yes:
```bash
git worktree remove ../{worktree-name} --force
rm memory/pod-manifest.md
rm .tmp/conductor-result-*.md .tmp/conductor-log-*.txt .tmp/pod-*.txt 2>/dev/null
```

Report: "Pod run abandoned. No changes to main branch."

## Edge Cases

- **Reviewer times out** — "Reviewer agent timed out. Check `.tmp/pod-reviewer-log.txt`. PR was not opened — open it manually or re-run `/pod-review`."
- **Tester shows failures but user approves anyway** — Proceed but add a warning line to the PR body: "⚠️ Approved with failing tests: {list}"
- **Multiple worktrees, partial approval** — Ask: "Approve all worktrees or specific ones? (all / list names)"

## Next Step

After PR is opened: run `superpowers:finishing-a-development-branch` to merge and close the branch.

## See Also

- `/pod` — Gate 1 entry point that dispatched the agents reviewed here
- `superpowers:finishing-a-development-branch` — branch merge and cleanup
