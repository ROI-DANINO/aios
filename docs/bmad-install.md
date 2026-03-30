# BMAD Claude Code Fork — Install Record

**Date:** 2026-03-30
**Source repo:** https://github.com/aj-geddes/claude-code-bmad-skills
**Install destination:** `~/.claude/skills/`

## What Was Installed

Files were copied from `bmad-v6/skills/` in the cloned repo. The repo structure uses a `bmad-v6/` versioned directory (not a flat `skills/` root), so the copy source was `/tmp/bmad-skills/bmad-v6/skills/*`.

### BMAD-specific skill directories installed

| Dir | Contents |
|-----|----------|
| `~/.claude/skills/core/` | `bmad-master/` — master orchestrator skill |
| `~/.claude/skills/bmb/` | `builder/` — project builder skill |
| `~/.claude/skills/bmm/` | Role agents: analyst, architect, developer, pm, scrum-master, ux-designer |
| `~/.claude/skills/cis/` | `creative-intelligence/` |

### Pre-existing gstack skills also present in source (not overwritten if identical)

autoplan, benchmark, browse, canary, careful, codex, connect-chrome, cso, design-consultation, design-review, design-shotgun, document-release, freeze, gstack, gstack-upgrade, guard, investigate, land-and-deploy, office-hours, plan-ceo-review, plan-design-review, plan-eng-review, qa, qa-only, retro, review, setup-browser-cookies, setup-deploy, ship, unfreeze

## Notes

- The official installer script (`install-v6.sh`) was not used in favor of a direct `cp -r` to keep the install traceable and avoid any side effects.
- BMAD methodology credit: BMAD Code Organization (https://github.com/bmad-code-org/BMAD-METHOD). This repo is a Claude Code adaptation by aj-geddes.
- Skills require a Claude Code session restart to appear as slash commands.
- Registration as plugins (per AIOS CLAUDE.md) not yet done — that is a separate task.
