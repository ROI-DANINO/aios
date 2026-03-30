---
name: init
description: >
  Project onboarding wizard — scan an existing project directory, interview the user about
  what it is and what they're building, propose a tidy coherent file structure, move files
  with approval, and register the project in AIOS memory. Use when user says "/init",
  "set up this project", "tidy this project", "onboard this project", "initialize project",
  "help me organize this", or when starting work on an existing codebase for the first time.
user-invocable: true
argument-hint: "[optional: path to project dir, defaults to cwd]"
tools:
  - Read
  - Write
  - Edit
  - Glob
  - Bash
---

# Project Init

First-time onboarding for any existing project. Scan it, understand it, tidy it, register it.

## Philosophy

Don't reorganize for the sake of it. The goal is coherence — every file should be findable,
every folder should have one clear job, and the project should slot naturally into the AIOS
workflow (plans go in plans/, scratch goes in .tmp/, etc.). When in doubt, ask, don't assume.

## When to Trigger

- User wants to start working on an existing project they haven't touched via AIOS before
- Project directory feels messy or the user doesn't know where things live
- User says "/init", "tidy this project", "organize this codebase", "help me find my way around"
- Any time `docs/superpowers/plans/` doesn't exist inside a dev project

## Process

Run conversationally. One phase at a time. Get approval before touching any files.

---

### Phase 1: Scan

1. Determine the target directory:
   - If an argument was passed (e.g. `/init ~/Projects/my-app`), use that path.
   - Otherwise use the current working directory.

2. Run a directory tree scan (depth 3, skip `.git`, `node_modules`, `.tmp`, build artifacts):
   ```bash
   find . -maxdepth 3 \
     -not -path './.git/*' \
     -not -path './node_modules/*' \
     -not -path './.tmp/*' \
     -not -path './dist/*' \
     -not -path './.next/*' \
     -not -path './build/*' \
     | sort
   ```

3. Show the user the tree. If the project has more than 50 files, summarise by folder rather
   than listing every file.

---

### Phase 2: Interview

If the project has a `README.md`, `package.json`, or `CLAUDE.md`, read it first and pre-fill
what you can. Only ask for what's genuinely missing.

Ask these questions as a single batch:

1. **What does this project do?** (one sentence — what problem does it solve, what does it make)
2. **What's the current state?** (e.g. "brand new", "half-built", "live in production", "abandoned and picking back up")
3. **What are you trying to do right now?** (e.g. "add a feature", "fix a bug", "understand the codebase", "plan a rewrite")
4. **Is there anything obviously out of place?** (files they know are in the wrong location, dead code, etc.)
5. **Any folders or files you want to keep exactly as-is?** (lock these — do not move them)

---

### Phase 3: Propose

Based on the scan and interview, propose a tidy structure. Present as a diff:

```
PROPOSED CHANGES
────────────────────────────────────
CREATE  docs/superpowers/plans/      (AIOS plans live here)
CREATE  .tmp/                        (scratch space, gitignored)
MOVE    notes.txt → data/notes.md    (notes belong in data/)
MOVE    design.fig → assets/design.fig
RENAME  App.js → src/App.jsx         (consistent extension)
IGNORE  src/, package.json, README   (no changes)
────────────────────────────────────
```

Rules for what to propose:
- **Always create** `docs/superpowers/plans/` if it doesn't exist (AIOS plan output)
- **Always create** `.tmp/` if it doesn't exist (add to .gitignore if git project)
- **Never move** files the user locked in Phase 2
- **Never move** source code files (`.ts`, `.tsx`, `.js`, `.jsx`, `.py`, `.go`, etc.) — only configuration, docs, assets, and loose files in the project root
- **Propose renaming** ambiguous filenames in the root (e.g. `stuff.txt`, `old.md`, `test.js`)
- **Propose grouping** if there are 4+ loose files of the same type in root (e.g. 5 `.md` files → suggest `docs/`)
- **If nothing needs moving** — say so. "Structure looks clean — I'll just add the AIOS scaffolding."

Ask: "Does this look right? Any changes before I proceed?"

Do NOT proceed until the user confirms. If they request changes, revise the proposal and re-show.

---

### Phase 4: Execute

Once approved:

1. Create folders that don't exist yet (`mkdir -p`)
2. Move/rename files as proposed (`mv`)
3. If `.tmp/` was created and the project has a `.gitignore`, append `.tmp/` to it
4. Create `docs/superpowers/plans/.gitkeep` if the plans folder is new (keeps it in git)

After executing, show a brief confirmation:
```
Done. Changes applied:
✓ Created docs/superpowers/plans/
✓ Created .tmp/ (added to .gitignore)
✓ Moved notes.txt → data/notes.md
```

---

### Phase 5: Register in Memory

Note: memory/ lives in the AIOS directory (`~/Desktop/Projects/aios/memory/`), not in the
project being initialized. Use the absolute AIOS memory path.

1. Check `memory/MEMORY.md` — does this project already have an entry?
   - If yes: update the existing entry with current state.
   - If no: create a new memory file and add it to the index.

2. Write a project memory file to `memory/project-[slug].md`:

```markdown
---
name: project-[slug]
description: Brief one-liner about this project for MEMORY.md index
type: project
---

**Project:** [name from README or interview]
**Path:** [absolute path to project dir]
**What it does:** [one sentence from interview]
**Current state:** [from interview]
**Stack:** [detected from package.json / go.mod / requirements.txt / etc.]

**Why:** [what the user is trying to accomplish]
**How to apply:** Start sessions in this project with the current state in mind. Plans live in docs/superpowers/plans/.
```

3. Add a line to `memory/MEMORY.md`:
```
- [Project Name](project-[slug].md) — [what it does, current state]
```

---

### Route to Next Action

After registering, tell the user exactly what to do next based on their Phase 2 answers:

**"brand new" or "half-built":**
> "Your project is registered. Ready to plan? Run `/brainstorm` to think through the next
> feature, then `/write-plan` to produce a task list in `docs/superpowers/plans/`."

**"live in production" / "fix a bug":**
> "Registered. If you've got a specific bug, run `/investigate`. For a feature, start with
> `/brainstorm`."

**"understand the codebase":**
> "Registered. I can walk you through the architecture — just ask 'explain the codebase' and
> I'll read the key files and give you a tour."

**"plan a rewrite":**
> "Registered. Start with `/brainstorm` — the rewrite scope usually shifts once you've
> articulated what's broken."

---

## Edge Cases

- **No git repo** — Skip the .gitignore step. Note it: "No git repo detected — you may want to run `git init`."
- **Monorepo (multiple package.json / go.mod)** — Treat each sub-package as a separate zone. Propose changes only at the root level, not inside sub-packages.
- **Already tidy** — "Structure looks clean. I've added the AIOS scaffolding and registered the project." Don't invent work.
- **Huge project (500+ files)** — Don't list files individually. Summarise by top-level folder. Focus interview on root-level loose files and AIOS scaffolding only.
- **Project already has a `docs/` folder** — Create `docs/superpowers/plans/` inside it. Don't flatten the existing `docs/` structure.
- **User says "don't move anything"** — Honour it. Just create AIOS scaffolding and register.
- **Can't determine tech stack** — Ask: "What language/framework is this in?" Don't guess.
- **Project path has spaces** — Always quote paths in bash commands.

## Next Step

After project is registered: run `/system-architect` to design the architecture, or go straight to `/business-setup` if this is a new AIOS context.

## See Also

- `/system-architect` — architecture design, natural follow-on after init
- `/business-setup` — AIOS context setup, alternative next step for new installs
