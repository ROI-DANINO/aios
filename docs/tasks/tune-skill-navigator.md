# Task: Tune skill-navigator for reliable auto-routing

## Goal
Make Claude auto-invoke the right skill without needing explicit slash commands. Right now
auto-routing works for obvious triggers but misses subtle or mid-conversation cases.

## What to do

1. **Read the current `skill-navigator` skill** — understand what it does now
2. **Read `skills-map.md`** — review all trigger phrases
3. **Tune `skill-navigator`** to be more aggressive:
   - Always run at session start (not just when user seems lost)
   - Re-check skill relevance after every user message, not just the first
   - Expand trigger matching beyond exact phrases — catch intent, not just keywords
   - Prioritize process skills first (brainstorming, debugging) before implementation skills
4. **Tighten trigger phrases in `skills-map.md`** where they're too vague or too narrow
5. **Test against these real scenarios** (make sure the right skill fires):
   - "let's add X to the app" → `brainstorming`
   - "something's broken" → `systematic-debugging`
   - "I'm done" → `finishing-a-development-branch`
   - "closing my laptop" → `session-close`
   - "starting fresh on this project" → `init`
   - "ready to ship" → `ship`

## Success criteria
Claude routes to the correct skill for each test scenario above without the user typing a
slash command. Explicit `/skill-name` invocations still work as before.

## Files to touch
- `skills/skill-navigator.md` — main tuning target
- `skills/skills-map.md` — tighten trigger phrases if needed
