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
Scan the user's message for phrases from the **Triggers** column in `skills-map.md`. Triggers are examples, not exhaustive lists — match on semantic similarity where all key nouns and verbs from the trigger are present in the user's message. If two or more skills match at this step, proceed to Tie-Breaking before invoking.

### 2. Intent Match
If no keyword match, consider what the user is trying to accomplish. Map that intent to a skill's "What it does" description. Only match if you can identify a single skill without hesitation. If two or more skills are plausible, proceed to Rule 3.

### 3. Phase Awareness
If the session context is dev work (files mentioned, a plan exists, code being discussed), dev skills take priority over business skills when the trigger is ambiguous. If Phase Awareness still leaves multiple candidate skills, apply Tie-Breaking before invoking.

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
