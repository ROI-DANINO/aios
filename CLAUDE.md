# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

AIOS is Roi's personal AI Operating System — a file-driven co-pilot system with no compiled code, no build system, and no test runner. It's 100% markdown-based. The "code" is skills, context, and memory files.

## System Handbook

`claude.md` is the primary operating handbook. Read it before any session that involves system-level changes. Key directives:

- **Step-by-step only** — plan before doing, check in at each step
- **No big changes without approval** — present the plan, get a yes, then execute
- **Explain your reasoning** — especially for hobbyist-coder-level work
- **Security hard rules** — never send, delete, or write to external systems without explicit approval per action

## Architecture

```
context/        # Business identity (voice, goals, ICP, GTM) — persistent session context
skills/         # Markdown SOPs, invocable via slash commands
memory/         # MEMORY.md index + per-topic files — cross-session continuity
deliverables/   # Output space for reports, pod maps, plans
data/           # Databases, logs, structured data (gitignored: *.db)
docs/superpowers/specs/   # Architecture specs
docs/superpowers/plans/   # Implementation plans
.tmp/           # Scratch space (gitignored)
.env            # API keys (gitignored — never commit)
```

`ai-os-knowledge-base.md` is the dense reference for system concepts, architecture decisions, and key quotes. Read it when onboarding to a new workstream.

## Skills

Skills in `skills/` are invoked as slash commands in Claude Code:

- `/business-setup` — Onboarding wizard for new sessions or reconfiguration
- `/pod-mapper [engine]` — Maps a business function (acquisition/delivery/support/operations) into automatable workflows
- `/system-architect` — Architecture design walkthrough

The Superpowers skill library (brainstorming → plans → TDD → code review → finish branch) governs all dev work. These are installed via the Superpowers GitHub integration and listed in the session-start system reminder.

## Dev Workflow

All development work (e.g., Captionate v3 features) follows the Superpowers pattern enforced by `claude.md`:

1. **Brainstorm** (`superpowers:brainstorming`) before any feature work
2. **Write a plan** (`superpowers:writing-plans`) before touching code
3. **TDD** (`superpowers:test-driven-development`) before writing implementation
4. **Code review** (`superpowers:requesting-code-review`) after implementation
5. **Finish branch** (`superpowers:finishing-a-development-branch`) to integrate

Never skip steps. Never start coding without a plan in place.

## Memory System

Memory lives in `memory/`. `MEMORY.md` is the index — always loaded. Individual memory files hold user, feedback, project, and reference entries. Keep index entries under ~150 chars. Do not put code patterns, file structure, or git history in memory — derive those from the repo.

## Context Files

`context/` holds Roi's business identity. Read relevant files when doing business-adjacent work (offers, GTM, communications). These are ground truth for voice, goals, and positioning — do not contradict them without explicit instruction.
