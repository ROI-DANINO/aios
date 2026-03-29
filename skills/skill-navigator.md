---
name: skill-navigator
description: >
  Contextual silent skill router. Reads skills-map.md and invokes the right skill
  based on what the user is doing — no announcement, no confirmation. Fires automatically
  at session start and after every user message.
---

# Skill Navigator

## Purpose

Route to the right skill silently and contextually. The user never has to name a skill — you detect the situation and invoke it. No announcement. No "I'm using X because Y." Just better behavior.

## When to Run

**Every turn.** Re-evaluate after every user message, not just the first. Context evolves — a follow-up that shifts phase or introduces a new intent should trigger the right skill for that new intent.

At session start, always run this navigator before doing anything else.

## How to Use This Skill

When this skill is loaded, read `skills/skills-map.md` in full. Then apply the matching logic below to the current user message before responding.

## Matching Logic

Apply these rules in order. Stop at the first match.

### 1. Intent Match (primary)
Ask: what is the user actually trying to accomplish? Map that intent to a skill's "What it does" description in `skills-map.md`. Prefer this over keyword scanning — triggers are examples, not a complete list. Only skip to Step 2 if you find two or more equally plausible matches.

### 2. Keyword Match (tiebreaker)
Scan the user's message for phrases from the **Triggers** column. Match on semantic similarity — all key nouns and verbs from the trigger should be present or clearly implied. If still two or more skills match, proceed to Tie-Breaking.

### 3. Phase Awareness
If the session context is dev work (files mentioned, a plan exists, code is being discussed), dev skills take priority over business skills when the trigger is ambiguous. If this still leaves multiple candidates, apply Tie-Breaking.

### 4. No Double-Fire
If a skill was already invoked earlier in this session, do not re-invoke it unless the context has clearly shifted to a new task or phase. A new feature request after finishing one is a clear shift; a follow-up question on the same topic is not.

## Tie-Breaking

If multiple skills could match, prefer the skill that comes **earlier in the dev lifecycle**. Process skills come before implementation skills:

`brainstorming` → `writing-plans` → `test-driven-development` → `executing-plans` → `requesting-code-review` → `finishing-a-development-branch`

For non-dev skills, prefer the more specific skill (e.g. `systematic-debugging` over `office-hours` if there's an active bug).

## No Match

If no skill matches, proceed normally without invoking any skill.

## Behavior Rules

- **Silent** — never announce which skill you're using or why
- **Non-blocking** — if skill invocation fails, proceed without it
- **Contextual** — one match per message; don't stack multiple skills in one turn
- **Aggressive** — when in doubt and a process skill is relevant, invoke it; the cost of a missed skill is higher than the cost of a slightly over-eager one
