# gstack Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Graft 7 gstack-derived skills into AIOS as native slash commands, covering post-code QA/security/ship/retro lifecycle and browser automation + parallel agent capabilities.

**Architecture:** 7 markdown skill files added to `skills/`, 7 rows added to `skills/skills-map.md` for auto-routing, CLAUDE.md updated with runtime docs. Bun + Playwright installed system-wide as the runtime layer for `/browse`. `/conductor` uses Claude Code's headless mode for parallel sessions.

**Tech Stack:** Markdown skill files, Bun runtime, Playwright (Chromium), Claude Code CLI headless mode

---

## File Map

| Action | File | Purpose |
|---|---|---|
| Create | `skills/qa.md` | QA pass skill |
| Create | `skills/cso.md` | Security officer skill |
| Create | `skills/ship.md` | Release/ship skill |
| Create | `skills/retro.md` | Sprint retrospective skill |
| Create | `skills/office-hours.md` | Unstructured problem-solving skill |
| Create | `skills/browse.md` | Chromium browser automation skill |
| Create | `skills/conductor.md` | Parallel Claude Code sessions skill |
| Modify | `skills/skills-map.md` | Add 7 routing rows |
| Modify | `CLAUDE.md` | Add Runtime Tools section + skills index entries |

---

## Task 1: Runtime Setup — Install Bun and Playwright

**Files:**
- No file changes — system-level install

- [ ] **Step 1: Install Bun**

Run in terminal:
```bash
curl -fsSL https://bun.sh/install | bash
```
Expected output: `bun was installed successfully to ~/.bun/bin/bun`

- [ ] **Step 2: Reload shell so bun is on PATH**

Run:
```bash
source ~/.bashrc   # or ~/.zshrc if you use zsh
bun --version
```
Expected: prints a version like `1.1.x`

- [ ] **Step 3: Install Chromium via Playwright**

Run:
```bash
bunx playwright install chromium
```
Expected: downloads Chromium to `~/.cache/ms-playwright/`. Takes 1-2 minutes.

- [ ] **Step 4: Verify browser works**

Run:
```bash
bunx playwright --version
```
Expected: prints Playwright version. No errors.

---

## Task 2: Write `skills/qa.md`

**Files:**
- Create: `skills/qa.md`

- [ ] **Step 1: Create the file**

Create `skills/qa.md` with this exact content:

```markdown
---
name: qa
description: >
  QA pass before shipping. Reads the current branch diff and test files, runs
  existing tests, flags untested paths, edge cases, and regressions. Outputs a
  pass/fail checklist. Use when user says "qa this", "test coverage", "edge cases",
  "before I ship", or "is this ready to ship".
user-invocable: true
argument-hint: "[path/to/project] — defaults to current working directory"
---

# QA

No guessing. Read the diff. Run the tests. Report the truth.

## When to Trigger

- "qa this"
- "test coverage"
- "edge cases"
- "before I ship"
- "is this ready"
- After implementation, before `/ship`

## Process

### Phase 1: Load context (silent)

1. Identify project root — use argument if provided, else current directory
2. Run `git diff main...HEAD --name-only` to get changed files
3. Find test files: look for `tests/`, `__tests__/`, `*.test.*`, `*.spec.*` in the project
4. Read changed files and their corresponding test files

### Phase 2: Run tests

Run the appropriate test command for the project. Try in order:
```bash
# Python
pytest --tb=short -q

# JavaScript/TypeScript
npm test -- --passWithNoTests

# Bun
bun test
```

Capture output. Note: pass count, fail count, any errors.

### Phase 3: Analyse coverage gaps

For each changed file:
- List functions/methods changed
- Check if corresponding tests exist
- Flag any changed logic with no test coverage
- Identify obvious edge cases not covered (null inputs, empty arrays, auth failures, network errors)

### Phase 4: Output the checklist

```
## QA Report — {project} — {date}

### Test Results
- Status: {PASS / FAIL / UNKNOWN}
- {N} passing, {N} failing
- {Note if tests could not be run and why}

### Coverage Gaps
{For each changed file with gaps:}
- `path/to/file.py` — {function()} has no test for {edge case}

### Regressions to Watch
{Any changed logic that could affect existing behaviour — flag these specifically}

### Verdict
{One line: "Ready to ship." OR "N issues to address before shipping."}
```

### Phase 5: Route

| Verdict | Next step |
|---------|-----------|
| All pass, no gaps | "Run `/ship` when ready." |
| Tests failing | "Fix failing tests before shipping. Run `/systematic-debugging` if stuck." |
| Coverage gaps only | "Consider adding tests for: {list}. Or accept the risk and run `/ship`." |
| Could not run tests | "Set up your test runner first. Then re-run `/qa`." |

## Edge Cases

- **No tests exist** — Report: "No test files found. Flagging all changed logic as untested." List changed functions.
- **Tests pass but no assertions** — Flag: "Tests exist but may not be asserting anything meaningful."
- **Docker required** — If tests need Docker and it's not running, skip live run and use grep to count test functions.
- **Monorepo** — Run tests only in the affected package directory.
```

- [ ] **Step 2: Commit**

```bash
git add skills/qa.md
git commit -m "feat: add /qa skill — QA pass before shipping"
```

---

## Task 3: Write `skills/cso.md`

**Files:**
- Create: `skills/cso.md`

- [ ] **Step 1: Create the file**

Create `skills/cso.md` with this exact content:

```markdown
---
name: cso
description: >
  Security officer review. Scans changed files for OWASP top 10 issues, exposed
  secrets, unsafe inputs, and permission problems. Outputs findings with severity
  (critical/warn/info). Use when user says "security check", "is this safe to ship",
  "cso", or "check for vulnerabilities".
user-invocable: true
argument-hint: "[path/to/file or directory] — defaults to git diff from main"
---

# CSO — Chief Security Officer

Read the code. Find the holes. Report them before they ship.

## When to Trigger

- "security check"
- "is this safe to ship"
- "cso"
- "check for vulnerabilities"
- "audit this"
- After `/qa`, before `/ship` on any externally-facing feature

## Process

### Phase 1: Load context (silent)

1. Get changed files: `git diff main...HEAD --name-only`
2. If argument provided, scope to that file/directory instead
3. Read all changed files in full

### Phase 2: Scan for issues

Check each file against this list. Flag every instance found.

**CRITICAL (block ship):**
- Hardcoded secrets, API keys, passwords, tokens in code
- SQL queries built with string concatenation (SQL injection)
- `eval()` or `exec()` called with user input
- File paths constructed from user input without sanitisation
- Missing authentication on routes that modify data
- Credentials committed to git (check git diff for .env-like patterns)

**WARN (fix before ship unless risk accepted):**
- User input rendered directly into HTML (XSS)
- Unvalidated file uploads (type, size, path)
- Sensitive data logged (emails, tokens, PII)
- CORS set to `*` on an API with auth
- JWT verified without checking algorithm
- Dependency versions pinned to `*` or `latest`

**INFO (note, no action required):**
- `console.log` / `print` statements left in production paths
- TODO/FIXME comments near security-sensitive logic
- Rate limiting absent on public endpoints
- Error messages exposing stack traces to clients

### Phase 3: Output the report

```
## Security Review — {project} — {date}

### CRITICAL 🔴
{finding}: `path/to/file.py:42` — {description of what's wrong and why it matters}
{or "None found."}

### WARN 🟡
{finding}: `path/to/file.py:88` — {description}
{or "None found."}

### INFO 🔵
{finding}: `path/to/file.py:12` — {description}
{or "None found."}

### Verdict
{One line: "Clear to ship." OR "N critical issues must be fixed before shipping."}
```

### Phase 4: Route

| Verdict | Next step |
|---------|-----------|
| No critical issues | "Run `/ship` when ready." |
| Critical issues found | "Fix these before shipping: {list}. Re-run `/cso` after." |
| Warn issues only | "Review warns and decide. Run `/ship` when comfortable." |

## Edge Cases

- **Binary files changed** — Skip them. Note: "Skipped binary files."
- **Generated code** — Flag but note it's generated; fix at the generator level.
- **Test files only changed** — Report: "Only test files changed. No production security surface affected."
- **Can't read a file** — Note the file name and skip it.
```

- [ ] **Step 2: Commit**

```bash
git add skills/cso.md
git commit -m "feat: add /cso skill — security officer review"
```

---

## Task 4: Write `skills/ship.md`

**Files:**
- Create: `skills/ship.md`

- [ ] **Step 1: Create the file**

Create `skills/ship.md` with this exact content:

```markdown
---
name: ship
description: >
  Release checklist. Bumps version, writes changelog entry from git log, creates
  a git tag, outputs deploy command. Confirms before any destructive or external
  action. Use when user says "ship this", "release", "deploy", "tag this", or
  "time to ship".
user-invocable: true
argument-hint: "[version] — e.g. 1.2.0. If omitted, suggests next semver patch."
---

# Ship

One command from done to deployed. No skipped steps. No surprises.

## When to Trigger

- "ship this"
- "release"
- "deploy"
- "tag this"
- "time to ship"
- After `/qa` and `/cso` pass

## Pre-Flight Check

Before doing anything, verify:

1. `git status` — working tree must be clean
2. Current branch — warn if not on `main` or a release branch
3. Last QA/CSO — ask: "Has this been through `/qa` and `/cso`?" If no, recommend running them first. Don't block — Roi decides.

If anything fails pre-flight, report it and ask: "Fix this first, or proceed anyway?"

**HARD RULE: Never proceed past pre-flight without explicit confirmation.**

## Process

### Phase 1: Determine version

1. If argument provided, use it as the new version
2. If no argument: read current version from `package.json`, `pyproject.toml`, or `VERSION` file (try in that order)
3. Suggest next patch version (e.g. `1.2.3` → `1.2.4`)
4. Ask: "Releasing as v{version}. Confirm?"

Wait for confirmation before proceeding.

### Phase 2: Write changelog entry

1. Run: `git log {last_tag}...HEAD --oneline`
2. Group commits by type (feat, fix, chore, docs)
3. Write a changelog entry:

```
## v{version} — {date}

### Features
- {feat commits summarised}

### Fixes
- {fix commits summarised}

### Other
- {chore/docs commits if notable}
```

4. If a `CHANGELOG.md` exists, prepend the entry. If not, create it.
5. Stage the file: `git add CHANGELOG.md`

### Phase 3: Commit + tag

Run these commands. Show each one before running and wait for confirmation on the tag step.

```bash
git commit -m "chore: release v{version}"
```

Then ask: "Create tag v{version}? This will be visible in git history."

On confirmation:
```bash
git tag -a v{version} -m "Release v{version}"
```

### Phase 4: Deploy

Ask: "Push and deploy now?"

On confirmation, run:
```bash
git push origin main --tags
```

Then output the deploy command for the project (read from `Makefile`, `package.json` scripts, or `Procfile`). If none found, output:
```
No deploy command found. Push complete. Run your deploy manually.
```

### Phase 5: Confirm

```
## Ship Report — v{version} — {date}

- [x] Version bumped
- [x] Changelog written
- [x] Commit created
- [x] Tag created: v{version}
- [x] Pushed to origin
- [ ] Deploy: {status}

Shipped. 🚀
```

## Edge Cases

- **No VERSION file or package.json** — Ask: "What version is this? I can't find a version file."
- **No previous tag** — Use first commit as the base for the changelog: `git log --oneline`
- **Dirty working tree** — Hard stop. "Working tree has uncommitted changes. Clean up first."
- **Not on main** — Warn clearly but let Roi decide: "You're on branch {name}, not main. Proceed?"
```

- [ ] **Step 2: Commit**

```bash
git add skills/ship.md
git commit -m "feat: add /ship skill — release checklist"
```

---

## Task 5: Write `skills/retro.md`

**Files:**
- Create: `skills/retro.md`

- [ ] **Step 1: Create the file**

Create `skills/retro.md` with this exact content:

```markdown
---
name: retro
description: >
  Sprint retrospective. Reads session logs and git log to surface what shipped,
  what didn't, one process improvement, and the next sprint focus. Use when user
  says "retro", "retrospective", "end of sprint", "what did we learn", or
  "sprint review".
user-invocable: true
argument-hint: "[sprint name or date range, e.g. 'week of Mar 24'] — defaults to last 7 days"
---

# Retro

Look back. Be honest. Move forward smarter.

## When to Trigger

- "retro"
- "retrospective"
- "end of sprint"
- "what did we learn"
- "sprint review"
- At the end of a dev cycle, after `/ship`

## Process

### Phase 1: Load context (silent)

1. Determine time range: argument if provided, else last 7 days
2. Read `data/session-log-*.md` files within the range (list files in `data/`)
3. Run: `git log --oneline --since="{start_date}" --until="{end_date}"`
4. Read `context/my-goals.md` — top 3 priorities for alignment check

### Phase 2: Build the retro

Answer these four questions from the data:

**1. What shipped?**
Pull from git tags, commits with `feat:` prefix, and session logs marked as completed.

**2. What didn't ship?**
Cross-reference session logs against git — things logged as planned but no corresponding commit. Also check for #blocker tags in notes.

**3. What slowed us down?**
Look for patterns: repeated debugging sessions, blockers mentioned multiple times, tasks that took multiple sessions.

**4. What's the one process improvement?**
Based on question 3, suggest exactly one change. Be specific. Not "communicate better" — "add a `/cso` pass before final review so security issues don't surface at ship time."

### Phase 3: Output the retro

```
## Sprint Retro — {date range}

### What Shipped ✓
{bullet list — specific features/fixes, linked to commits where possible}
{or "Nothing shipped this sprint."}

### What Didn't Ship ✗
{bullet list — planned but not done, with honest reason if visible in the data}
{or "Everything planned shipped."}

### What Slowed Us Down
{bullet list — specific friction points from session logs/notes}
{or "No major blockers this sprint."}

### One Process Improvement
{Single specific change to make next sprint better}

### Goals Alignment
{One sentence: how this sprint's output maps to the top priorities in my-goals.md}

### Next Sprint Focus
{Top 1-2 priorities for the next sprint, derived from "What didn't ship" + goals}
```

## Edge Cases

- **No session logs** — Use git log only. Note: "No session logs found — retro based on git history only."
- **No commits in range** — Report honestly: "No commits in this range. Was this a planning/thinking sprint?"
- **my-goals.md missing** — Skip goals alignment section.
- **Argument is a sprint name** — Try to match to session log filenames or notes containing the sprint name.
```

- [ ] **Step 2: Commit**

```bash
git add skills/retro.md
git commit -m "feat: add /retro skill — sprint retrospective"
```

---

## Task 6: Write `skills/office-hours.md`

**Files:**
- Create: `skills/office-hours.md`

- [ ] **Step 1: Create the file**

Create `skills/office-hours.md` with this exact content:

```markdown
---
name: office-hours
description: >
  Unstructured problem-solving session. No fixed format — asks what you're stuck on
  and reasons through it with you. Use when user says "I'm stuck", "think this
  through", "office hours", "help me reason", "I can't figure this out", or
  "talk me through this".
user-invocable: true
argument-hint: "[optional: brief description of what you're stuck on]"
---

# Office Hours

No agenda. No output format. Just thinking together.

## When to Trigger

- "I'm stuck"
- "think this through with me"
- "office hours"
- "help me reason about this"
- "I can't figure this out"
- "talk me through this"
- Any time the user is blocked and doesn't know the next step

## Process

### If argument provided

Skip the opening question. Start reasoning about the problem described.

### If no argument

Ask exactly one question:

> "What are you stuck on?"

Wait. Don't suggest options. Don't offer frameworks. Just listen.

### Reasoning mode

Once you know the problem:

1. Restate it in one sentence to confirm understanding
2. Ask: "Is that right, or am I missing something?"
3. Once confirmed, reason through it — think out loud, consider alternatives, surface assumptions
4. Don't rush to a solution. The goal is clarity, not a deliverable.
5. End with: "What feels like the right next step from here?"

## Rules

- No output template — every session is different
- Don't turn this into a planning session unless Roi asks
- If the problem needs a skill (e.g. it's a bug → `/systematic-debugging`), say so — but only after you've understood the problem fully
- One question at a time
- No unsolicited advice — follow Roi's thread, don't redirect it
```

- [ ] **Step 2: Commit**

```bash
git add skills/office-hours.md
git commit -m "feat: add /office-hours skill — unstructured problem-solving"
```

---

## Task 7: Write `skills/browse.md`

**Files:**
- Create: `skills/browse.md`

- [ ] **Step 1: Create the file**

Create `skills/browse.md` with this exact content:

```markdown
---
name: browse
description: >
  Real Chromium browser automation via Playwright. Accepts a URL and a task
  description, returns structured text output or saves a screenshot. Use when user
  says "browse", "open this URL", "scrape", "automate this page", "check this
  visually", or "go to [URL]".
user-invocable: true
argument-hint: '"[URL] [task description]" — e.g. "https://example.com get the pricing table"'
---

# Browse

Real browser. Real page. No hallucinated content.

## When to Trigger

- "browse [URL]"
- "open this URL"
- "scrape [URL]"
- "automate this page"
- "check this visually"
- "go to [URL] and [do something]"

## Pre-Flight

Verify runtime is available:
```bash
bunx playwright --version
```
If this fails, tell the user: "Playwright is not installed. Run: `bunx playwright install chromium`"

## Process

### Phase 1: Parse the request

Extract from the argument or user message:
- **URL** — the page to open (must start with `http://` or `https://`)
- **Task** — what to do on the page (read, scrape, screenshot, find element, etc.)

If URL is missing, ask: "What URL should I open?"
If task is missing, ask: "What should I do on that page?"

### Phase 2: Run the browser task

Write a temporary Playwright script to `.tmp/browse-task.js` and run it via `bunx`:

```javascript
// .tmp/browse-task.js
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  await page.goto('{URL}', { waitUntil: 'domcontentloaded', timeout: 30000 });

  // Task-specific logic goes here based on the request:
  // - For "get text": const text = await page.innerText('body'); console.log(text);
  // - For "screenshot": await page.screenshot({ path: '.tmp/browse-screenshot.png' });
  // - For "find X": const el = await page.$eval('{selector}', el => el.textContent);

  await browser.close();
})();
```

Run: `bunx node .tmp/browse-task.js`

**HARD RULE: Never write a script that submits a form, clicks a purchase/delete/send button, or posts data without explicit per-action approval from Roi.**

### Phase 3: Output

Return the result in a clean format:

```
## Browse Result — {URL}
**Task:** {what was requested}
**Date:** {today}

{Result text, table, or "Screenshot saved to .tmp/browse-screenshot.png"}
```

If the page fails to load, report: "Could not load {URL}. Error: {message}. Is the URL correct and accessible?"

## Edge Cases

- **Auth-required page** — Report: "This page requires login. I can't authenticate automatically. Try a public URL or log in manually and share the content."
- **JavaScript-heavy SPA** — Use `waitUntil: 'networkidle'` instead of `domcontentloaded` in the script
- **Screenshot requested** — Save to `.tmp/browse-screenshot.png` and report the path
- **URL with no protocol** — Prepend `https://` and proceed
```

- [ ] **Step 2: Commit**

```bash
git add skills/browse.md
git commit -m "feat: add /browse skill — Chromium browser automation via Playwright"
```

---

## Task 8: Write `skills/conductor.md`

**Files:**
- Create: `skills/conductor.md`

- [ ] **Step 1: Create the file**

Create `skills/conductor.md` with this exact content:

```markdown
---
name: conductor
description: >
  Parallel Claude Code sessions for independent workstreams. Lists tasks, confirms
  the split, spawns headless Claude Code sub-sessions, and tracks completion. Use
  when user says "run these in parallel", "spin up agents", "conductor", or
  "multiple workstreams".
user-invocable: true
argument-hint: "[optional: comma-separated task list]"
---

# Conductor

Split the work. Run it in parallel. Collect the results.

## When to Trigger

- "run these in parallel"
- "spin up agents"
- "conductor"
- "multiple workstreams"
- Any time 2+ tasks are clearly independent and could be worked simultaneously

## Pre-Flight

1. Verify Claude Code CLI is available: `claude --version`
2. Verify tasks are genuinely independent — no task's output is another task's input

If tasks have dependencies, route to `superpowers:dispatching-parallel-agents` instead.

## Process

### Phase 1: Define the tasks

If argument provided, parse the comma-separated list.
If no argument, ask: "What are the independent tasks you want to run in parallel?"

List them back to the user:
```
Parallel tasks:
1. {task 1}
2. {task 2}
3. {task 3 if any}

These will each run in a separate Claude Code session simultaneously. Confirm?
```

**HARD RULE: Never spawn sessions without explicit confirmation.**

### Phase 2: Prepare task prompts

For each task, write a self-contained prompt file to `.tmp/conductor-task-{N}.md`:

```markdown
# Task {N}: {task name}

## Context
{Relevant project context — file paths, what already exists, what this task should produce}

## Goal
{Specific, concrete output expected}

## Instructions
- Work only on this task
- Do not modify files outside the scope listed
- Commit your changes when done
- Write a completion summary to `.tmp/conductor-result-{N}.md`
```

### Phase 3: Spawn sessions

For each task, spawn a background Claude Code session:

```bash
claude --dangerously-skip-permissions -p "$(cat .tmp/conductor-task-{N}.md)" > .tmp/conductor-log-{N}.txt 2>&1 &
```

Report: "Spawned {N} sessions. Monitoring..."

### Phase 4: Track completion

Poll every 30 seconds:
```bash
ls .tmp/conductor-result-*.md 2>/dev/null | wc -l
```

When all result files exist, report:

```
## Conductor Results

### Task 1: {name}
{contents of .tmp/conductor-result-1.md}

### Task 2: {name}
{contents of .tmp/conductor-result-2.md}

### Summary
{N}/{N} tasks completed. Review results above and resolve any conflicts before committing.
```

## Edge Cases

- **Tasks have a dependency** — Refuse to run them in parallel: "Task 2 depends on Task 1's output. Run them sequentially instead."
- **One session fails** — Report partial results. Don't suppress failures: "Task 2 failed. Log at `.tmp/conductor-log-2.txt`."
- **More than 5 tasks** — Warn: "Running {N} parallel sessions is resource-intensive. Consider batching. Proceed?"
- **claude CLI not found** — "Claude Code CLI not found. Install it at claude.ai/code."
```

- [ ] **Step 2: Commit**

```bash
git add skills/conductor.md
git commit -m "feat: add /conductor skill — parallel Claude Code sessions"
```

---

## Task 9: Update `skills/skills-map.md`

**Files:**
- Modify: `skills/skills-map.md`

- [ ] **Step 1: Add Phase 3 rows**

In `skills/skills-map.md`, find the Phase 3 table (ends with the `writing-skills` row). Add these 4 rows before the closing `---`:

```markdown
| `qa`        | dev     | qa this, test coverage, edge cases, before I ship          | QA pass — tests, untested paths, regressions        |
| `cso`       | dev     | security check, is this safe to ship, cso                 | Security review — OWASP, secrets, permissions        |
| `ship`      | dev     | ship this, release, deploy, tag this                       | Release — version bump, changelog, git tag           |
| `retro`     | dev     | retro, retrospective, end of sprint, what did we learn     | Sprint retro — shipped, missed, next focus           |
```

- [ ] **Step 2: Add Phase 4 rows**

In the Phase 4 table (ends with `writing-skills`), add these 3 rows:

```markdown
| `office-hours` | dev  | I'm stuck, think this through, office hours, help me reason | Unstructured problem-solving session               |
| `browse`       | dev  | browse, open URL, scrape, automate this page, go to URL    | Real Chromium automation via Playwright              |
| `conductor`    | dev  | run in parallel, spin up agents, conductor, multiple workstreams | Parallel Claude Code sessions for independent tasks |
```

- [ ] **Step 3: Verify the map looks right**

Read `skills/skills-map.md` and confirm all 7 new rows appear in the correct phase sections.

- [ ] **Step 4: Commit**

```bash
git add skills/skills-map.md
git commit -m "feat: add 7 gstack skills to skills-map for auto-routing"
```

---

## Task 10: Update `CLAUDE.md`

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Add Runtime Tools section**

At the end of `CLAUDE.md`, add:

```markdown
## Runtime Tools

AIOS has Bun and Playwright (Chromium) installed system-wide. Skills that use the browser or parallel sessions call these directly — no setup needed per session.

- **Bun:** `~/.bun/bin/bun` — JS runtime for Playwright scripts
- **Playwright/Chromium:** `~/.cache/ms-playwright/` — real browser for `/browse`
- **Claude Code CLI headless mode:** used by `/conductor` to spawn parallel sessions

## gstack Skills Index

Additional skills grafted from gstack (available as slash commands):

**Dev lifecycle (run after `finishing-a-development-branch`):**
- `/qa` — QA pass: runs tests, flags untested paths and edge cases
- `/cso` — Security review: OWASP scan, secrets check, permission audit
- `/ship` — Release: version bump, changelog, git tag, push
- `/retro` — Sprint retrospective: what shipped, what didn't, next focus

**Anytime:**
- `/office-hours` — Unstructured problem-solving, no fixed format
- `/browse [URL] [task]` — Real Chromium browser automation via Playwright
- `/conductor` — Spawn parallel Claude Code sessions for independent tasks
```

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: add runtime tools and gstack skills index to CLAUDE.md"
```

---

## Task 11: Smoke Test

- [ ] **Step 1: Verify all 7 skill files exist**

```bash
ls skills/qa.md skills/cso.md skills/ship.md skills/retro.md skills/office-hours.md skills/browse.md skills/conductor.md
```
Expected: all 7 files listed, no "No such file" errors.

- [ ] **Step 2: Verify skills-map has all 7 new rows**

```bash
grep -E "qa|cso|ship|retro|office-hours|browse|conductor" skills/skills-map.md
```
Expected: 7 lines, one per skill.

- [ ] **Step 3: Verify CLAUDE.md has the Runtime Tools section**

```bash
grep "Runtime Tools" CLAUDE.md
```
Expected: one match.

- [ ] **Step 4: Test `/browse` with a real URL**

In a Claude Code session, type:
```
/browse https://example.com get the page title
```
Expected: Claude runs Playwright, returns "Example Domain" (or similar page title). No errors about missing runtime.

- [ ] **Step 5: Final commit**

```bash
git add .
git status  # verify nothing unexpected staged
git commit -m "feat: gstack integration complete — 7 skills, runtime, skills-map, CLAUDE.md"
```
