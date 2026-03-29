# Skill Inventory Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire AIOS skills into explicit workflow chains and prune local duplicates superseded by gstack equivalents.

**Architecture:** Each skill gets a `## Next Step` section (hard handoff) and a `## See Also` section (soft cross-refs) appended to its markdown. Four local skill files that duplicate gstack equivalents are deleted. Two skills (retro, office-hours) are hardened to distinguish them from their gstack counterparts.

**Tech Stack:** Markdown only — no build system. All changes are file edits and deletes. Verification is text grep.

---

### Task 1: Create the backlog file

**Files:**
- Create: `data/skill-improvement-backlog.md`

- [ ] **Step 1: Create the file**

```markdown
# Skill Improvement Backlog

## Wiring tasks
<!-- Items appended by /skill-scan -->

## Cleanup tasks
<!-- Items appended by /skill-scan -->

## Open questions
- [ ] `system-architect` — clarify whether it's a standalone entry point or always follows `init`
- [ ] `office-hours` — validate that merged gstack format doesn't conflict with local debugging route
- [ ] `conductor` vs `superpowers:dispatching-parallel-agents` — document the difference clearly in both skill files
```

- [ ] **Step 2: Verify file exists**

Run: `ls data/skill-improvement-backlog.md`
Expected: file listed

- [ ] **Step 3: Commit**

```bash
git add data/skill-improvement-backlog.md
git commit -m "feat: create skill improvement backlog"
```

---

### Task 2: Wire session loop chain

**Files:**
- Modify: `skills/daily-brief.md`
- Modify: `skills/note.md`
- Modify: `skills/session-close.md`

- [ ] **Step 1: Append to `skills/daily-brief.md`**

```markdown

## Next Step

After your session focus is confirmed: use `/note "text"` to capture decisions and blockers mid-session. When done, run `/session-close` to log the session and extract memory.

## See Also

- `/note` — mid-session capture
- `/session-close` — end of session log and memory extraction
```

- [ ] **Step 2: Verify**

Run: `grep "session-close" skills/daily-brief.md`
Expected: line found

- [ ] **Step 3: Append to `skills/note.md`**

```markdown

## See Also

- `/daily-brief` — session start, sets the agenda this note feeds into
- `/session-close` — reads notes.md at end of session to extract memory
```

- [ ] **Step 4: Verify**

Run: `grep "daily-brief" skills/note.md`
Expected: line found

- [ ] **Step 5: Append to `skills/session-close.md`**

```markdown

## See Also

- `/daily-brief` — run at the start of the next session to pick up where you left off
- `/note` — mid-session capture that feeds into this log
```

- [ ] **Step 6: Verify**

Run: `grep "daily-brief" skills/session-close.md`
Expected: line found

- [ ] **Step 7: Commit**

```bash
git add skills/daily-brief.md skills/note.md skills/session-close.md
git commit -m "feat: wire session loop chain — daily-brief → note → session-close"
```

---

### Task 3: Wire dev pipeline chain

Note: local `qa`, `cso`, `ship` are being deleted in Task 6. Handoffs point to gstack versions.

**Files:**
- Modify: `skills/dev-audit.md`
- Modify: `skills/retro.md`

- [ ] **Step 1: Append to `skills/dev-audit.md`**

```markdown

## Next Step

When audit is complete and phase is healthy: run `/qa` (gstack) to check coverage and flag untested paths, then `/cso` for security review, then `/ship` to release.

If UX intent is missing: run `/ux-scan` before continuing.

## See Also

- `/qa` (gstack) — test coverage check, runs after audit
- `/cso` (gstack) — security review
- `/ship` (gstack) — release
- `/ux-scan` — UX audit, feeds back into dev-audit
- `/retro` — end-of-sprint retrospective
```

- [ ] **Step 2: Verify**

Run: `grep "ux-scan" skills/dev-audit.md`
Expected: line found

- [ ] **Step 3: Append to `skills/retro.md`**

```markdown

## Next Step

After the retrospective: update `context/my-goals.md` if priorities shifted, then start the next sprint with `/daily-brief`.

## See Also

- `/dev-audit` — feeds into retro via session logs and git history
- `/daily-brief` — next session start, picks up the sprint focus from retro output
- `/ship` (gstack) — the step before retro in the dev pipeline
```

- [ ] **Step 4: Verify**

Run: `grep "dev-audit" skills/retro.md`
Expected: line found

- [ ] **Step 5: Commit**

```bash
git add skills/dev-audit.md skills/retro.md
git commit -m "feat: wire dev pipeline chain — dev-audit → qa → cso → ship → retro"
```

---

### Task 4: Wire project setup chain

**Files:**
- Modify: `skills/init.md`
- Modify: `skills/system-architect.md`

- [ ] **Step 1: Append to `skills/init.md`**

```markdown

## Next Step

After project is registered: run `/system-architect` to design the architecture, or go straight to `/business-setup` if this is a new AIOS context.

## See Also

- `/system-architect` — architecture design, natural follow-on after init
- `/business-setup` — AIOS context setup, alternative next step for new installs
```

- [ ] **Step 2: Verify**

Run: `grep "system-architect" skills/init.md`
Expected: line found

- [ ] **Step 3: Append to `skills/system-architect.md`**

```markdown

## Next Step

After architecture is documented: enter the appropriate workflow chain — `/business-setup` for a new AIOS context, or `/dev-audit` to audit an existing project phase.

## See Also

- `/init` — project onboarding, typically runs before system-architect
- `/business-setup` — AIOS context setup
- `/dev-audit` — active project phase audit
```

- [ ] **Step 4: Verify**

Run: `grep "dev-audit" skills/system-architect.md`
Expected: line found

- [ ] **Step 5: Commit**

```bash
git add skills/init.md skills/system-architect.md
git commit -m "feat: wire project setup chain — init → system-architect"
```

---

### Task 5: Wire business, multi-agent, and UX chains

**Files:**
- Modify: `skills/business-setup.md`
- Modify: `skills/pod-mapper.md`
- Modify: `skills/pod.md`
- Modify: `skills/pod-review.md`
- Modify: `skills/ux-gate.md`
- Modify: `skills/ux-scan.md`

- [ ] **Step 1: Append to `skills/business-setup.md`**

```markdown

## Next Step

After context is configured: run `/pod-mapper` to map your business workflows into automatable pods.

## See Also

- `/pod-mapper` — workflow audit, natural follow-on after business setup
- `/init` — project onboarding, pairs with business-setup for new AIOS installs
```

- [ ] **Step 2: Append to `skills/pod-mapper.md`**

```markdown

## Next Step

After pod map is written: execute with `/pod "task"` to dispatch a multi-agent dev team, or continue mapping another business function.

## See Also

- `/business-setup` — AIOS context, runs before pod-mapper
- `/pod` — multi-agent execution of the workflows mapped here
```

- [ ] **Step 3: Append to `skills/pod.md`**

```markdown

## Next Step

When all agents report complete: run `/pod-review` to review diffs at Gate 2, approve, and open the PR.

## See Also

- `/pod-review` — Gate 2 review and PR creation
- `/pod-mapper` — maps the workflows that feed into pod tasks
- `superpowers:dispatching-parallel-agents` — Agent SDK alternative for parallel work (no headless sessions)
```

- [ ] **Step 4: Append to `skills/pod-review.md`**

```markdown

## Next Step

After PR is opened: run `superpowers:finishing-a-development-branch` to merge and close the branch.

## See Also

- `/pod` — Gate 1 entry point that dispatched the agents reviewed here
- `superpowers:finishing-a-development-branch` — branch merge and cleanup
```

- [ ] **Step 5: Append to `skills/ux-gate.md`**

```markdown

## Next Step

After gate passes and the feature is built: run `/ux-scan` to audit the implementation for UX completeness.

## See Also

- `/ux-scan` — post-build UX audit, reviews what was gated here
- `/dev-audit` — overall project phase status, includes UX as a health signal
```

- [ ] **Step 6: Append to `skills/ux-scan.md`**

```markdown

## Next Step

After findings are reviewed: feed critical issues into `/dev-audit` to update project phase status, or act on individual findings with `superpowers:brainstorming`.

## See Also

- `/ux-gate` — pre-build gate that defines the intent this scan verifies
- `/dev-audit` — phase status audit, reads ux-scan findings as a health signal
```

- [ ] **Step 7: Verify all six**

Run: `grep -l "Next Step" skills/business-setup.md skills/pod-mapper.md skills/pod.md skills/pod-review.md skills/ux-gate.md skills/ux-scan.md`
Expected: all six files listed

- [ ] **Step 8: Commit**

```bash
git add skills/business-setup.md skills/pod-mapper.md skills/pod.md skills/pod-review.md skills/ux-gate.md skills/ux-scan.md
git commit -m "feat: wire business, multi-agent, and UX chains"
```

---

### Task 6: Remove duplicate skills superseded by gstack

**Files:**
- Delete: `skills/browse.md`
- Delete: `skills/cso.md`
- Delete: `skills/qa.md`
- Delete: `skills/ship.md`

- [ ] **Step 1: Delete the four files**

```bash
rm skills/browse.md skills/cso.md skills/qa.md skills/ship.md
```

- [ ] **Step 2: Verify deleted**

Run: `ls skills/browse.md skills/cso.md skills/qa.md skills/ship.md 2>&1`
Expected: "No such file or directory" for all four

- [ ] **Step 3: Verify gstack equivalents still respond**

Ask Claude: "run /browse" — confirm gstack version activates (Playwright-based).
Ask Claude: "security check" — confirm gstack `/cso` activates.

- [ ] **Step 4: Commit**

```bash
git commit -m "chore: remove local browse/cso/qa/ship — superseded by gstack equivalents"
```

---

### Task 7: Harden retro and office-hours

**Files:**
- Modify: `skills/retro.md`
- Modify: `skills/office-hours.md`

- [ ] **Step 1: Add gstack differentiation note to top of `skills/retro.md`** (after frontmatter, before `# Retro` heading)

Add after the closing `---` of the frontmatter:

```markdown
> **Note:** This is the AIOS-native retro. It reads `data/session-log-*.md` for full session context. The gstack `/retro` does not have access to AIOS session logs — use this version for AIOS project retrospectives.

```

- [ ] **Step 2: Add open-ended fallback to `skills/office-hours.md`**

Append at end of file:

```markdown

## Open-Ended Mode

If the problem doesn't fit a specific skill, stay open. Reason through alternatives out loud, surface assumptions, and end with: "What feels like the right next step from here?" No fixed output format.

> **Note:** The gstack `/office-hours` runs YC-style forcing questions. This AIOS version prioritizes understanding the problem before any framework. If you want the forcing-question format, say "office hours YC mode."

## See Also

- `superpowers:systematic-debugging` — for bugs with a clear reproduction path
- `superpowers:brainstorming` — for feature ideation with a structured design output
```

- [ ] **Step 3: Verify**

Run: `grep "session-log" skills/retro.md && grep "YC mode" skills/office-hours.md`
Expected: both lines found

- [ ] **Step 4: Commit**

```bash
git add skills/retro.md skills/office-hours.md
git commit -m "feat: harden retro + office-hours — differentiate from gstack equivalents"
```

---

### Task 8: Update skills-map to reflect chains

**Files:**
- Modify: `skills/skills-map.md`

- [ ] **Step 1: Read current skills-map structure**

Run: `head -60 skills/skills-map.md`

- [ ] **Step 2: Add or update a "Workflow Chains" section**

Add after the existing skill listing (before the final notes or at the end):

```markdown
---

## Workflow Chains

Quick reference for skill sequencing. Each `→` is a hard handoff defined in the skill file.

| Chain | Sequence |
|---|---|
| **Session loop** | `/daily-brief` → (work) → `/note` → `/session-close` → next day `/daily-brief` |
| **Dev pipeline** | `/dev-audit` → `/qa` → `/cso` → `/ship` → `/retro` |
| **Project setup** | `/init` → `/system-architect` → `/business-setup` or dev pipeline |
| **Business** | `/business-setup` → `/pod-mapper` → `/pod` |
| **Multi-agent** | `/pod` → `/pod-review` → `superpowers:finishing-a-development-branch` |
| **UX** | `/ux-gate` → (build) → `/ux-scan` → `/dev-audit` |
```

- [ ] **Step 3: Verify**

Run: `grep "Workflow Chains" skills/skills-map.md`
Expected: line found

- [ ] **Step 4: Commit**

```bash
git add skills/skills-map.md
git commit -m "docs: add workflow chains reference to skills-map"
```

---

## Verification Checklist

- [ ] `data/skill-improvement-backlog.md` exists with three sections
- [ ] `grep "Next Step" skills/daily-brief.md skills/dev-audit.md skills/pod.md` — all found
- [ ] `ls skills/browse.md` returns "No such file"
- [ ] `grep "AIOS-native" skills/retro.md` — found
- [ ] `grep "Workflow Chains" skills/skills-map.md` — found
- [ ] Run `/skill-scan` after completion — confirms chain gaps are resolved
