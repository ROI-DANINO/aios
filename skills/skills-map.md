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

---

## Phase 2 — Business Work

| Skill | Domain | Triggers | What it does |
|-------|--------|----------|--------------|
| `business-setup` | business | set up my business, onboard, configure AIOS, I'm new, reconfigure | Full onboarding wizard — captures identity, voice, ICP, GTM, tools, goals |
| `offer-engine` | business | build my offer, what should I sell, define my offer, audit my offer, ICP missing | Build or audit a business offer from scratch |
| `pod-mapper` | business | map my workflows, audit this department, break down acquisition/delivery/support/ops | Map a business function into automatable workflows |
| `system-architect` | system | design my system, architecture, how should I structure AIOS | Architecture design walkthrough for AIOS itself |

---

## Phase 3 — Dev Work

> Run these in order for any feature or fix.

| Skill | Domain | Triggers | What it does |
|-------|--------|----------|--------------|
| `brainstorming` | dev | build X, add feature, let's make, I want to create, new component, new functionality | Explore intent and design before any implementation |
| `writing-plans` | dev | write a plan, implementation plan, plan this out, I have a spec | Write a structured implementation plan from a spec |
| `test-driven-development` | dev | write tests, TDD, test first, before I code | Write tests before implementation code |
| `executing-plans` | dev | execute this plan, run the plan, implement the plan, let's build it | Execute a written plan with checkpoints |
| `subagent-driven-development` | dev | use subagents, parallel tasks, dispatch agents, run tasks in parallel | Parallel implementation via independent subagents |
| `dispatching-parallel-agents` | dev | these tasks are independent, split this work, run these in parallel | Split 2+ independent tasks across agents |
| `requesting-code-review` | dev | review my code, I'm done, ready for review, code review | Request review after completing a feature |
| `receiving-code-review` | dev | I got feedback, review came back, handle this review | Handle review feedback with technical rigor |
| `finishing-a-development-branch` | dev | I'm done implementing, merge this, finish the branch, wrap up | Merge, PR, or cleanup after implementation |
| `using-git-worktrees` | dev | isolate this work, start feature work, new worktree, keep this separate | Create isolated git worktrees for feature work |

---

## Phase 4 — Anytime / Utility

| Skill | Domain | Triggers | What it does |
|-------|--------|----------|--------------|
| `note` | utility | note this, remember this, capture this, jot down | Quick mid-session capture to notes.md |
| `dev-audit` | dev | where am I, what's left, is this done, phase status, what should I work on | Audit current dev phase — progress, blockers, next steps |
| `systematic-debugging` | dev | bug, error, this is broken, something's wrong, failing, unexpected behavior | Diagnose bugs before proposing fixes |
| `verification-before-completion` | dev | is this done, let me verify, check before I commit, make sure this works | Verify before claiming done — evidence first |
| `writing-skills` | system | create a skill, new skill, update this skill, improve this skill | Create or improve skills — always update skills-map after |

---

## Phase 5 — Session Close

| Skill | Domain | Triggers | What it does |
|-------|--------|----------|--------------|
| `session-close` | business | wrap up, end session, I'm done for today, close out, session summary | End-of-session log, open threads, next session setup |

---

<!-- NEW SKILLS APPENDED BELOW BY update-skills-map.sh — REVIEW PLACEMENT -->
