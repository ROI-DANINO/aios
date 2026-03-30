---
name: AIOS Plugin Infrastructure
description: AIOS skills in skills/ are NOT auto-available as slash commands — they must be installed as plugins via the local aios marketplace
type: project
---

AIOS has a local Claude Code plugin marketplace at `~/.claude/aios-plugins/`. New AIOS skills must be installed there to work via the Skill tool and slash commands.

**Why:** AIOS `skills/*.md` files are markdown SOPs read directly by Claude — they don't register as slash-command skills. Only plugins installed via `claude plugin install` appear in session as invocable skills.

**How to apply:** Every time a new skill is created in `skills/`, follow the 5-step plugin install process documented in CLAUDE.md under "Creating New AIOS Skills". The plugin copy at `~/.claude/aios-plugins/plugins/<name>/skills/<name>/SKILL.md` must be kept in sync with `skills/<name>.md` on updates.
