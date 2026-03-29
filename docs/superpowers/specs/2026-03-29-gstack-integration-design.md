# gstack Integration Design
Date: 2026-03-29

## Overview

Selectively graft 7 skills from Garry Tan's gstack into AIOS as native skills. Fills two gaps: (A) post-code dev lifecycle (QA, security, ship, retro) and (D) runtime capabilities (browser automation, parallel agents). No gstack repo dependency — skills are adapted and owned by AIOS.

**Approach:** Selective Graft (Option A)
**Runtime:** Bun + Playwright installed system-wide, one-time setup

---

## 1. Skills Added

### Dev Lifecycle (slot after `finishing-a-development-branch`)

| Skill file | Trigger phrases | Behavior |
|---|---|---|
| `skills/qa.md` | "qa this", "test coverage", "edge cases", "before I ship" | Reads current branch diff + test files. Runs existing tests. Flags untested paths, edge cases, regressions. Outputs a pass/fail checklist. |
| `skills/cso.md` | "security check", "is this safe to ship", "cso" | OWASP top 10 scan on changed files. Checks for exposed secrets, unsafe inputs, permission issues. Outputs findings with severity (critical/warn/info). |
| `skills/ship.md` | "ship this", "release", "deploy", "tag this" | Bumps version, writes changelog entry from git log, creates git tag, outputs deploy command. Confirms before any destructive step. |
| `skills/retro.md` | "retro", "retrospective", "end of sprint", "what did we learn" | Reads session-log + git log for the sprint. Outputs: what shipped, what didn't, one process improvement, next sprint focus. |
| `skills/office-hours.md` | "I'm stuck", "think this through", "office hours", "help me reason" | Unstructured problem-solving — asks what you're stuck on, reasons through it, no fixed output format. |

### Runtime Skills

| Skill file | Trigger phrases | Behavior |
|---|---|---|
| `skills/browse.md` | "browse", "open this URL", "scrape", "automate this page", "check this visually" | Launches real Chromium via `bunx playwright`. Accepts URL + task description. Returns structured output (text/screenshot path). |
| `skills/conductor.md` | "run these in parallel", "spin up agents", "conductor", "multiple workstreams" | Lists independent tasks, confirms split, spawns parallel Claude Code sessions via headless mode. Tracks completion. |

---

## 2. Workflow Position

```
Superpowers:                     gstack grafts:
brainstorm →
writing-plans →
TDD →
[implementation] →               → /qa
requesting-code-review →         → /cso
finishing-a-development-branch → → /ship
                                 → /retro (end of sprint)

Anytime:
                                 → /browse
                                 → /conductor
                                 → /office-hours
```

---

## 3. AIOS Touch Points

### 3.1 `skills/` — 7 new skill files
Same format as existing AIOS skills (frontmatter + markdown body). No external dependencies in the skill files themselves — runtime calls are encapsulated inside browse.md and conductor.md.

### 3.2 `skills/skills-map.md` — 7 new rows
Dev lifecycle skills added to Phase 3. Runtime + office-hours added to Phase 4. skill-navigator will auto-route to them without any other changes.

**Phase 3 additions:**
```
| `qa`        | dev     | qa this, test coverage, edge cases, before I ship          | QA pass — tests, untested paths, regressions        |
| `cso`       | dev     | security check, is this safe to ship, cso                 | Security review — OWASP, secrets, permissions        |
| `ship`      | dev     | ship this, release, deploy, tag this                       | Release — version bump, changelog, git tag           |
| `retro`     | dev     | retro, retrospective, end of sprint, what did we learn     | Sprint retro — shipped, missed, next focus           |
```

**Phase 4 additions:**
```
| `office-hours` | dev  | I'm stuck, think this through, office hours, help me reason | Unstructured problem-solving session               |
| `browse`       | dev  | browse, open URL, scrape, automate this page               | Real Chromium automation via Playwright              |
| `conductor`    | dev  | run in parallel, spin up agents, conductor                 | Parallel Claude Code sessions for independent tasks  |
```

### 3.3 `CLAUDE.md` — new "Runtime Tools" section
Documents Bun/Playwright availability and lists the 7 new skills in the skills index. No behavior changes to existing directives.

### 3.4 Runtime install (one-time)
```bash
curl -fsSL https://bun.sh/install | bash   # install Bun
bunx playwright install chromium            # install Chromium
```
After this, `bunx playwright` is available system-wide. Skills call it directly — no project-level config needed.

---

## 4. What's Excluded

- `/codex` — Roi uses Claude Code, not OpenAI Codex
- gstack's CEO review, plan-ceo-review, full sprint orchestration — Superpowers already covers planning
- gstack's Chrome Side Panel extension — out of scope for now
- Conductor's full multi-repo parallelism — scoped to single-project parallel workstreams only

---

## 5. Security Rules

All gstack-derived skills inherit AIOS security hard rules:
- `/ship` confirms before any tag, push, or deploy action
- `/browse` never submits forms or clicks destructive actions without explicit user approval per action
- `/conductor` lists all planned sub-sessions and confirms before spawning
- No skill writes to external systems without explicit per-action approval

---

## 6. Success Criteria

- 7 skill files exist in `skills/` and are invocable as slash commands
- `skills-map.md` routes to all 7 via skill-navigator
- `CLAUDE.md` documents the runtime and new skills
- Bun + Playwright installed and `/browse` opens real Chromium
- `/conductor` spawns at least 2 parallel Claude Code sessions on a test task
- Existing Superpowers workflow unchanged
