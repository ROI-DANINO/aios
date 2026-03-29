# AIOS Agentic Workstation — Design Spec
**Date:** 2026-03-29
**Status:** Approved

---

## Overview

Upgrade AIOS from a skill-dispatch system into a true multi-agent workstation. A Dev Pod of specialized agents (Planner, Coder, Tester, Reviewer) orchestrated by an enhanced Conductor, with two human approval gates and worktree-per-agent isolation. Business Pod is Phase 2 — designed in, not built yet.

**North star:** Describe a feature once. Conductor breaks it down, you approve the split, agents execute headless, you review the diff, it merges. All local, all file-native, all auditable.

---

## What Exists (Reused As-Is)

| Asset | Role in this system |
|---|---|
| `skills/conductor.md` | Execution engine — `/pod` wraps it |
| `superpowers:using-git-worktrees` | Worktree isolation per agent session |
| `superpowers:dispatching-parallel-agents` | Parallel dispatch logic |
| `superpowers:subagent-driven-development` | In-session parallel task execution |
| Full Superpowers dev lifecycle | Runs inside each agent session |
| `skills/dev-audit.md` | Extended with Pod Mode status |
| `skills/skill-navigator.md` | Auto-routes pod triggers — no changes needed |
| `skills/skills-map.md` | Updated with Phase 3b section |
| `memory/` directory | Shared agent state store |
| github MCP | Already installed — Reviewer agent uses it |

---

## What Gets Built (New)

### 1. `skills/pod.md`
Entry point skill. Accepts a task description, runs the Planner agent, writes a task manifest to `memory/pod-manifest.md`, presents the split for Gate 1 approval, then invokes `/conductor` with role-specific prompts.

**Triggers:** "pod", "spin up a dev team", "multi-agent this", "dispatch this feature", "run the dev pod"

### 2. `skills/pod-review.md`
Gate 2 skill. Loads diff from completed worktrees, presents summary, accepts approval, invokes Reviewer agent to open PR via github MCP, then runs `superpowers:finishing-a-development-branch`.

**Triggers:** "review pod results", "approve this", "pod diff", "merge pod work"

### 3. `agents/dev-pod/` — Role Definitions

Four markdown files, each a self-contained agent spec:

| File | Role | Tools Granted |
|---|---|---|
| `planner.md` | Decompose task into manifest | Read, Write, memory MCP, sequential-thinking MCP |
| `coder.md` | Implement in isolated worktree | Read, Edit, Write, Bash, git |
| `tester.md` | Run tests, flag failures, write result | Bash, Read |
| `reviewer.md` | Code review, security scan, open PR | Read, Grep, github MCP |

Each file defines: role description, tool access, input format (from manifest), output format (to `.tmp/conductor-result-N.md`), and failure behavior.

### 4. MCP Configuration Additions

Two new MCP servers added to `.claude/settings.json` (or equivalent config):

- **`memory` MCP** (`@modelcontextprotocol/server-memory`) — persistent key-value store for pod manifests and cross-session agent state
- **`sequential-thinking` MCP** (`@modelcontextprotocol/server-sequential-thinking`) — structured reasoning for Planner agent task decomposition

### 5. `dev-audit.md` — Pod Mode Extension

One new section appended to the existing audit output when `memory/pod-manifest.md` exists:

```
### Pod Status
- Active manifest: {task name}
- Agents: {which are running / completed}
- Gate: {waiting for Gate 1 / Gate 2 / none}
- Next action: {approve split | review diff | pod is idle}
```

### 6. `skills-map.md` — Phase 3b Addition

New table section between Phase 3 and Phase 4:

```markdown
## Phase 3b — Dev Pod (Multi-Agent)

| Skill | Domain | Triggers | What it does |
|---|---|---|---|
| `pod` | dev | pod, spin up a dev team, multi-agent, dispatch this feature | Entry point — Planner decomposes, Conductor dispatches, Gate 1 approval |
| `pod-review` | dev | review pod results, approve this, pod diff, merge pod work | Gate 2 — diff review, approval, PR via Reviewer agent |
```

---

## Task Flow

```
You: /pod "add image resizing to Captionate"
        │
        ▼
  pod.md loads
  Planner agent (sequential-thinking MCP) decomposes task
  Writes memory/pod-manifest.md
  Presents task split to user
        │
        ▼ ← GATE 1: You approve the task split
        │
  /conductor spawns headless sessions:
    - Coder session → worktree: feature/{task-slug}
      (superpowers TDD cycle runs inside)
    - Tester session → worktree: test/{task-slug}
  Both write to .tmp/conductor-result-*.md
        │
        ▼
  /pod-review loads diffs, presents summary
        │
        ▼ ← GATE 2: You approve the merge
        │
  Reviewer agent opens PR via github MCP
  superpowers:finishing-a-development-branch runs
```

---

## Approval Gates

**Gate 1 — Task Split Approval**
- Shown: task name, sub-tasks list, agent assignments, estimated worktrees
- Options: Approve / Revise (edit manifest) / Cancel
- Hard rule: conductor never spawns without explicit approval

**Gate 2 — Diff Approval**
- Shown: file change summary, test results from Tester agent, Reviewer agent findings
- Options: Approve merge / Request changes (re-queue Coder) / Abandon
- Hard rule: nothing merges without explicit approval

---

## Agent Isolation

Each Coder and Tester session runs in its own git worktree (via `superpowers:using-git-worktrees`). Worktrees are named `{role}/{task-slug}`. On Gate 2 approval, worktree is merged and cleaned up. On abandonment, worktree is deleted with no changes to main branch.

---

## Business Pod — Phase 2

Same architecture, different role set:

| Agent | Role |
|---|---|
| Researcher | Web search, competitive analysis, market data |
| Writer | Content drafts, emails, proposals |
| Analyst | Data summaries, goal tracking, metrics |
| Scheduler | Calendar, reminders, follow-ups |

Business Pod is invoked via `/biz-pod`. Conductor routes based on task type detection. Phase 2 only — not built in this spec.

---

## Files Created / Modified Summary

**New files:**
- `skills/pod.md`
- `skills/pod-review.md`
- `agents/dev-pod/planner.md`
- `agents/dev-pod/coder.md`
- `agents/dev-pod/tester.md`
- `agents/dev-pod/reviewer.md`

**Modified files:**
- `skills/dev-audit.md` — Pod Mode section appended
- `skills/skills-map.md` — Phase 3b section added
- `.claude/settings.json` (or MCP config) — memory + sequential-thinking MCPs added

**Unchanged:** `/conductor`, all Superpowers skills, `skill-navigator`, github MCP, `memory/` directory structure.

---

## Success Criteria

- `/pod "add X"` produces a task manifest, shows it, waits for approval
- After approval, spawns isolated worktrees via conductor
- Both agent sessions write result files when complete
- `/pod-review` shows the diff summary and test results
- After Gate 2 approval, PR is opened via github MCP
- `dev-audit` shows pod status when a manifest is active
- No existing skills are broken or duplicated
