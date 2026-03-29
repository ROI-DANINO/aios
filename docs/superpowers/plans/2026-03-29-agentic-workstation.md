# Agentic Workstation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade AIOS into a multi-agent Dev Pod — describe a feature once, conductor decomposes it, agents execute in isolated worktrees, you approve at two gates, PR opens automatically.

**Architecture:** A `/pod` skill wraps the existing `/conductor` engine, adds a Planner agent that decomposes tasks into a manifest, routes Coder/Tester agents into git worktrees, and closes with a `/pod-review` Gate 2 approval flow. Two MCP servers (memory + sequential-thinking) provide shared state and structured reasoning.

**Tech Stack:** Markdown skills, Claude Code CLI headless mode (`claude --dangerously-skip-permissions`), git worktrees, MCP servers via npx (`@modelcontextprotocol/server-memory`, `@modelcontextprotocol/server-sequential-thinking`), existing github plugin MCP.

---

## File Map

| File | Action | Purpose |
|---|---|---|
| `~/.claude/settings.json` | Modify | Add memory + sequential-thinking MCP server entries |
| `agents/dev-pod/planner.md` | Create | Planner agent role definition |
| `agents/dev-pod/coder.md` | Create | Coder agent role definition |
| `agents/dev-pod/tester.md` | Create | Tester agent role definition |
| `agents/dev-pod/reviewer.md` | Create | Reviewer agent role definition |
| `skills/pod.md` | Create | Entry point skill — Gate 1 + conductor dispatch |
| `skills/pod-review.md` | Create | Gate 2 — diff review, approval, PR |
| `skills/dev-audit.md` | Modify | Append Pod Mode status section |
| `skills/skills-map.md` | Modify | Add Phase 3b Dev Pod section |

---

## Task 1: Install MCP Servers

**Files:**
- Modify: `~/.claude/settings.json` (mcpServers section)

- [ ] **Step 1: Verify npx is available**

```bash
npx --version
```
Expected: a version number (e.g. `10.x.x`). If missing, install Node.js first.

- [ ] **Step 2: Test memory MCP server can start**

```bash
npx -y @modelcontextprotocol/server-memory --help 2>&1 | head -5
```
Expected: help output or silent success (no "not found" error).

- [ ] **Step 3: Test sequential-thinking MCP server can start**

```bash
npx -y @modelcontextprotocol/server-sequential-thinking --help 2>&1 | head -5
```
Expected: help output or silent success.

- [ ] **Step 4: Add both MCP servers to settings.json**

Read `~/.claude/settings.json`. Replace the `"mcpServers": {}` entry with:

```json
"mcpServers": {
  "memory": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-memory"]
  },
  "sequential-thinking": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
  }
}
```

- [ ] **Step 5: Verify settings.json is valid JSON**

```bash
python3 -c "import json; json.load(open('/home/roking/.claude/settings.json')); print('valid')"
```
Expected: `valid`

- [ ] **Step 6: Commit**

```bash
git -C /home/roking/Desktop/Projects/aios add -A
git -C /home/roking/Desktop/Projects/aios commit -m "feat: add memory and sequential-thinking MCP servers"
```

---

## Task 2: Create Agent Role Definitions

**Files:**
- Create: `agents/dev-pod/planner.md`
- Create: `agents/dev-pod/coder.md`
- Create: `agents/dev-pod/tester.md`
- Create: `agents/dev-pod/reviewer.md`

- [ ] **Step 1: Create agents/dev-pod/ directory and planner.md**

Create `agents/dev-pod/planner.md`:

```markdown
---
role: planner
pod: dev-pod
description: Decomposes a task into a structured manifest for the Dev Pod. Runs first in the pod lifecycle before any code is written.
---

# Planner Agent

You are the Planner in the Dev Pod. Your only job is to read the task and write a structured manifest to `memory/pod-manifest.md`.

## Input

You will receive a task description like:
> "Add image resizing to Captionate — support width/height params, maintain aspect ratio, return resized URL"

## Process

1. Use sequential-thinking to reason through:
   - What is the core change? (which files, which layer)
   - What sub-tasks are genuinely independent?
   - What must be done sequentially vs. in parallel?
   - What are the acceptance criteria?

2. Write the manifest to `memory/pod-manifest.md` using this exact format:

```markdown
# Pod Manifest
**Task:** {one-line task name}
**Created:** {YYYY-MM-DD}
**Status:** pending-gate-1

## Sub-Tasks

### Sub-Task 1: {name}
- **Agent:** Coder
- **Worktree:** feature/{task-slug}-{subtask-slug}
- **Scope:** {which files, what change}
- **Acceptance criteria:** {specific, testable}

### Sub-Task 2: {name}
- **Agent:** Tester
- **Worktree:** test/{task-slug}
- **Scope:** {which test files, what coverage}
- **Acceptance criteria:** {N tests pass, covers X behavior}

## Dependencies
{list any ordering constraints between sub-tasks, or "none"}

## Out of Scope
{explicitly list what this task does NOT include}
```

3. Output: "Manifest written to memory/pod-manifest.md. Ready for Gate 1."

## Rules
- Never write code. Your output is the manifest only.
- Never skip the sequential-thinking step — it's how you catch false assumptions.
- If the task is too vague to decompose, ask one clarifying question before proceeding.
- Maximum 4 sub-tasks per manifest. If more are needed, flag it for decomposition.
```

- [ ] **Step 2: Create coder.md**

Create `agents/dev-pod/coder.md`:

```markdown
---
role: coder
pod: dev-pod
description: Implements code changes in an isolated git worktree. Follows Superpowers TDD cycle. Reads manifest for scope, writes result file when done.
---

# Coder Agent

You are the Coder in the Dev Pod. You implement one sub-task from the manifest in an isolated worktree.

## Input

You will receive:
- Path to `memory/pod-manifest.md`
- Your assigned sub-task name (e.g. "Sub-Task 1: Add resize endpoint")

## Process

1. Read `memory/pod-manifest.md`. Find your assigned sub-task.
2. Confirm you are in the correct worktree (name matches `feature/{task-slug}-{subtask-slug}`).
3. Read the files listed in your sub-task scope. Understand what exists before changing anything.
4. Follow the Superpowers TDD cycle:
   - Write failing tests first
   - Implement minimal code to pass
   - Refactor if needed
   - Commit
5. Write your result to `.tmp/conductor-result-{N}.md`:

```markdown
# Coder Result: {sub-task name}
**Status:** complete | failed
**Worktree:** {worktree name}
**Files changed:**
- {file path} — {what changed}

**Summary:** {1-2 sentences of what was implemented}

**Tests written:** {N} new tests
**All tests passing:** yes | no — {failure detail if no}
```

## Rules
- Work only within the files listed in your sub-task scope. Do not touch other files.
- Never merge or push. Your job ends at the commit.
- If you hit a blocker (missing dependency, ambiguous requirement), write status: failed and explain clearly in the result file.
- Commit message format: `feat: {sub-task name in lowercase}`
```

- [ ] **Step 3: Create tester.md**

Create `agents/dev-pod/tester.md`:

```markdown
---
role: tester
pod: dev-pod
description: Runs the full test suite against completed Coder worktrees and writes a structured result. Does not write new tests — validates what Coder wrote.
---

# Tester Agent

You are the Tester in the Dev Pod. You run the test suite and report what passed, failed, and why.

## Input

You will receive:
- The worktree path to test (e.g. `feature/image-resizing-endpoint`)
- Path to `memory/pod-manifest.md` for acceptance criteria

## Process

1. Navigate to the worktree. Read the acceptance criteria for the relevant sub-task.
2. Run the project test suite. Try these in order, use the first that works:

```bash
# Python projects
cd {worktree_path} && pytest --tb=short -q 2>&1

# Node/Bun projects
cd {worktree_path} && bun test 2>&1

# Fallback: count test functions
grep -r "def test_\|it(\|test(" {worktree_path} --include="*.py" --include="*.ts" --include="*.js" -l
```

3. Write result to `.tmp/conductor-result-tester-{N}.md`:

```markdown
# Tester Result: {worktree name}
**Status:** passing | failing | unknown
**Tests run:** {N}
**Tests passed:** {N}
**Tests failed:** {N}

## Failures (if any)
{test name}: {failure message}

## Acceptance Criteria Check
- {criterion 1}: met | not met
- {criterion 2}: met | not met

## Verdict
{one sentence: "All acceptance criteria met." OR "Blocking failures: {list}"}
```

## Rules
- Do not modify any code. Read and run only.
- If Docker is required and not running, note it and use grep fallback for test count.
- If tests cannot run at all, write status: unknown and explain why.
```

- [ ] **Step 4: Create reviewer.md**

Create `agents/dev-pod/reviewer.md`:

```markdown
---
role: reviewer
pod: dev-pod
description: Reviews the completed diff for code quality and security issues, then opens a GitHub PR. Runs at Gate 2 after user approval.
---

# Reviewer Agent

You are the Reviewer in the Dev Pod. You run after Gate 2 approval.

## Input

You will receive:
- Worktree name(s) that are approved for merge
- Target branch (default: `main`)
- Task name from `memory/pod-manifest.md`

## Process

1. For each approved worktree, generate the diff against main:

```bash
git diff main...{worktree-branch} --stat
git diff main...{worktree-branch}
```

2. Review the diff for:
   - **OWASP Top 10**: injection, XSS, insecure deserialization, hardcoded secrets
   - **Code quality**: obvious logic errors, missing error handling at system boundaries
   - **Scope creep**: changes outside the manifest sub-task scope

3. If critical issues found: write findings to `.tmp/reviewer-findings.md` and stop. Do not open PR.

4. If no critical issues: open a PR using the github MCP tool:
   - Title: `feat: {task name from manifest}`
   - Body: include sub-task summary, files changed, test results from Tester result file
   - Base branch: `main`
   - Head branch: the worktree branch

5. Write result to `.tmp/conductor-result-reviewer.md`:

```markdown
# Reviewer Result
**Status:** pr-opened | blocked
**PR URL:** {url or "n/a"}
**Issues found:** {none | list}
**Action:** {PR opened at {url} | Blocked — see .tmp/reviewer-findings.md}
```

## Rules
- Never merge the PR. Open it only. Merging is Roi's decision.
- If multiple worktrees are approved, open one PR that includes all branches, or one PR per worktree — use judgment based on whether the changes are cohesive.
- Do not open a PR if Tester result shows failing tests.
```

- [ ] **Step 5: Verify all 4 files exist with correct frontmatter**

```bash
for f in planner coder tester reviewer; do
  echo "=== $f ===" && head -5 /home/roking/Desktop/Projects/aios/agents/dev-pod/$f.md
done
```
Expected: each file shows `---`, `role:`, `pod: dev-pod` in first 5 lines.

- [ ] **Step 6: Commit**

```bash
git -C /home/roking/Desktop/Projects/aios add agents/
git -C /home/roking/Desktop/Projects/aios commit -m "feat: add dev-pod agent role definitions (planner, coder, tester, reviewer)"
```

---

## Task 3: Create /pod Skill

**Files:**
- Create: `skills/pod.md`

- [ ] **Step 1: Create skills/pod.md**

Create `skills/pod.md`:

```markdown
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
```

- [ ] **Step 2: Verify skill frontmatter is valid**

```bash
head -10 /home/roking/Desktop/Projects/aios/skills/pod.md
```
Expected: `---`, `name: pod`, `description:`, `user-invocable: true` all present.

- [ ] **Step 3: Commit**

```bash
git -C /home/roking/Desktop/Projects/aios add skills/pod.md
git -C /home/roking/Desktop/Projects/aios commit -m "feat: add /pod skill — Dev Pod entry point with Gate 1 approval"
```

---

## Task 4: Create /pod-review Skill

**Files:**
- Create: `skills/pod-review.md`

- [ ] **Step 1: Create skills/pod-review.md**

Create `skills/pod-review.md`:

```markdown
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
```

- [ ] **Step 2: Verify skill frontmatter**

```bash
head -10 /home/roking/Desktop/Projects/aios/skills/pod-review.md
```
Expected: `---`, `name: pod-review`, `description:`, `user-invocable: true` all present.

- [ ] **Step 3: Commit**

```bash
git -C /home/roking/Desktop/Projects/aios add skills/pod-review.md
git -C /home/roking/Desktop/Projects/aios commit -m "feat: add /pod-review skill — Gate 2 diff review and PR dispatch"
```

---

## Task 5: Extend dev-audit with Pod Mode

**Files:**
- Modify: `skills/dev-audit.md`

- [ ] **Step 1: Read the current end of dev-audit.md**

Read `skills/dev-audit.md` to find the Phase 4: Route section (the last section).

- [ ] **Step 2: Add Pod Mode section before Phase 4: Route**

Find the line `## Edge Cases` in `skills/dev-audit.md`. Insert the following block immediately before it:

```markdown
### Phase 3b: Pod Mode (if active)

Run this check before outputting the Phase 3 report:
```bash
cat memory/pod-manifest.md 2>/dev/null | grep -E "^\*\*Task:\*\*|\*\*Status:\*\*"
```

If `memory/pod-manifest.md` exists, append this section to the audit report:

```
### Pod Status
- **Task:** {task name from manifest}
- **Status:** {status value from manifest}
- **Agents:** {count .tmp/conductor-result-*.md files} result files found
- **Next action:**
  - pending-gate-1 → "Run `/pod` to review and approve the task split."
  - in-progress → "Agents are running. Check `.tmp/conductor-log-*.txt` for progress."
  - pending-gate-2 → "Agents complete. Run `/pod-review` to review the diff."
  - approved → "PR is open. Review and merge on GitHub."
```

If `memory/pod-manifest.md` does not exist, skip this section entirely.

```

- [ ] **Step 3: Verify the edit landed correctly**

```bash
grep -n "Pod Mode\|Pod Status\|pod-manifest" /home/roking/Desktop/Projects/aios/skills/dev-audit.md
```
Expected: at least 3 matches showing the new section is present.

- [ ] **Step 4: Commit**

```bash
git -C /home/roking/Desktop/Projects/aios add skills/dev-audit.md
git -C /home/roking/Desktop/Projects/aios commit -m "feat: extend dev-audit with Pod Mode status section"
```

---

## Task 6: Update skills-map with Phase 3b

**Files:**
- Modify: `skills/skills-map.md`

- [ ] **Step 1: Locate the insertion point**

```bash
grep -n "Phase 4\|Phase 3b\|Anytime" /home/roking/Desktop/Projects/aios/skills/skills-map.md
```
Expected: a line number for `## Phase 4 — Anytime / Utility`. The new section goes immediately before it.

- [ ] **Step 2: Insert Phase 3b section**

Find the line `## Phase 4 — Anytime / Utility` in `skills/skills-map.md`. Insert the following block immediately before it:

```markdown
## Phase 3b — Dev Pod (Multi-Agent)

| Skill | Domain | Triggers | What it does |
|-------|--------|----------|--------------|
| `pod` | dev | pod, spin up a dev team, multi-agent, dispatch this feature, run the dev pod | Entry point — Planner decomposes task, Gate 1 approval, Conductor dispatches agents |
| `pod-review` | dev | review pod results, approve this, pod diff, merge pod work | Gate 2 — diff review, approve or reject, Reviewer agent opens PR |

```

- [ ] **Step 3: Verify placement**

```bash
grep -n "Phase 3b\|Phase 4\|pod" /home/roking/Desktop/Projects/aios/skills/skills-map.md
```
Expected: Phase 3b appears before Phase 4, both `pod` and `pod-review` rows are present.

- [ ] **Step 4: Commit**

```bash
git -C /home/roking/Desktop/Projects/aios add skills/skills-map.md
git -C /home/roking/Desktop/Projects/aios commit -m "feat: add Phase 3b Dev Pod section to skills-map"
```

---

## Task 7: Smoke Test the Full System

No test runner exists in this repo. Verification is structural + invocation-level.

- [ ] **Step 1: Verify all new files exist**

```bash
for f in \
  skills/pod.md \
  skills/pod-review.md \
  agents/dev-pod/planner.md \
  agents/dev-pod/coder.md \
  agents/dev-pod/tester.md \
  agents/dev-pod/reviewer.md; do
  echo -n "$f: " && test -f /home/roking/Desktop/Projects/aios/$f && echo "OK" || echo "MISSING"
done
```
Expected: all 6 lines say `OK`.

- [ ] **Step 2: Verify all skill frontmatter fields**

```bash
for skill in pod pod-review; do
  echo "=== $skill ==="
  grep -E "^name:|^user-invocable:|^description:" /home/roking/Desktop/Projects/aios/skills/$skill.md
done
```
Expected: `name:`, `description:`, `user-invocable: true` present in both.

- [ ] **Step 3: Verify agent role files have required sections**

```bash
for agent in planner coder tester reviewer; do
  echo "=== $agent ==="
  grep -c "## Input\|## Process\|## Rules" /home/roking/Desktop/Projects/aios/agents/dev-pod/$agent.md
done
```
Expected: each agent shows `3` (all three sections present).

- [ ] **Step 4: Verify MCP config is valid and contains both servers**

```bash
python3 -c "
import json
d = json.load(open('/home/roking/.claude/settings.json'))
servers = d.get('mcpServers', {})
assert 'memory' in servers, 'memory MCP missing'
assert 'sequential-thinking' in servers, 'sequential-thinking MCP missing'
print('MCP config OK:', list(servers.keys()))
"
```
Expected: `MCP config OK: ['memory', 'sequential-thinking']`

- [ ] **Step 5: Verify dev-audit has pod section**

```bash
grep -c "Pod Mode\|Pod Status\|pod-manifest" /home/roking/Desktop/Projects/aios/skills/dev-audit.md
```
Expected: `3` or more.

- [ ] **Step 6: Verify skills-map has Phase 3b**

```bash
grep -c "Phase 3b\|pod-review" /home/roking/Desktop/Projects/aios/skills/skills-map.md
```
Expected: `2` or more.

- [ ] **Step 7: Verify no existing skills were broken**

```bash
for skill in conductor browse dev-audit skill-navigator; do
  echo -n "$skill.md: " && head -3 /home/roking/Desktop/Projects/aios/skills/$skill.md | grep -q "^name:" && echo "OK" || echo "BROKEN"
done
```
Expected: all 4 say `OK`.

- [ ] **Step 8: Final commit**

```bash
git -C /home/roking/Desktop/Projects/aios log --oneline -7
```
Expected: shows all commits from this plan: MCP setup, agent definitions, /pod, /pod-review, dev-audit extension, skills-map update.

---

## Success Criteria Checklist

- [ ] `/pod "add X"` produces a manifest at `memory/pod-manifest.md`, presents Gate 1, waits for approval
- [ ] After Gate 1 approval, conductor spawns one headless session per sub-task
- [ ] Each agent session writes `.tmp/conductor-result-N.md` on completion
- [ ] `/pod-review` reads all result files and shows a diff summary
- [ ] Gate 2 approval spawns Reviewer agent which opens a PR via github MCP
- [ ] Gate 2 abandonment deletes worktrees and clears manifest — no changes to main
- [ ] `dev-audit` shows Pod Status section when `memory/pod-manifest.md` exists
- [ ] `skills-map.md` Phase 3b lists both `pod` and `pod-review`
- [ ] All 6 existing skills verified intact after implementation
