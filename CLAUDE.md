# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

AIOS is Roi's personal AI Operating System — a file-driven co-pilot system with no compiled code, no build system, and no test runner. It's 100% markdown-based. The "code" is skills, context, and memory files.

## System Handbook

`CLAUDE.md` is the primary operating handbook. Read it before any session that involves system-level changes. Key directives:

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

### Creating New AIOS Skills

After writing a new skill in `skills/`, it must be installed as a plugin so it works via the Skill tool (slash commands). Steps:

1. Create `~/.claude/aios-plugins/plugins/<skill-name>/.claude-plugin/plugin.json` with name + description
2. Create `~/.claude/aios-plugins/plugins/<skill-name>/skills/<skill-name>/SKILL.md` (copy from `skills/<skill-name>.md`)
3. Add entry to `~/.claude/aios-plugins/.claude-plugin/marketplace.json` plugins array: `{ "name": "<skill-name>", "description": "...", "category": "productivity", "source": "./plugins/<skill-name>" }`
4. Run: `claude plugin install <skill-name>@aios`
5. Restart Claude Code for the new skill to appear in session

**Keeping in sync:** When `skills/<skill-name>.md` is updated, copy the file to the plugin path (step 2) so they stay in sync.

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

## Runtime Tools

AIOS has Bun and Playwright (Chromium) installed system-wide. Skills that use the browser or parallel sessions call these directly — no setup needed per session.

- **Bun:** `~/.bun/bin/bun` — JS runtime for Playwright scripts
- **Playwright/Chromium:** `~/.cache/ms-playwright/` — real browser for `/browse`
- **Claude Code CLI headless mode:** used by `/conductor` to spawn parallel sessions

## Agent Teams

Claude Code Agent Teams is enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`). The Dev Pod (`/pod`) now uses the Scheduler agent to coordinate Coder/Tester/Reviewer teammates with dependency-aware dispatch. The main session receives push updates — no polling, no silent waiting.

Enable a teammate manually: open a new Claude Code session alongside your main session.

## gstack Skills Index

Additional skills grafted from gstack (available as slash commands):

**Planning reviews (run before brainstorming):**
- `/plan-ceo-review` — CEO/founder mode: rethink the problem, find the 10-star product
- `/plan-eng-review` — Engineering architecture review and lock-down
- `/plan-design-review` — Design system review before implementation
- `/autoplan` — Chains CEO → Design → Eng reviews with confirmation prompts

**Design work:**
- `/design-consultation` — Competitor research, design proposals, realistic mockups
- `/design-review` — Design system audit and iteration feedback
- `/design-shotgun` — Collaborative design brainstorming with variations

**Dev lifecycle (run after `finishing-a-development-branch`):**
- `/review` — Intelligent multi-mode review: tracks what's been reviewed, does the right thing
- `/investigate` — Auto-freezes to module, safety restrictions on
- `/qa` — QA pass: runs tests, flags untested paths and edge cases
- `/qa-only` — QA check without automatic fixes
- `/cso` — Security review: OWASP scan, secrets check, permission audit
- `/ship` — Release: version bump, changelog, git tag, push
- `/setup-deploy` — Detects platform, production URL, deploy commands — one-time setup
- `/land-and-deploy` — Merge PR + monitor production after code review passes
- `/canary` — Monitor production for 30 minutes post-deploy
- `/document-release` — Generate release documentation
- `/retro` — Sprint retrospective: what shipped, what didn't, next focus

**Safety:**
- `/careful` — Warns before rm -rf, DROP TABLE, force-push, git reset --hard
- `/freeze [dir]` — Lock edits to a single directory
- `/guard` — Combines careful + freeze (maximum safety)
- `/unfreeze` — Release directory lock

**Browser and utilities:**
- `/office-hours` — Unstructured problem-solving, no fixed format
- `/browse [URL] [task]` — Real Chromium browser automation via Playwright
- `/conductor` — Spawn parallel Claude Code sessions for independent tasks
- `/setup-browser-cookies` — Import cookies from Chrome/Arc/Brave/Edge for authenticated pages
- `/connect-chrome` — Browser integration setup (Chrome sidebar)
- `/codex` — Three OpenAI Codex review modes: code review, adversarial, open consultation
- `/benchmark` — Performance benchmarking and analysis
- `/gstack-upgrade` — Update gstack to latest version
- `/git-audit [owner/repo]` — Interactive git + GitHub audit: repo setup, stale branches, commit quality, PR/issue/CI triage. Use `/git-audit report` to save a structured health report to `data/`.
- `/skill-scan [skill-name]` — Full skill audit: finds missing registrations, chain gaps, duplicates. Saves tiered report to `data/` + feeds backlog. Optional interactive triage per finding.
