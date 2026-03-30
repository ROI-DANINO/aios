---
name: dev-audit
description: >
  Use when you want to know where you are in a development phase, whether a phase is
  done, what's broken, or what to work on next. Triggers on: "where am I", "is this
  done", "audit my project", "what's left", "phase status", "what should I work on".
  Reads PLAN.md, runs tests, checks git log — produces a structured status report.
user-invocable: true
argument-hint: "[path/to/project] — defaults to current working directory"
tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# Dev Audit

No questions. Read the project. Tell the truth.

## When to Trigger

- "Where am I in the project?"
- "Is this phase done?"
- "What should I work on next?"
- "Audit my code / project / phase"
- "What's left?"
- Any time before starting a coding session

## Process

### Phase 1: Locate Project

- If argument provided → use it as project root
- Default → current working directory
- Read `PLAN.md`, `INIT.md`, `CLAUDE.md` silently — no output yet

### Phase 2: Gather Hard Data

Run all of the following. Do not ask — just execute.

**Test count (try in order, use first that works):**
```bash
# Option A: live run (requires Docker running)
docker compose -f {project_root}/../docker-compose.yml exec -T backend pytest --tb=no -q 2>/dev/null | tail -3

# Option B: count test functions without running
grep -r "def test_" {project_root}/backend/tests/ --include="*.py" -l | xargs grep -c "def test_" | awk -F: '{sum += $2} END {print sum " test functions found (not run)"}'
```

**Recent git commits:**
```bash
git -C {project_root} log --oneline -10
```

**Parse PLAN.md for:**
- Current phase (look for `**Phase:**` line)
- Done items (`- [x]` lines)
- Not-done items (`- [ ]` lines)
- Open questions section
- Last updated date

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

### Phase 3: Produce the Report

Output exactly this structure:

```
## Phase Audit — {project name}
**Date:** {today}
**Current Phase:** {from PLAN.md}
**Last Updated:** {from PLAN.md}

### Health
- Tests: {N passing / N total} — {passing | failing | unknown}
- Last commit: "{message}" ({date})
- Phase checklist: {X done / N total items}

### Done ✓
{bullet list of [x] items from PLAN.md — current phase only}

### Not Done ✗
{bullet list of [ ] items — these are the actual gap}

### Open Questions
{list from PLAN.md open questions / decisions log — flag any that are blocking}

### Verdict
{one sentence: "Phase X is complete." OR "Phase X is {X}% done. {N} items blocking."}

### Next Move
{single most important next action — specific, not vague}
```

### Phase 4: Route

After the report, give one routing instruction:

| Situation | Route |
|-----------|-------|
| Phase complete, no blockers | "Phase done. Run `/pod-mapper` to map your next workflow, or `/dev-audit {next_project}` to audit another project." |
| Phase complete, no `ux-decisions.md` found | "No UX decisions recorded for this project. Run `/ux-scan` to find features that may be missing intent before moving forward." |
| Data collection in progress | "You need {N} more rated runs. Open the dashboard at `localhost:5173` and run 10 images today." |
| Tests failing | "Run `/systematic-debugging` — start with the failing module: {module name}." |
| Open questions blocking code | "Answer these before writing more code: {list}. Use `/superpowers:brainstorming` if stuck." |
| Feature work available | "Next task: {specific item from Not Done list}. Start with `/superpowers:writing-plans`." |

## Edge Cases

- **Docker not running** — Skip live test run. Use grep fallback. Note: "Test count estimated (Docker not running)."
- **No PLAN.md** — Report: "No PLAN.md found. Cannot audit phase status. Create one or point me to the right file."
- **PLAN.md has no checkboxes** — Summarise what's described as complete vs in-progress in prose.
- **Multiple phases in PLAN.md** — Report only on the current active phase (the one marked as in-progress). Mention other phases exist but don't expand them.
- **Project argument is wrong path** — Report the error clearly: "No PLAN.md at {path}. Did you mean {closest match}?"

## Next Step

When audit is complete and phase is healthy: run `/qa` (gstack) to check coverage and flag untested paths, then `/cso` for security review, then `/ship` to release.

If UX intent is missing: run `/ux-scan` before continuing.

## See Also

- `/qa` (gstack) — test coverage check, runs after audit
- `/cso` (gstack) — security review
- `/ship` (gstack) — release
- `/ux-scan` — UX audit, feeds back into dev-audit
- `/retro` — end-of-sprint retrospective
