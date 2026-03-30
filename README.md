# AIOS — AI Operating System

Roi's personal AI co-pilot layer. A file-driven system with no compiled code, no build system, no test runner — 100% markdown.

## What It Is

AIOS is a skill + context + memory framework that runs inside Claude Code. It turns Claude into a persistent, opinionated work partner that knows your goals, follows your workflows, and improves over sessions.

## Structure

```
context/        # Business identity — voice, goals, ICP, GTM
skills/         # Markdown SOPs, invoked as slash commands
memory/         # Cross-session memory index + per-topic files
deliverables/   # Reports, pod maps, plans
data/           # Logs and structured data
docs/           # Design specs and implementation plans
```

## Key Skills

| Skill | Purpose |
|---|---|
| `/daily-brief` | Session-start orientation |
| `/pod-mapper` | Map a business function into automatable workflows |
| `/system-architect` | Architecture design walkthrough |
| `/session-close` | End-of-session wrap-up + memory extraction |
| `/dev-audit` | Development phase and pod status check |
| `/conductor` | Spawn parallel Claude Code sessions |
| `/git-audit` | Interactive git + GitHub repo health audit |

Full skill index in `skills/skills-map.md`.

## Dev Workflow

All development follows the Superpowers pattern:

1. **Brainstorm** → 2. **Write plan** → 3. **TDD** → 4. **Code review** → 5. **Finish branch**

## Runtime

- **Bun** — JS runtime for Playwright scripts
- **Playwright/Chromium** — browser automation
- **Claude Code Agent Teams** — parallel session coordination
