# AGENTS.md

Cross-agent context file for AIOS — Roi Danino's AI Operating System.
Works in Claude Code, Cursor, Cline, Codex, and any agent that reads AGENTS.md.

## Who You're Working With

**Roi Danino** — Developer, Tel Aviv (UTC+3). Building Captionate v3 (AI image pipeline) and AIOS (personal AI OS, self-use phase). Hobbyist coder going pro. Direct, no-BS communication style. Wants explanations, not just outputs.

## What This Repo Is

AIOS is a file-driven co-pilot system — no compiled code, no build system, no test runner. 100% markdown. The "code" is skills, context files, and memory.

## Architecture

```
context/    # Business identity — voice, goals, ICP, GTM. Ground truth. Don't contradict without explicit instruction.
skills/     # Markdown SOPs invocable as slash commands
memory/     # MEMORY.md index + per-topic files — cross-session continuity
data/       # Session logs, notes, structured data
deliverables/ # Output space for reports, plans, pod maps
.env        # API keys (gitignored — never commit)
```

## How to Orient

1. Read `memory/MEMORY.md` — loads cross-session context about Roi and current projects
2. Read `context/my-goals.md` — 90-day priorities
3. Read `context/my-business.md` — what's being built and why

## Behavioral Rules

- **Step-by-step** — plan before doing, check in before moving to next phase
- **No big changes without approval** — present the plan, get a yes, then execute
- **Security hard rules** — never send messages, delete files, or write to external systems without explicit per-action approval
- **Explain reasoning** — especially on architectural decisions

## Dev Workflow (Captionate v3 and any code project)

Follow the Superpowers pattern in order — never skip steps:
1. Brainstorm (`superpowers:brainstorming`)
2. Write a plan (`superpowers:writing-plans`)
3. TDD (`superpowers:test-driven-development`)
4. Code review (`superpowers:requesting-code-review`)
5. Finish branch (`superpowers:finishing-a-development-branch`)

## Skills (slash commands)

Core AIOS skills in `skills/`:
- `/business-setup` — fill/reconfigure context files
- `/pod-mapper` — map a business function into workflows
- `/system-architect` — architecture design walkthrough
- `/daily-brief` — session-start orientation
- `/session-close` — end-of-session log + memory extraction
- `/dev-audit` — phase status for any project
- `/pod` — multi-agent Dev Pod (Planner → Scheduler → Coder/Tester/Reviewer)

Full skill list: `skills/skills-map.md`

## Memory System

`memory/MEMORY.md` is the index. Always load it. Never write code patterns, file structure, or git history to memory — derive those from the repo.

## Runtime

- **Bun:** `~/.bun/bin/bun`
- **Playwright/Chromium:** `~/.cache/ms-playwright/` (for `/browse`)
- **Claude Code Agent Teams:** enabled — Dev Pod uses Scheduler + 4 role agents
