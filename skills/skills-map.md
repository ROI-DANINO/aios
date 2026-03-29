---
name: skills-map
description: Layered reference of all AIOS and Superpowers skills — organized by workflow phase, domain, and trigger phrases. Used by skill-navigator and as a personal cheat sheet.
type: reference
---

# Skills Map

> Organized by workflow phase. Each skill shows its domain, trigger phrases, and what it does.
> **Domains:** `business` · `dev` · `system` · `utility`

---

## Phase 1 — Session Start

| Skill | Domain | Triggers | What it does |
|-------|--------|----------|--------------|
| `using-superpowers` | system | session start, new conversation, first message | Loads skill rules and routing behavior |
| `daily-brief` | business | start of day, what should I work on, morning, orient me, what's on my plate | Reads goals, surfaces yesterday's notes, proposes focused agenda |
| `init` | system | /init, set up this project, tidy this project, onboard this project, initialize, help me organize, starting fresh on this project, starting a new project, help me set up this project | Scans project dir, interviews user, proposes tidy structure, moves files with approval, registers in AIOS memory |

---

## Phase 2 — Business Work

| Skill | Domain | Triggers | What it does |
|-------|--------|----------|--------------|
| `business-setup` | business | set up my business, onboard, configure AIOS, I'm new, reconfigure | Full onboarding wizard — captures identity, voice, ICP, GTM, tools, goals |
| `offer-engine` | business | build my offer, what should I sell, define my offer, audit my offer, ICP missing | Build or audit a business offer from scratch |
| `pod-mapper` | business | map my workflows, audit this department, break down acquisition/delivery/support/ops | Map a business function into automatable workflows |
| `system-architect` | system | design my system, architecture, how should I structure AIOS | Architecture design walkthrough for AIOS itself |

---

## Phase 2b — Design Work

| Skill | Domain | Triggers | What it does |
|-------|--------|----------|--------------|
| `design-consultation` | dev | design this, competitor research, design system, mockups, DESIGN.md | Competitor research, design proposals, realistic mockups |
| `design-review` | dev | review the design, design audit, design feedback | Design system audit and iteration feedback |
| `design-shotgun` | dev | brainstorm designs, design variations, explore design directions | Collaborative design brainstorming with variations |

---

## Phase 3 — Dev Work

> Run these in order for any feature or fix.

| Skill | Domain | Triggers | What it does |
|-------|--------|----------|--------------|
| `plan-ceo-review` | dev | think bigger, expand scope, strategy review, rethink this, is this ambitious enough | CEO/founder mode — rethink the problem, find the 10-star product |
| `plan-eng-review` | dev | architecture review, lock down the plan, eng review, is this technically sound | Engineering architecture review and lock-down |
| `plan-design-review` | dev | design review, is this well designed, UX review | Design system review before implementation |
| `autoplan` | dev | chain all reviews, full review, autoplan, run all planning | Chains CEO → Design → Eng reviews with confirmation prompts |
| `brainstorming` | dev | build X, add feature, let's make, I want to create, new component, new functionality | Explore intent and design before any implementation |
| `writing-plans` | dev | write a plan, implementation plan, plan this out, I have a spec | Write a structured implementation plan from a spec |
| `test-driven-development` | dev | write tests, TDD, test first, before I code | Write tests before implementation code |
| `executing-plans` | dev | execute this plan, run the plan, implement the plan, let's build it | Execute a written plan with checkpoints |
| `subagent-driven-development` | dev | use subagents, parallel tasks, dispatch agents, run tasks in parallel | Parallel implementation via independent subagents |
| `dispatching-parallel-agents` | dev | these tasks are independent, split this work, run these in parallel | Split 2+ independent tasks across agents |
| `requesting-code-review` | dev | review my code, I'm done, ready for review, code review | Request review after completing a feature |
| `receiving-code-review` | dev | I got feedback, review came back, handle this review | Handle review feedback with technical rigor |
| `review` | dev | review my code, smart review, multi-mode review | Intelligent multi-mode review — tracks what's been reviewed, does the right thing |
| `investigate` | dev | investigate this module, look into this, drill down, freeze and investigate | Auto-freezes to module, safety restrictions on |
| `finishing-a-development-branch` | dev | I'm done implementing, done with this feature, merge this, finish the branch, wrap up, all done here | Merge, PR, or cleanup after implementation |
| `using-git-worktrees` | dev | isolate this work, start feature work, new worktree, keep this separate | Create isolated git worktrees for feature work |
| `careful` | dev | be careful, safety mode, prod mode, destructive command | Warns before rm -rf, DROP TABLE, force-push, git reset --hard |
| `freeze [dir]` | dev | freeze this dir, lock edits to, restrict to | Lock edits to a single directory |
| `guard` | dev | guard mode, careful and freeze, maximum safety | Combines careful + freeze |
| `unfreeze` | dev | unfreeze, release freeze, unlock | Release directory lock |
| `qa`        | dev     | qa this, test coverage, edge cases, before I ship          | QA pass — tests, untested paths, regressions        |
| `qa-only`   | dev     | qa without fixes, check only, qa read only                 | QA check without automatic fixes                    |
| `cso`       | dev     | security check, is this safe to ship, cso                 | Security review — OWASP, secrets, permissions        |
| `ship`      | dev     | ship this, release, deploy, tag this, ready to ship, time to release, let's release | Release — version bump, changelog, git tag           |
| `setup-deploy` | dev  | configure deploy, set up deployment, one-time deploy setup | Detects platform, production URL, deploy commands — one-time setup |
| `land-and-deploy` | dev | land this, merge and deploy, deploy after review       | Merge PR + monitor production after code review passes |
| `canary`    | dev     | watch production, canary deploy, monitor after deploy, post-deploy monitor | Monitor production for 30 minutes post-deploy |
| `document-release` | dev | document this release, release notes, generate release docs | Generate release documentation |
| `retro`     | dev     | retro, retrospective, end of sprint, what did we learn     | Sprint retro — shipped, missed, next focus           |

---

## Phase 3b — Dev Pod (Multi-Agent)

| Skill | Domain | Triggers | What it does |
|-------|--------|----------|--------------|
| `pod` | dev | pod, spin up a dev team, multi-agent, dispatch this feature, run the dev pod | Entry point — Planner decomposes task, Gate 1 approval, Scheduler dispatches agents via Agent Teams with dep-aware ordering |
| `pod-review` | dev | review pod results, approve this, pod diff, merge pod work | Gate 2 — diff review, approve or reject, Reviewer agent opens PR |

---

## Phase 4 — Anytime / Utility

| Skill | Domain | Triggers | What it does |
|-------|--------|----------|--------------|
| `note` | utility | note this, remember this, capture this, jot down | Quick mid-session capture to notes.md |
| `dev-audit` | dev | where am I, what's left, what phase am I in, phase status, what should I work on | Audit current dev phase — progress, blockers, next steps |
| `systematic-debugging` | dev | bug, error, this is broken, something's broken, something's wrong, something isn't working, not working, failing, unexpected behavior | Diagnose bugs before proposing fixes |
| `verification-before-completion` | dev | is this done yet, let me verify, check before I commit, make sure this works, verify this works | Verify before claiming done — evidence first |
| `writing-skills` | system | create a skill, new skill, update this skill, improve this skill | Create or improve skills — always update skills-map after |
| `office-hours` | dev  | I'm stuck, think this through, office hours, help me reason | Unstructured problem-solving session               |
| `browse`       | dev  | browse, open URL, scrape, automate this page, go to URL    | Real Chromium automation via Playwright              |
| `conductor`    | dev  | run in parallel, spin up agents, conductor, multiple workstreams | Parallel Claude Code sessions for independent tasks |
| `setup-browser-cookies` | dev | import cookies, browser auth, set up cookies, authenticate browser | Import cookies from Chrome/Arc/Brave/Edge for authenticated pages |
| `connect-chrome` | dev | connect chrome, chrome sidebar, browser integration | Browser integration setup (Chrome sidebar) |
| `codex`        | dev  | codex review, adversarial review, ask codex, second opinion | Three OpenAI Codex review modes: code review, adversarial, open consultation |
| `benchmark`    | dev  | benchmark this, performance test, measure speed            | Performance benchmarking and analysis                |
| `gstack-upgrade` | system | update gstack, upgrade skills, latest gstack           | Update gstack to latest version                      |

---

## Phase 5 — Session Close

| Skill | Domain | Triggers | What it does |
|-------|--------|----------|--------------|
| `session-close` | business | wrap up, end session, I'm done for today, close out, session summary, closing my laptop, done for now, signing off, logging off, heading out | End-of-session log, open threads, next session setup |

---

<!-- NEW SKILLS APPENDED BELOW BY update-skills-map.sh — REVIEW PLACEMENT -->
