---
name: aios-health
description: >
  Full AIOS system health audit. Spawns five parallel subagents to audit skill health,
  memory integrity, data hygiene, self-improvement backlog, and token efficiency.
  Saves a report to data/aios-health-YYYY-MM-DD.md, auto-fixes safe issues with
  confirmation, and conditionally invokes context-clean on data bloat.
  Use when user says "/aios-health", "audit my AIOS", "system health check",
  "how healthy is my AIOS", "full AIOS audit", or "something feels off with my system".
user-invocable: true
argument-hint: "[--dry-run | --report-only]"
tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - Agent
---

# AIOS Health

Full system audit. Five parallel subagents. One report. Auto-fixes with confirmation.

## Arguments

- `--dry-run` — run all agents, propose all fixes, write no files
- `--report-only` — run all agents, write report, skip fixes and context-clean

---

## Phase 0 — Pre-flight

1. Detect argument: `--dry-run` or `--report-only` (default: full run)
2. Set `TODAY = YYYY-MM-DD` (current date)
3. Announce: "Starting AIOS health audit — dispatching 5 agents."

---

## Phase 1 — Dispatch 5 Parallel Subagents

Dispatch all five simultaneously via the Agent tool. Each agent is fully self-contained — provide all file paths in the prompt, specify the exact return format, and dispatch in a single message.

### Agent 1: Skill Health

**Reads:** `skills/*.md`, `skills/skills-map.md`, `CLAUDE.md`, `~/.claude/aios-plugins/.claude-plugin/marketplace.json`

**Checks:**
- Each skill file has frontmatter: `name`, `description`, `user-invocable`
- Cross-reference skills in `skills-map.md` against actual `skills/*.md` files:
  - Skill listed in map but no file → **Critical**
  - Skill file exists but not in map → **Critical**
- Skills referenced in CLAUDE.md not present in `skills/` → **Warning**
- Plugin entries in marketplace.json without a corresponding directory at `~/.claude/aios-plugins/plugins/<name>/` → **Critical**
- Known chains — verify each skill has `## Next Step` or `## See Also` pointing to the next skill:
  - Session loop: daily-brief → note → session-close
  - Dev pipeline: dev-audit → qa → cso → ship → retro
  - Project setup: init → system-architect → business-setup
  - Business: business-setup → pod-mapper → pod
  - Multi-agent: pod → pod-review → finishing-a-development-branch
  - UX: ux-gate → ux-scan → dev-audit
  - Health audit: aios-health → (conditional) context-clean

**Return format:**
```
AGENT:skill-health
CRITICAL: [list, or "None"]
WARNING: [list, or "None"]
INFO: [list, or "None"]
SUMMARY: N critical, N warning, N info
```

---

### Agent 2: Memory & Context

**Reads:** `memory/MEMORY.md`, all `memory/*.md`, all `context/*.md`

**Checks:**
- Each pointer in `memory/MEMORY.md` → verify `memory/<filename>` exists; missing = **orphan pointer**
- Each `memory/*.md` file (except MEMORY.md) → verify it appears in MEMORY.md; missing = **orphan file**
- Memory files that appear to hold project-status info with no visible date signal in the last 30 days → **possibly stale**
- `context/` files with no date stamp or last-updated note → **no freshness signal**
- MEMORY.md pointer labels that appear to cover the same topic → **dedup candidates**

**Return format:**
```
AGENT:memory-context
ORPHAN_POINTERS: [list of referenced filenames that are missing, or "None"]
ORPHAN_FILES: [list of memory/*.md not referenced in MEMORY.md, or "None"]
STALE_MEMORY: [list with file names, or "None"]
CONTEXT_FLAGS: [list, or "None"]
DEDUP_CANDIDATES: [list pairs, or "None"]
SUMMARY: N orphan pointers, N orphan files, N stale, N context flags
```

---

### Agent 3: Data Hygiene

**Reads:** list of all files in `data/`, `data/notes.md`, `data/skill-improvement-backlog.md`

**Checks:**

Daily briefs (`data/daily-brief-*.md`):
- Sort by date. Mark 7 most recent as KEEP. All others → ARCHIVE candidates.

Skill-scan reports (`data/skill-scan-*.md`):
- Sort by date. Mark 2 most recent as KEEP. All others → ARCHIVE candidates.

`data/notes.md`:
- Count total non-blank, non-archive lines
- Find all `#next` entries with a date 14+ days before TODAY → STALE
- Count all tag types: `#next`, `#idea`, `#blocker`, `#decision`

`data/skill-improvement-backlog.md`:
- Count open (`- [ ]`) and closed (`- [x]`) items by section

Trigger signals (compute all three):
- `DAILY_BRIEFS_OVER`: total daily-brief count > 7 → true/false
- `SCANS_OVER`: skill-scan report count > 2 → true/false
- `NOTES_BLOAT`: notes.md non-archive lines > 50 → true/false (include count)

**Return format:**
```
AGENT:data-hygiene
ARCHIVE_DAILY_BRIEFS: [list of filenames, or "None"]
ARCHIVE_SKILL_SCANS: [list of filenames, or "None"]
STALE_NEXT_ITEMS: [list with date and text, or "None"]
BACKLOG_STATS: N open items (N cleanup, N wiring, N other)
NOTES_STATS: N total lines, N #next, N #idea, N #blocker
TRIGGER_CONTEXT_CLEAN: DAILY_BRIEFS_OVER=true/false, SCANS_OVER=true/false, NOTES_BLOAT=true/false (N lines)
```

---

### Agent 4: Self-Improvement

**Reads:** `data/skill-improvement-backlog.md`, `data/notes.md`, latest `data/skill-scan-*.md`

**Checks:**
- Open backlog items by section: count, identify oldest (look for date references in text)
- `#idea` entries in notes.md: flag ideas with no corresponding backlog item or session log action
- Latest skill-scan report: compare Critical/Warning findings against open backlog items — items in scan not yet in backlog = **gap**
- Identify patterns: which skills are repeatedly cited, which fix types are never done, which system phases are neglected

**Return format:**
```
AGENT:self-improvement
BACKLOG_SUMMARY: N open, N closed, oldest open: "[text]"
STALE_IDEAS: [list from notes.md, or "None"]
SCAN_TO_BACKLOG_GAPS: [items from latest skill-scan not in backlog, or "None"]
PATTERNS: [2-3 sentence analysis]
RECOMMENDED_NEXT_ACTIONS: [ordered list, max 5]
```

---

### Agent 5: Token & Context Efficiency

**Reads:** all `skills/*.md`, `skills/skills-map.md`, `CLAUDE.md`

**Checks:**
- Count lines in each skill file. Flag >150 lines as **potentially bloated**
- Count `##` headings in each skill. Flag >8 sections as **potentially bloated**
- Identify skills that load 3+ context or memory files in Phase 1 (look for "Read `context/`" or "Read `memory/`" patterns) → **heavy context loader**
- Check `## Next Step` references — does the named skill exist in skills/? Dead ref = **broken chain link**
- Check `skills-map.md` for duplicate skill entries across sections
- Count skill references in `CLAUDE.md` skills index

**Return format:**
```
AGENT:token-efficiency
BLOATED_SKILLS: [list with line counts, or "None"]
HEAVY_CONTEXT_LOADERS: [list, or "None"]
BROKEN_CHAIN_LINKS: [list, or "None"]
DUPLICATE_MAP_ENTRIES: [list, or "None"]
SKILLS_MAP_LINE_COUNT: N
CLAUDE_MD_SKILL_REFS: N
EFFICIENCY_FLAGS: [list of specific recommendations, or "None"]
```

---

## Phase 2 — Merge & Classify

After all five agents return:

1. Parse each `AGENT:*` block
2. Assign global severity:
   - **Critical:** any Critical from skill-health, any orphan pointer, context-clean trigger signals true
   - **Warning:** stale items, bloated skills, orphan files, stale memory, backlog gaps
   - **Info:** efficiency flags, dedup candidates, patterns, closed/already-good signals
3. Write executive summary: one paragraph covering overall health state, most important findings, and whether immediate action is needed

---

## Phase 3 — Auto-Fix Execution

Skip this phase entirely if `--dry-run` or `--report-only` was passed.

### Tier A — Automatic (no confirmation)

Mark stale `#next` items in `data/notes.md`:
- Append `<!-- stale: flagged by aios-health TODAY -->` on the line after each stale `#next` entry
- Never removes lines — only marks
- Log each marking in "Actions Taken"

### Tier B — Single Confirmation Block

Present all proposed fixes in one block before executing anything:

```
AIOS Health — Proposed Fixes

Archive daily-briefs (keep last 7):
  - [list of filenames → ~/.aios-archive/daily-briefs/]
  OR "None to archive."

Archive skill-scan reports (keep last 2):
  - [list of filenames → ~/.aios-archive/skill-scans/]
  OR "None to archive."

Remove MEMORY.md orphan pointers:
  - [list of pointer lines to remove]
  OR "None found."

Remove orphan memory files (no MEMORY.md entry):
  - [list of files]
  OR "None found."

Apply these fixes? [y / n / select]
```

Response handling:
- `y` → execute all (create `~/.aios-archive/` subdirs if missing, then `mv`; edit files for pointer removals)
- `n` → skip all, log to "Actions Skipped" in report
- `select` → user names which items; apply only those
- `--dry-run` → show block with "(dry run — no changes)" label, do nothing

If a `mv` fails (permissions, already moved): note in "Actions Skipped", continue with remaining fixes.

### Tier C — Never Auto-Execute

Surface in report under "Actions Skipped — Requires Manual Review":
- Memory file merges or deletions (dedup candidates)
- `notes.md` compaction (removing lines, not just marking)
- Any changes to `context/` files
- Any changes to `skills/` files

---

## Phase 4 — Context-Clean Trigger

Skip entirely if `--report-only` was passed.

```
If DAILY_BRIEFS_OVER=true OR SCANS_OVER=true:
  → If Tier B archive fixes were applied: invoke context-clean --notes-only
  → If user declined Tier B: invoke context-clean (full run)

If NOTES_BLOAT=true AND DAILY_BRIEFS_OVER=false AND SCANS_OVER=false:
  → invoke context-clean --notes-only

If none triggered:
  → skip; note in report: "context-clean not triggered — data within healthy thresholds"
```

Before invoking, tell the user: "Data bloat detected ([specific trigger]). Invoking /context-clean now..."

context-clean handles its own confirmation flow.

---

## Phase 5 — Write Report

Save to `data/aios-health-TODAY.md`. If today's file already exists, append a `## Re-run — HH:MM` section.

```markdown
# AIOS Health Report — YYYY-MM-DD

## Executive Summary
[One paragraph: overall health state, most critical findings, action taken or pending]

---

## 1. Skill Health
**Summary:** N critical · N warning · N info

### Critical
- [ ] [skill-name] — [finding]

### Warning
- [ ] [skill-name] — [finding]

### Info
- [finding]

---

## 2. Memory & Context
**Orphan pointers (MEMORY.md → missing file):** [list or "None"]
**Orphan files (no MEMORY.md pointer):** [list or "None"]
**Stale memory files:** [list or "None"]
**Context file flags:** [list or "None"]
**Dedup candidates:** [list pairs or "None"]

---

## 3. Data Hygiene
**Daily-briefs:** N total (N kept, N archived)
**Skill-scan reports:** N total (N kept, N archived)
**notes.md:** N non-archive lines — N #next, N #idea, N #blocker

**Stale #next items (14+ days):**
- [date] — "[text]"

**Backlog:** N open (N cleanup, N wiring)

---

## 4. Self-Improvement
**Backlog:** N open, N closed
**Oldest open item:** "[text]"
**Stale ideas:** [list or "None"]
**Scan-to-backlog gaps:** [list or "None"]

**Patterns:**
[2-3 sentence analysis]

---

## 5. Token & Context Efficiency
**Bloated skills (>150 lines):** [list with line counts or "None"]
**Heavy context loaders:** [list or "None"]
**Broken chain links:** [list or "None"]
**Efficiency flags:** [list or "None"]

---

## Actions Taken
- [action]
OR "No actions taken."

---

## Actions Skipped
- [action — reason]
OR "None."

**Requires Manual Review:**
- [Tier C items]

---

## Suggested Improvement Tasks

Derived from all findings above. Formatted as ready-to-act backlog items.
Each task is one action, one outcome, one owner (you). Ordered: Critical first, then Warning, then efficiency.

### Immediate (Critical findings)
- [ ] [task — e.g. "Register missing plugin: `init` not in marketplace.json"] — _source: skill-health_

### This week (Warning findings)
- [ ] [task — e.g. "Add ## Next Step to `ux-scan` pointing to `dev-audit`"] — _source: skill-health_
- [ ] [task — e.g. "Remove orphan memory pointer: `project_stale.md` listed but file missing"] — _source: memory-context_

### When time allows (Info / efficiency)
- [ ] [task — e.g. "Trim `conductor.md` (210 lines) — identify sections that can move to See Also refs"] — _source: token-efficiency_

---

## Next Session Recommendations
1. [Most important — specific skill or file]
2. [Second priority]
3. [Third priority]

---
_Generated by /aios-health on YYYY-MM-DD. Subagents: skill-health, memory-context, data-hygiene, self-improvement, token-efficiency._
```

---

## Phase 6 — Close

Output to the user:

```
AIOS Health audit complete.
Report: data/aios-health-TODAY.md

[N critical · N warning · N info]

Actions taken: N
context-clean: [invoked / skipped — reason]

Top 3 next actions:
1. [from recommendations]
2. [from recommendations]
3. [from recommendations]
```

---

## Edge Cases

- `data/` missing → create it before writing report
- `data/notes.md` missing → skip notes analysis in Agent 3; note in report
- `memory/MEMORY.md` missing or malformed → skip Agent 2; note "memory agent skipped — MEMORY.md unreadable"
- Any agent returns malformed or empty block → mark that dimension as "agent error — manual check required"; continue with other dimensions
- `--dry-run` → run all agents, show all proposed changes, write no files; append "(dry run — no changes made)" to confirmation block
- `--report-only` → run all agents, write report, skip Phase 3 and Phase 4 entirely
- `~/.aios-archive/` subdirs missing → `mkdir -p ~/.aios-archive/daily-briefs ~/.aios-archive/skill-scans` before any `mv`
- Tier B `mv` fails → note failure in "Actions Skipped", continue remaining fixes
- Health report for today already exists → append `## Re-run — HH:MM` section with full findings

---

## See Also

- `context-clean` — triggered conditionally by Phase 4 when data bloat detected
- `skill-scan` — targeted skill-only audit; aios-health covers this and more
- `dev-audit` — dev phase status check; aios-health covers system-wide health

## Next Step

After aios-health: address Critical findings first (broken plugin registrations, missing skill files), then Warning items. Use `session-close` to log what was fixed.
