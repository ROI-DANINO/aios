# AIOS Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Initialize the AIOS workspace with folder structure, system handbook, skills, context placeholders, and git — ready for the first `/business-setup` run.

**Architecture:** A Claude Code CLI workspace with a `claude.md` system handbook, skills as markdown files, and context files that persist business identity across sessions. No code, no dependencies — pure file structure and configuration.

**Tech Stack:** Claude Code CLI, markdown files, git, bash

---

### Task 1: Initialize Git Repository

**Files:**
- Create: `aios/.git/` (via git init)

- [ ] **Step 1: Initialize git**

Run: `git init /home/roking/Desktop/Projects/aios`
Expected output: `Initialized empty Git repository in /home/roking/Desktop/Projects/aios/.git/`

- [ ] **Step 2: Verify**

Run: `git -C /home/roking/Desktop/Projects/aios status`
Expected output: `On branch master` (or `main`) with `No commits yet`

---

### Task 2: Create Folder Structure

**Files:**
- Create: `context/`, `skills/`, `deliverables/`, `data/`, `memory/`, `docs/superpowers/specs/`, `docs/superpowers/plans/`, `.tmp/`

- [ ] **Step 1: Create all directories**

Run:
```bash
mkdir -p /home/roking/Desktop/Projects/aios/context
mkdir -p /home/roking/Desktop/Projects/aios/skills
mkdir -p /home/roking/Desktop/Projects/aios/deliverables
mkdir -p /home/roking/Desktop/Projects/aios/data
mkdir -p /home/roking/Desktop/Projects/aios/memory
mkdir -p /home/roking/Desktop/Projects/aios/docs/superpowers/specs
mkdir -p /home/roking/Desktop/Projects/aios/docs/superpowers/plans
mkdir -p /home/roking/Desktop/Projects/aios/.tmp
```

- [ ] **Step 2: Verify structure**

Run: `find /home/roking/Desktop/Projects/aios -type d | sort`
Expected: All 9 directories listed above appear in output.

---

### Task 3: Create `.gitignore`

**Files:**
- Create: `aios/.gitignore`

- [ ] **Step 1: Write `.gitignore`**

Create `/home/roking/Desktop/Projects/aios/.gitignore` with this exact content:

```
# API keys — never commit
.env

# Scratch space
.tmp/

# Local databases
data/*.db
data/*.sqlite

# OS files
.DS_Store
Thumbs.db
```

- [ ] **Step 2: Verify**

Run: `cat /home/roking/Desktop/Projects/aios/.gitignore`
Expected: The file contents print cleanly.

---

### Task 4: Create `.env` with Placeholder Keys

**Files:**
- Create: `aios/.env`

- [ ] **Step 1: Write `.env`**

Create `/home/roking/Desktop/Projects/aios/.env` with this exact content:

```
# API Keys — fill in what you have, leave blank what you don't
# Skills will tell you when they need a key you haven't set

# Required for research tasks
PERPLEXITY_API_KEY=

# Required for web scraping / lead research
FIRECRAWL_API_KEY=

# Required for Telegram mobile access
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=

# Optional — for image/thumbnail generation
GEMINI_API_KEY=

# Anthropic (Claude) — usually handled by Claude Code directly
ANTHROPIC_API_KEY=
```

- [ ] **Step 2: Verify `.env` is gitignored**

Run: `git -C /home/roking/Desktop/Projects/aios check-ignore -v .env`
Expected output: `.gitignore:2:.env    .env`

---

### Task 5: Write `claude.md` System Handbook

**Files:**
- Create: `aios/claude.md`

- [ ] **Step 1: Write `claude.md`**

Create `/home/roking/Desktop/Projects/aios/claude.md` with this exact content:

```markdown
# AIOS — System Handbook

## Identity

You are my AI Operating System co-pilot. I am a hobbyist coder going pro.

**My job:** Creativity, direction, decisions.
**Your job:** Discipline, structure, execution, filling my blind spots.

Keep me on professional rails while I stay in creative flow.

## Directives

1. Go step-by-step. Never rush.
2. Explain what you're doing and why as we go — I am learning.
3. Check in with me at the end of every stage before moving to the next one.
4. Never write large amounts of code or make big structural changes without my approval first.
5. If you're unsure what I want, ask. One question at a time.

## Workflow Rules

Always follow the Superpowers development workflow in this order:
1. **Brainstorm** (`superpowers:brainstorming`) — before any feature or change
2. **Plan** (`superpowers:writing-plans`) — before any implementation
3. **TDD** (`superpowers:test-driven-development`) — red → green → refactor
4. **Code Review** (`superpowers:requesting-code-review`) — before finishing
5. **Finish** (`superpowers:finishing-a-development-branch`) — clean close

Never skip steps. Never jump straight to code.

## Context Files

At the start of every session, read these files to understand who I am and what I'm building:

- `context/my-business.md` — what I'm building, my stage, my current challenge
- `context/my-voice.md` — how I communicate, my tone, what to avoid
- `context/my-goals.md` — my 90-day priorities and long-term vision

If any of these files are empty, suggest running `/business-setup` to fill them.

## Available Skills

| Command | What it does |
|---|---|
| `/business-setup` | Onboarding wizard — fills all context files in one conversation |
| `/pod-mapper` | Maps any business function into automatable workflow steps |
| `/system-architect` | Walks through architecture decisions and produces a brief |

## Security Rules

**Hard rules — no exceptions:**
- Never send a message, email, or notification on my behalf without explicit approval
- Never delete files or data without explicit approval
- Never write to an external system (CRM, database, API) without explicit approval
- Always confirm before any action that cannot be undone

When in doubt, ask. The cost of asking is zero. The cost of a mistake can be high.

## Pod Structure

**Pod 1 (current):** Operations + Second Brain
- Daily planning and reviews
- Decision logging and knowledge capture
- Dev project tracking

**Next phase:** Paperclip web UI — install after context files are filled and Pod 1 is running.
```

- [ ] **Step 2: Verify**

Run: `wc -l /home/roking/Desktop/Projects/aios/claude.md`
Expected: 60+ lines

---

### Task 6: Install Skills

**Files:**
- Create: `aios/skills/business-setup.md`
- Create: `aios/skills/pod-mapper.md`
- Create: `aios/skills/system-architect.md`

- [ ] **Step 1: Copy downloaded skills into `skills/`**

Run:
```bash
cp /home/roking/Desktop/Projects/aios/aios2-20260328T213631Z-1-001/aios2/business-setup-skill.md \
   /home/roking/Desktop/Projects/aios/skills/business-setup.md

cp /home/roking/Desktop/Projects/aios/aios2-20260328T213631Z-1-001/aios2/pod-mapper-skill.md \
   /home/roking/Desktop/Projects/aios/skills/pod-mapper.md

cp /home/roking/Desktop/Projects/aios/aios2-20260328T213631Z-1-001/aios2/system-architect-template.md \
   /home/roking/Desktop/Projects/aios/skills/system-architect.md
```

- [ ] **Step 2: Verify all three are in place**

Run: `ls /home/roking/Desktop/Projects/aios/skills/`
Expected: `business-setup.md  pod-mapper.md  system-architect.md`

---

### Task 7: Create Context Placeholder Files

**Files:**
- Create: `aios/context/my-business.md`
- Create: `aios/context/my-voice.md`
- Create: `aios/context/my-goals.md`

- [ ] **Step 1: Create `my-business.md` placeholder**

Create `/home/roking/Desktop/Projects/aios/context/my-business.md` with:

```markdown
# My Business

> This file is empty. Run `/business-setup` to fill it.
```

- [ ] **Step 2: Create `my-voice.md` placeholder**

Create `/home/roking/Desktop/Projects/aios/context/my-voice.md` with:

```markdown
# My Voice

> This file is empty. Run `/business-setup` to fill it.
```

- [ ] **Step 3: Create `my-goals.md` placeholder**

Create `/home/roking/Desktop/Projects/aios/context/my-goals.md` with:

```markdown
# My Goals

> This file is empty. Run `/business-setup` to fill it.
```

- [ ] **Step 4: Verify all three exist**

Run: `ls /home/roking/Desktop/Projects/aios/context/`
Expected: `my-business.md  my-goals.md  my-voice.md`

---

### Task 8: Create `memory/MEMORY.md`

**Files:**
- Create: `aios/memory/MEMORY.md`

- [ ] **Step 1: Create MEMORY.md**

Create `/home/roking/Desktop/Projects/aios/memory/MEMORY.md` with:

```markdown
# Memory Index

This file is the index for the AIOS memory system.
Individual memory files live in this directory.
Each entry below is a pointer to a memory file.

## Index

<!-- Memory entries will be added here as the system learns about you -->
```

- [ ] **Step 2: Verify**

Run: `cat /home/roking/Desktop/Projects/aios/memory/MEMORY.md`
Expected: The file prints cleanly.

---

### Task 9: First Git Commit

**Files:**
- Modify: git staging area

- [ ] **Step 1: Stage all files**

Run:
```bash
git -C /home/roking/Desktop/Projects/aios add \
  claude.md \
  .gitignore \
  skills/ \
  context/ \
  memory/ \
  deliverables/ \
  data/ \
  docs/
```

- [ ] **Step 2: Verify staging (check .env is NOT staged)**

Run: `git -C /home/roking/Desktop/Projects/aios status`
Expected: `.env` does NOT appear in staged files. All other files appear as `new file`.

- [ ] **Step 3: Commit**

Run:
```bash
git -C /home/roking/Desktop/Projects/aios commit -m "init: AIOS foundation — structure, handbook, skills, context placeholders"
```
Expected: Commit confirmation with file count.

- [ ] **Step 4: Verify commit**

Run: `git -C /home/roking/Desktop/Projects/aios log --oneline`
Expected: One commit line with the message above.

---

### Task 10: Verify Complete Setup

- [ ] **Step 1: Check full file tree**

Run: `find /home/roking/Desktop/Projects/aios -not -path '*/.git/*' | sort`

Expected output includes:
```
aios/claude.md
aios/.env
aios/.gitignore
aios/context/my-business.md
aios/context/my-voice.md
aios/context/my-goals.md
aios/skills/business-setup.md
aios/skills/pod-mapper.md
aios/skills/system-architect.md
aios/memory/MEMORY.md
aios/deliverables/
aios/data/
aios/.tmp/
aios/docs/superpowers/specs/2026-03-29-aios-foundation-design.md
aios/docs/superpowers/plans/2026-03-29-aios-foundation.md
```

- [ ] **Step 2: Foundation complete**

If all files are present: the AIOS foundation is ready.

**Next step:** Open a new Claude Code session in `/home/roking/Desktop/Projects/aios` and run `/business-setup` to fill your context files.
