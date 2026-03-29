# Skills Map & Navigator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a layered skills reference map, a contextual skill navigator, and an auto-update hook so skills stay current.

**Architecture:** Three files — `skills/skills-map.md` (reference), `skills/skill-navigator.md` (navigator skill), `scripts/update-skills-map.sh` (hook script) — plus a hook entry in `~/.claude/settings.json`. No compiled code, no dependencies.

**Tech Stack:** Markdown, bash, Claude Code hooks (PostToolUse)

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `skills/skills-map.md` | Layered reference — phase, domain, triggers, description per skill |
| Create | `skills/skill-navigator.md` | Navigator skill — contextual silent routing logic |
| Create | `scripts/update-skills-map.sh` | Hook script — detects new skills, appends with TODO tag |
| Modify | `~/.claude/settings.json` | Add PostToolUse hook for skills/*.md changes |

---

### Task 1: Write skills-map.md

**Files:**
- Create: `skills/skills-map.md`

- [ ] **Step 1: Create the file**

Write `skills/skills-map.md` with the following exact content:

```markdown
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
```

- [ ] **Step 2: Verify the file exists and has all 5 phases**

```bash
grep "^## Phase" skills/skills-map.md
```
Expected output:
```
## Phase 1 — Session Start
## Phase 2 — Business Work
## Phase 3 — Dev Work
## Phase 4 — Anytime / Utility
## Phase 5 — Session Close
```

- [ ] **Step 3: Commit**

```bash
git add skills/skills-map.md
git commit -m "feat: add layered skills map with phases, domains, and triggers"
```

---

### Task 2: Write skill-navigator.md

**Files:**
- Create: `skills/skill-navigator.md`

- [ ] **Step 1: Create the file**

Write `skills/skill-navigator.md` with the following exact content:

```markdown
---
name: skill-navigator
description: >
  Contextual silent skill router. Reads skills-map.md and invokes the right skill
  based on what the user is doing — no announcement, no confirmation. Fires automatically
  when a skill match is detected.
---

# Skill Navigator

## Purpose

Route to the right skill silently and contextually. The user never has to name a skill — you detect the situation and invoke it. No announcement. No "I'm using X because Y." Just better behavior.

## How to Use This Skill

When this skill is loaded, read `skills/skills-map.md` in full. Then apply the matching logic below to the current user message before responding.

## Matching Logic

Apply these rules in order. Stop at the first match.

### 1. Keyword Match
Scan the user's message for exact or near-exact phrases from the **Triggers** column in `skills-map.md`. If found, invoke that skill.

### 2. Intent Match
If no keyword match, consider what the user is trying to accomplish. Map that intent to a skill's "What it does" description. If a skill clearly fits the goal, invoke it.

### 3. Phase Awareness
If the session context is dev work (files mentioned, a plan exists, code being discussed), dev skills take priority over business skills when the trigger is ambiguous.

### 4. No Double-Fire
If a skill was already invoked earlier in this session, do not re-invoke it unless the context has clearly shifted to a new task or phase. Use judgment — a new feature request after finishing one is a clear shift; a follow-up question is not.

## Tie-Breaking

If multiple skills could match, prefer the skill that comes **earlier in the dev lifecycle**:
`brainstorming` → `writing-plans` → `test-driven-development` → `executing-plans` → `requesting-code-review` → `finishing-a-development-branch`

## No Match

If no skill matches, proceed normally without invoking any skill.

## Behavior Rules

- **Silent** — never announce which skill you're using or why
- **Non-blocking** — if skill invocation fails, proceed without it
- **Contextual** — one match per message; don't stack multiple skills in one turn
```

- [ ] **Step 2: Verify the file exists**

```bash
grep "^# Skill Navigator" skills/skill-navigator.md
```
Expected: `# Skill Navigator`

- [ ] **Step 3: Commit**

```bash
git add skills/skill-navigator.md
git commit -m "feat: add skill navigator for contextual silent skill routing"
```

---

### Task 3: Write update-skills-map.sh

**Files:**
- Create: `scripts/update-skills-map.sh`

- [ ] **Step 1: Create the scripts directory and script**

```bash
mkdir -p scripts
```

Write `scripts/update-skills-map.sh` with the following exact content:

```bash
#!/usr/bin/env bash
# update-skills-map.sh
# Scans skills/*.md for frontmatter names not yet in skills-map.md.
# Appends any new skills below the TODO marker with a review tag.
# Safe to run multiple times — only adds, never modifies existing entries.

set -euo pipefail

SKILLS_DIR="$(dirname "$0")/../skills"
MAP_FILE="$SKILLS_DIR/skills-map.md"
MARKER="<!-- NEW SKILLS APPENDED BELOW BY update-skills-map.sh — REVIEW PLACEMENT -->"

# Only run if the changed file is inside skills/ and is a .md file
# CLAUDE_TOOL_INPUT is set by Claude Code hooks to the tool's arguments (JSON)
if [ -n "${CLAUDE_TOOL_INPUT:-}" ]; then
  changed_file=$(echo "$CLAUDE_TOOL_INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null || true)
  if [ -n "$changed_file" ]; then
    # Only proceed if the changed file is in skills/ and isn't skills-map.md itself
    case "$changed_file" in
      */skills/*.md)
        [[ "$changed_file" == *"skills-map.md"* ]] && exit 0
        [[ "$changed_file" == *"skill-navigator.md"* ]] && exit 0
        ;;
      *) exit 0 ;;
    esac
  fi
fi

# Ensure marker exists in map
if ! grep -qF "$MARKER" "$MAP_FILE"; then
  echo "" >> "$MAP_FILE"
  echo "$MARKER" >> "$MAP_FILE"
fi

# For each skill file, check if its name is already in the map
for skill_file in "$SKILLS_DIR"/*.md; do
  basename_file=$(basename "$skill_file")
  [[ "$basename_file" == "skills-map.md" ]] && continue
  [[ "$basename_file" == "skill-navigator.md" ]] && continue

  # Extract name from frontmatter
  skill_name=$(awk '/^---/{p++} p==1 && /^name:/{print $2; exit}' "$skill_file" 2>/dev/null || true)
  [ -z "$skill_name" ] && continue

  # Check if already in map (look for the skill name in backticks)
  if grep -qF "\`$skill_name\`" "$MAP_FILE"; then
    continue
  fi

  # Extract description from frontmatter
  skill_desc=$(awk '/^---/{p++} p==1 && /^description:/{$1=""; print substr($0,2); exit}' "$skill_file" 2>/dev/null || echo "No description")
  skill_desc=$(echo "$skill_desc" | tr -d '>' | xargs)

  # Append to map below marker
  echo "| \`$skill_name\` | utility | <!-- TODO: add triggers --> | $skill_desc | <!-- TODO: review placement -->" >> "$MAP_FILE"
  echo "Skill navigator: added '$skill_name' to skills-map.md — review placement and triggers"
done
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x scripts/update-skills-map.sh
```

- [ ] **Step 3: Test it with a dry run**

```bash
bash scripts/update-skills-map.sh
```
Expected: no output (all current skills already in map). No errors.

- [ ] **Step 4: Verify no duplicate entries were added**

```bash
grep "TODO: review placement" skills/skills-map.md
```
Expected: no output (all skills already in the map from Task 1).

- [ ] **Step 5: Commit**

```bash
git add scripts/update-skills-map.sh
git commit -m "feat: add update-skills-map.sh hook script for auto-update"
```

---

### Task 4: Add PostToolUse hook to settings.json

**Files:**
- Modify: `~/.claude/settings.json`

- [ ] **Step 1: Read current settings.json**

```bash
cat ~/.claude/settings.json
```

- [ ] **Step 2: Add the hook**

Add a `hooks` key to `~/.claude/settings.json`. The existing content must be preserved. The final file should look like this (merge with whatever else is already there):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash /home/roking/Desktop/Projects/aios/scripts/update-skills-map.sh"
          }
        ]
      }
    ]
  }
}
```

Use absolute path to the script so it works from any working directory.

- [ ] **Step 3: Verify the hook is valid JSON**

```bash
python3 -m json.tool ~/.claude/settings.json > /dev/null && echo "valid JSON"
```
Expected: `valid JSON`

- [ ] **Step 4: Test the hook fires by touching a skill file**

Create a test skill file:
```bash
cat > /tmp/test-skill-hook.md << 'EOF'
---
name: test-hook-skill
description: Temporary file to test hook firing
---
# Test
EOF
cp /tmp/test-hook-skill.md skills/test-hook-skill.md
```

Then use the Write or Edit tool on any skills/*.md file in Claude Code — the hook should run `update-skills-map.sh` and append `test-hook-skill` to the map.

Check the map:
```bash
grep "test-hook-skill" skills/skills-map.md
```
Expected: a row with `test-hook-skill` and `TODO: review placement`.

- [ ] **Step 5: Remove the test skill and clean up the map**

```bash
rm skills/test-hook-skill.md
```

Then manually remove the `test-hook-skill` row from `skills/skills-map.md` (it will be below the `<!-- NEW SKILLS APPENDED -->` marker).

- [ ] **Step 6: Commit**

```bash
git add ~/.claude/settings.json 2>/dev/null || true
git commit -m "feat: add PostToolUse hook to auto-update skills-map on skill changes"
```

Note: `~/.claude/settings.json` is outside the repo. The commit here covers any repo-level change from this task (cleanup of test file, etc.).

---

### Task 5: Verify end-to-end

- [ ] **Step 1: Confirm all files exist**

```bash
ls skills/skills-map.md skills/skill-navigator.md scripts/update-skills-map.sh
```
Expected: all three paths listed with no errors.

- [ ] **Step 2: Confirm skills-map has all 22 skills**

```bash
grep -c "^\| \`" skills/skills-map.md
```
Expected: `22` (7 AIOS + 15 Superpowers skills, excluding skills-map and skill-navigator themselves).

- [ ] **Step 3: Confirm skill-navigator references skills-map**

```bash
grep "skills-map.md" skills/skill-navigator.md
```
Expected: `read \`skills/skills-map.md\`` or similar.

- [ ] **Step 4: Final commit**

```bash
git add skills/skills-map.md skills/skill-navigator.md scripts/update-skills-map.sh
git status
git commit -m "chore: verify skills map and navigator complete" --allow-empty
```
