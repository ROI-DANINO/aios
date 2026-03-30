---
name: Agent Taxonomy Project
description: Decision log and context for AIOS multi-agent team redesign — architecture chosen, research done, ready to build
type: project
---

AIOS is being redesigned as a proper multi-agent team system using BMAD role-first architecture on top of the existing AIOS state layer.

**Why:** Current skills are a sloppy pile — no agent boundaries, no handoff protocol, no tool allowlists, broken session chain. Goal is to go from markdown SOPs to a cutting-edge agentic dev team.

**Architecture decision (confirmed):** BMAD role-first + AIOS state layer + oh-my-pi as runtime

```
BMAD roles (who does what)
    +
AIOS state layer (data/, memory/, session chain)
    +
oh-my-pi as runtime (future)
```

**Why BMAD:** 42.9k stars, most proven, maps to real team roles, complete artifact-driven handoff protocol, Claude Code fork ready to install, additive to existing AIOS — not a rewrite.

**Target agent roles (BMAD-style):**
- Analyst — research, brainstorming, product-brief.md
- PM — PRD.md, epics, stories
- Architect — architecture.md, ADRs
- Dev — implementation, TDD
- QA — test suites, quality gates
- Scrum Master — sprint coordination, story prep, handoffs
- Session Agent — daily-brief, note, session-close, memory (AIOS-specific)
- Health Agent — aios-health, skill-scan, context-clean (AIOS-specific)

**Key research artifacts:**
- `deliverables/skills-inventory-2026-03-30.md` — 50 skills audited, gaps flagged
- `deliverables/agentic-research-2026-03-30.md` — full community research, BMAD deep-dive, config standards, 15 adjacent projects

**What's already done:**
- Full skills audit complete
- Architecture decision made
- Research compiled and committed

**What needs to be built (in order):**
1. Install BMAD Claude Code fork (aj-geddes/claude-code-bmad-skills → ~/.claude/skills/)
2. Design agent taxonomy — map existing AIOS skills to BMAD roles + AIOS-specific agents
3. Create agent definition files (.claude/agents/) with tools allowlist + permissions
4. Fix broken session chain (daily-brief → note → session-close → memory → context-clean)
5. Add tools: frontmatter to all existing skills
6. Merge/discard duplicate skills (8 AIOS skills duplicated by gstack/superpowers)
7. Write 6 missing placeholder skills (agent-config, memory-audit, context-loader, handoff, tool-registry, session-health)
8. Sync to oh-my-pi format (.omp/agents/, .omp/skills/) when ready

**Why:** Dogfooding AIOS while building it as a product. Both personal use and product development.

**How to apply:** Every session that touches AIOS skills, agent definitions, or session workflow should reference this context. The skills inventory and research docs are the ground truth.
