# AIOS Agent Taxonomy — 2026-03-30

Reference document for the AIOS multi-agent redesign. Maps all existing AIOS skills to BMAD agent roles. Used as input for Task 3 (agent definition files).

---

## 1. Agent Roster

| # | Agent | Model | Permission | Tools Summary |
|---|-------|-------|------------|---------------|
| 1 | Analyst | claude-sonnet-4-6 | default | Read, Grep, Glob, WebSearch, WebFetch, Agent |
| 2 | PM | claude-sonnet-4-6 | default | Read, Write, Edit, Grep, Glob |
| 3 | Architect | claude-opus-4-6 | acceptEdits | Read, Write, Edit, Grep, Glob, Bash (read-only) |
| 4 | Developer | claude-sonnet-4-6 | acceptEdits | Read, Write, Edit, Bash, Grep, Glob |
| 5 | QA | claude-sonnet-4-6 | acceptEdits | Read, Grep, Glob, Bash, Agent |
| 6 | Scrum Master | claude-haiku-4-5-20251001 | default | Read, Write, Edit, Bash (git only), Grep, Glob |
| 7 | Session Agent | claude-haiku-4-5-20251001 | acceptEdits | Read, Write, Edit, Grep, Glob, Bash |
| 8 | Health Agent | claude-sonnet-4-6 | default | Read, Write, Edit, Grep, Glob, Bash, Agent |

---

## 2. Per-Agent Definitions

### Agent 1 — Analyst

**Role:** Research, brainstorming, product strategy, competitive analysis.

**Skills assigned:**
- `brainstorming` (superpowers)
- `plan-ceo-review` (gstack)
- `office-hours` (gstack — authoritative)
- `design-consultation` (gstack)

**Tools:** Read, Grep, Glob, WebSearch, WebFetch, Agent

**Permission mode:** `default`

**Model:** `claude-sonnet-4-6`

**Notes:** WebSearch/WebFetch enabled because research tasks require live data. No file-write access by default — outputs are proposals, not edits. Agent tool allowed for spawning research subagents. The AIOS `office-hours` duplicate is deleted in favor of gstack's authoritative version.

---

### Agent 2 — PM

**Role:** PRD authoring, epics, user stories, acceptance criteria.

**Skills assigned:**
- `writing-plans` (superpowers)
- `executing-plans` (superpowers)
- `pod-mapper` (superpowers — authoritative)
- `business-setup` (superpowers — authoritative)

**Tools:** Read, Write, Edit, Grep, Glob

**Permission mode:** `default`

**Model:** `claude-sonnet-4-6`

**Notes:** Owns all structured planning artifacts (PRDs, roadmaps, story backlogs). No Bash access — output is documents only. The AIOS `pod-mapper` and `business-setup` duplicates are deleted in favor of superpowers versions. No WebSearch — PM works from existing context and Analyst handoffs.

---

### Agent 3 — Architect

**Role:** Architecture design, ADRs, system design, technical feasibility.

**Skills assigned:**
- `system-architect` (AIOS core)
- `plan-eng-review` (gstack)
- `plan-design-review` (gstack)
- `autoplan` (gstack)

**Tools:** Read, Write, Edit, Grep, Glob, Bash (read-only: `ls`, `git log`, `git diff` only)

**Permission mode:** `acceptEdits`

**Model:** `claude-opus-4-6`

**Notes:** Opus justified — architectural decisions have long-term consequences and require deep reasoning. Bash is read-only; destructive operations are blocked. Writes to `docs/superpowers/specs/` and `docs/superpowers/plans/` only. acceptEdits required because architecture docs are written artifacts.

---

### Agent 4 — Developer

**Role:** TDD, implementation, debugging, git worktrees, code review participation.

**Skills assigned:**
- `test-driven-development` (superpowers)
- `subagent-driven-development` (superpowers)
- `dispatching-parallel-agents` (superpowers)
- `using-git-worktrees` (superpowers)
- `requesting-code-review` (superpowers)
- `receiving-code-review` (superpowers)
- `finishing-a-development-branch` (superpowers)
- `systematic-debugging` (superpowers)
- `investigate` (gstack)
- `conductor` (gstack — authoritative)

**Tools:** Read, Write, Edit, Bash, Grep, Glob

**Permission mode:** `acceptEdits`

**Model:** `claude-sonnet-4-6`

**Notes:** Full Bash access required for test runs, builds, git operations, and script execution. The AIOS `conductor` duplicate is deleted in favor of gstack's authoritative version. acceptEdits is appropriate — all file writes should be intentional and visible.

---

### Agent 5 — QA

**Role:** Test suites, quality gates, UX gates, security review, QA passes.

**Skills assigned:**
- `verification-before-completion` (superpowers)
- `ux-gate` (AIOS core)
- `ux-scan` (AIOS core)
- `qa` (gstack)
- `qa-only` (gstack)
- `cso` (gstack)
- `review` (gstack)

**Tools:** Read, Grep, Glob, Bash, Agent

**Permission mode:** `acceptEdits`

**Model:** `claude-sonnet-4-6`

**Notes:** Agent tool allowed for spawning parallel QA subagents (matching current `aios-health` pattern). Bash access needed for running test suites. `ux-gate` and `ux-scan` are AIOS-unique — no plugin equivalent exists; they stay here. acceptEdits for writing QA reports and flagging issues inline.

---

### Agent 6 — Scrum Master

**Role:** Sprint coordination, story preparation, handoffs, merges, retrospectives, deployment.

**Skills assigned:**
- `retro` (gstack — authoritative)
- `ship` (gstack)
- `land-and-deploy` (gstack)
- `setup-deploy` (gstack)
- `canary` (gstack)
- `careful` (gstack)
- `guard` (gstack)
- `freeze` / `unfreeze` (gstack)
- `dev-audit` (AIOS core)

**Tools:** Read, Write, Edit, Bash (git + deploy commands), Grep, Glob

**Permission mode:** `default`

**Model:** `claude-haiku-4-5-20251001`

**Notes:** Haiku justified — coordination tasks are procedural and low-complexity. Bash scoped to git and deploy commands only (no arbitrary script execution). The AIOS `retro` duplicate is deleted in favor of gstack. `dev-audit` stays here as it tracks development-phase status — a coordination concern.

---

### Agent 7 — Session Agent

**Role:** Owns the daily session lifecycle: orientation → capture → wrap-up → maintenance.

**Skills assigned:**
- `daily-brief` (AIOS core)
- `note` (AIOS core)
- `session-close` (AIOS core)
- `session-redo` (AIOS core)
- `context-clean` (AIOS core, scheduled)
- `init` (AIOS core)

**Tools:** Read, Write, Edit, Grep, Glob, Bash

**Permission mode:** `acceptEdits`

**Model:** `claude-haiku-4-5-20251001`

**Notes:** Haiku justified — session lifecycle tasks are structured and low-ambiguity. All six skills are AIOS-unique with no external equivalent. `context-clean` is included here for the scheduled/automated use case (end-of-session trigger); Health Agent also references it for on-demand use. Bash needed for git log reads and file archiving. acceptEdits required because session-close and context-clean write log files.

---

### Agent 8 — Health Agent

**Role:** System health auditing, skill inventory, memory auditing, on-demand maintenance.

**Skills assigned:**
- `aios-health` (AIOS core)
- `skill-scan` (AIOS core)
- `skills-map` (AIOS core)
- `skill-navigator` (AIOS core)
- `context-clean` (AIOS core, on-demand)
- `benchmark` (gstack)
- `git-audit` (gstack)

**Tools:** Read, Write, Edit, Grep, Glob, Bash, Agent

**Permission mode:** `default`

**Model:** `claude-sonnet-4-6`

**Notes:** Agent tool is required — `aios-health` spawns five parallel subagents. Sonnet justified because health audits require judgment about system state, not just pattern matching. `skills-map` and `skill-navigator` are AIOS-unique meta-skills (inventory and routing) — they belong here as operational tooling rather than in any feature-delivery role. Memory audit (future skill) slots here when built.

---

## 3. Skill Assignment Matrix

Every core AIOS skill assigned to exactly one primary owner.

| Skill | Owner Agent | Notes |
|-------|-------------|-------|
| `daily-brief` | Session Agent | Session lifecycle |
| `session-close` | Session Agent | Session lifecycle |
| `session-redo` | Session Agent | Session lifecycle |
| `note` | Session Agent | Session lifecycle |
| `context-clean` | Session Agent (scheduled) / Health Agent (on-demand) | Shared — dual trigger |
| `init` | Session Agent | System initialization |
| `aios-health` | Health Agent | Core audit skill |
| `skill-scan` | Health Agent | Skill inventory |
| `skills-map` | Health Agent | Meta-skill reference |
| `skill-navigator` | Health Agent | Silent skill routing |
| `system-architect` | Architect | Architecture walkthrough |
| `ux-gate` | QA | UX prevention gate |
| `ux-scan` | QA | UX codebase audit |
| `dev-audit` | Scrum Master | Dev phase tracking |

**Superpowers skills** (external plugins — not reassigned, remain on their owners):

| Skill | Assigned to | Reason |
|-------|-------------|--------|
| `brainstorming` | Analyst | Research/ideation |
| `writing-plans` | PM | Planning artifacts |
| `executing-plans` | PM | Plan execution |
| `test-driven-development` | Developer | TDD workflow |
| `subagent-driven-development` | Developer | Parallel implementation |
| `dispatching-parallel-agents` | Developer | Parallel dispatch |
| `using-git-worktrees` | Developer | Isolation workflow |
| `requesting-code-review` | Developer | Review initiation |
| `receiving-code-review` | Developer | Review response |
| `finishing-a-development-branch` | Developer | Branch integration |
| `systematic-debugging` | Developer | Debug workflow |
| `verification-before-completion` | QA | Completion gate |
| `pod-mapper` | PM | Business workflow mapping |
| `business-setup` | PM | System configuration |

---

## 4. Duplicate Resolution

Skills that exist in AIOS `skills/` AND as installed plugins. The AIOS copy should be deleted; the external version is authoritative.

| AIOS Skill File | Authoritative Version | Action | Rationale |
|-----------------|-----------------------|--------|-----------|
| `skills/office-hours.md` | gstack `office-hours` plugin | **Delete AIOS copy** | gstack version has full YC office-hours mode; AIOS copy is a thin wrapper |
| `skills/retro.md` | gstack `retro` plugin | **Delete AIOS copy** | gstack version reads session logs and git history; AIOS copy duplicates this |
| `skills/conductor.md` | gstack `conductor` plugin | **Delete AIOS copy** | gstack version is the authoritative parallel-session launcher |
| `skills/pod-mapper.md` | superpowers `pod-mapper` plugin | **Delete AIOS copy** | superpowers version is installed and active |
| `skills/business-setup.md` | superpowers `business-setup` plugin | **Delete AIOS copy** | superpowers version is installed and active |
| `skills/pod.md` | **Evaluate first** | **Hold — do not delete yet** | May contain unique Gate 1/Gate 2 logic not present in superpowers; needs diff review before deletion |
| `skills/pod-review.md` | **Evaluate first** | **Hold — do not delete yet** | Same as pod.md — gate logic may be AIOS-specific |

**Note on pod.md / pod-review.md:** These should be diffed against the superpowers pod-mapper skill before any deletion decision. If the Gate 1/Gate 2 approval logic is unique, extract it to a new AIOS-specific skill (e.g., `pod-gate.md`) before retiring the files.

---

## 5. oh-my-pi Slot Mapping

oh-my-pi provides 6 named agent slots: `explore`, `plan`, `designer`, `reviewer`, `task`, `quick_task`. Map the 8 AIOS agents to these slots plus overflow handling.

| oh-my-pi Slot | Mapped AIOS Agent | Rationale |
|---------------|-------------------|-----------|
| `explore` | Analyst | Exploration, research, brainstorming — direct semantic match |
| `plan` | PM | Planning artifacts, PRDs, stories — direct semantic match |
| `designer` | Architect | System design, ADRs, technical structure — closest fit |
| `reviewer` | QA | Quality gates, code review, UX scan — direct semantic match |
| `task` | Developer | Implementation, TDD, debugging — primary task executor |
| `quick_task` | Scrum Master | Coordination tasks, git ops, merges — lightweight procedural work |

**Overflow agents (no native oh-my-pi slot):**

| AIOS Agent | Handling |
|------------|----------|
| Session Agent | Runs as a **custom slot** named `session` — or as a pre/post hook on `quick_task` if oh-my-pi supports hooks |
| Health Agent | Runs as a **custom slot** named `health` — or triggered on-demand outside the slot system |

**Custom slot definitions (if oh-my-pi supports them):**

```
session:  Session Agent — daily-brief → note → session-close chain
health:   Health Agent  — aios-health, skill-scan, on-demand audits
```

If oh-my-pi does not support custom slots, Session Agent and Health Agent run as standalone invocations outside the slot framework (e.g., direct skill calls or scheduled triggers).

---

## Design Notes

**Model selection rationale:**
- Opus for Architect only — architectural decisions have the highest consequence-to-frequency ratio; the cost is justified.
- Haiku for Session Agent and Scrum Master — both run frequently (every session) on well-structured, low-ambiguity tasks.
- Sonnet for everything else — balanced capability for standard dev and analysis work.

**Permission mode rationale:**
- `bypassPermissions` is not assigned to any agent. No agent in this taxonomy needs to skip approval — all writes are intentional and auditable.
- `acceptEdits` is used where agents produce file artifacts as primary output (Architect, Developer, QA, Session Agent).
- `default` is used where agents primarily produce recommendations or run read-heavy workflows.

**context-clean dual ownership:**
This skill appears in both Session Agent (scheduled, end-of-session) and Health Agent (on-demand, triggered by audit findings). This is intentional — the trigger context differs. The skill itself is not duplicated; both agents call the same installed plugin. If conflict arises, Session Agent owns the scheduled invocation; Health Agent owns the reactive invocation.
