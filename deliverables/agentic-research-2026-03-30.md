# Agentic Dev Community Research — 2026-03-30
> Context for AIOS agent taxonomy design. Compiled from 3 research agents + known sources.
> **Gaps to fill next session:** BMAD deep-dive, agent config standards comparison, BMAD-adjacent projects list.

---

## 1. Projects Most Similar to What You're Building

### Closest spiritual twins

| Project | Stars | Why it matters |
|---|---|---|
| [danielmiessler/Personal_AI_Infrastructure](https://github.com/danielmiessler/Personal_AI_Infrastructure) | Modest | **Closest match** — Claude Code-native, file-driven, 7 components: Identity, Preferences, Workflows, Skills, Hooks, Memory, Routing. Now at v3.0 with feedback-based self-improvement. |
| [agiresearch/AIOS](https://github.com/agiresearch/AIOS) | ~4,100 | LLM kernel embedded into OS runtime — agent scheduling, memory management, tool access, process isolation. Proves the "OS for agents" framing is taken seriously at research level. |
| [MemTensor/MemOS](https://github.com/MemTensor/MemOS) | — | Memory OS for agents — hierarchical memory (short/mid/long term), dedicated memory agents per type. Directly relevant to AIOS memory architecture. |
| [Mirix-AI/MIRIX](https://github.com/Mirix-AI/MIRIX) | — | 6 specialized memory agents: Core, Episodic, Semantic, Procedural, Resource, Knowledge Vault. Each agent owns a memory type. |

### Broader ecosystem validation

| Project | Stars | Why it matters |
|---|---|---|
| [danielmiessler/Fabric](https://github.com/danielmiessler/Fabric) | 70,000+ | Markdown SOPs as CLI-invocable skills — 70k engineers. Biggest validation that markdown-as-skill works at scale. |
| [mem0ai/mem0](https://github.com/mem0ai/mem0) | 20,000+ | De facto standard for persistent agent memory. Community is converging on this rather than rolling their own. |
| [LangGraph](https://github.com/langchain-ai/langgraph) | 12,000+ | Production winner for multi-agent orchestration — graph state machines, checkpointing, time-travel debug. Running at LinkedIn, Uber, 400+ companies. |
| [CrewAI](https://github.com/joaomdmoura/crewAI) | 28,000+ | Popularized role-as-configuration — role + goal + backstory + tools in YAML. |
| [n8n](https://github.com/n8n-io/n8n) | 150,000+ | Visual workflow + agent orchestration. Signal: non-dev builders are converging on event-triggered node-graph tools. |

---

## 2. BMAD Method (fill-in from known sources)

**GitHub:** https://github.com/bmadcode/BMAD-METHOD — "Breakthrough Method for Agile AI-Driven Development"

The most directly relevant methodology for your agent taxonomy work. BMAD defines a team of AI agents, each with a persona, SOP, and task scope — designed to run inside Claude Code / Cursor as slash commands.

### BMAD Agent Roles

| Agent | Persona | What it does | Key tasks |
|---|---|---|---|
| **Analyst** | Mary | Requirements gathering, user research, problem framing | Interview user, write brief, validate assumptions |
| **PM** | John | Product requirements, prioritization, roadmap | Write PRD, define success metrics, scope features |
| **Architect** | Sage | System design, tech decisions, architecture docs | Write architecture doc, define interfaces, review design |
| **Dev** | James | Implementation | Write code, follow architecture, implement tasks |
| **QA** | Quinn | Testing, quality gates | Write test cases, find edge cases, approve for ship |
| **Scrum Master** | Bob | Sprint orchestration, unblocking | Plan sprints, run retrospectives, coordinate handoffs |

### BMAD Config Pattern
Each agent is a **markdown file** with:
- Frontmatter: name, role, persona description
- Body: SOP — what to do, in what order, what to produce
- Checklists: explicit done-criteria before handoff

The handoff protocol is explicit: each agent produces a **deliverable** (PRD, arch doc, task list, code, test results) and the next agent picks it up. No implicit context passing.

### Why BMAD is relevant to you
Your AIOS skills are already structured like BMAD SOPs. The gap is: BMAD has **explicit agent boundaries** (who owns what), **clear handoff deliverables**, and **done checklists**. Your skills currently lack all three.

**To research further:** https://github.com/bmadcode/BMAD-METHOD

---

## 3. oh-my-pi — How It Actually Works

**Key finding: your AIOS skills already work inside oh-my-pi without changes.** oh-my-pi reads `~/.claude/skills/`, `~/.claude/commands/`, and Claude plugin `installed_plugins.json` natively.

### Agent definition format (`.omp/agents/<name>.md`)

```yaml
---
name: my-reviewer
description: "One-liner shown in tool description"
systemPrompt: |
  You are a strict code reviewer...
tools: read,bash,task        # allowlist — comma-separated
spawns: "*"                  # which child agents this agent can spawn
model: claude-opus-4         # optional model override
thinkingLevel: high          # optional
---

Additional system prompt content here.
```

**No role/goal/permissions fields** — tool access is the `tools` allowlist, agent spawning is `spawns`.

### Custom skill format (`.omp/skills/<name>/SKILL.md`)

```yaml
---
name: semantic-compression
description: "Compress text for LLM prompts"
globs: ["**/*.md"]           # auto-apply by file pattern
alwaysApply: false
---

Skill body here.
```

### Custom command format (`.omp/commands/<name>.md`)

```markdown
---
description: "Release at a given version"
---
Release with `$ARGUMENTS` version.
```bash
bun scripts/release.ts $ARGUMENTS
```
```

### TypeScript extension format (`.omp/extensions/<name>.ts`)

Full API access — register tools, slash commands, and lifecycle hooks in one file:

```typescript
import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerTool({ name, description, parameters, execute });
  pi.registerCommand("name", { description, handler });
  pi.on("tool_call", async (event, ctx) => { /* can block */ });
}
```

### Hook events available
Session: `session_start`, `session_shutdown`, `session_compact`, `session_branch`
Agent: `before_agent_start`, `agent_start`, `agent_end`, `turn_start`, `turn_end`
Tools: `tool_call` (blockable), `tool_result` (overridable)

### Priority order for agent/skill/command discovery
`.omp/` (project) > `~/.omp/` (user) > `.claude/` > Claude plugins > bundled

---

## 4. MCP Ecosystem — What to Install

### Must-haves for a multi-agent dev system

| Layer | Server | Install |
|---|---|---|
| Code intelligence | [Serena](https://github.com/oraios/serena) (22k stars) — symbol-level tools, LSP-backed, token-efficient | `pip install serena && serena mcp` |
| Filesystem + terminal | [DesktopCommanderMCP](https://github.com/wonderwhy-er/DesktopCommanderMCP) (5.8k) — best all-in-one | `npx @wonderwhy-er/desktop-commander` |
| Git/GitHub | [github/github-mcp-server](https://github.com/github/github-mcp-server) — official, full PR/issue surface | `npx @github/mcp-server` |
| Browser | Already have `/browse` via Playwright | — |
| Search | Brave Search + [Exa](https://github.com/exa-labs/exa-mcp-server) | `npx @modelcontextprotocol/server-brave-search` |
| Memory (episodic) | [mem0](https://github.com/mem0ai/mem0) — has Claude Code plugin | `claude plugin install mem0` |
| Memory (semantic/vector) | [Qdrant MCP](https://github.com/qdrant/mcp-server-qdrant) | `npx @qdrant/mcp-server` |
| Code sandbox | [E2B](https://github.com/e2b-dev/mcp-server) — isolated containers | `npx @e2b/mcp-server` |
| Tool aggregator | [Composio](https://github.com/ComposioHQ/composio) (27.6k) — 1000+ APIs, one MCP server | `pip install composio-core` |
| Workflow enforcement | [spec-workflow-mcp](https://github.com/Pimzino/spec-workflow-mcp) (4k) — SOPs as MCP tools | `npx @pimzino/spec-workflow-mcp` |

### Skills libraries to browse
- [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) — 1,326+ agentic skills for Claude Code/Cursor/Codex
- [microsoft/skills](https://github.com/microsoft/skills) — 132 domain skills packaged with MCP configs
- [ComposioHQ/awesome-claude-plugins](https://github.com/ComposioHQ/awesome-claude-plugins) — 49k stars, Claude Code-specific plugins

### Registries to bookmark
- https://registry.modelcontextprotocol.io — canonical index
- https://smithery.ai — community marketplace (already in your AIOS)
- https://github.com/appcypher/awesome-mcp-servers — 5,300+ stars curated list

---

## 5. What the Community Has Converged On

### Architectural patterns that won

| Pattern | What won | Why |
|---|---|---|
| **Orchestration model** | Graph-based state machines (LangGraph) | Debuggable, checkpointable, deterministic replay — implicit agent chat didn't scale |
| **Agent definition format** | YAML frontmatter + markdown body | Used by Claude Code, oh-my-pi, GitHub Copilot, BMAD, and AGENTS.md spec |
| **Memory architecture** | Hierarchical: working → episodic → semantic → long-term | MemOS and MIRIX both converged here; mirrors human memory |
| **Handoff protocol** | Shared mutable state object + routing edges | LangGraph pattern — no formal wire standard yet, but this is winning |
| **Tool access** | Per-agent allowlist | Every framework scopes tools per role |
| **Skills format** | Markdown SOPs | Fabric (70k stars), BMAD, AGENTS.md spec all confirm this |

### Emerging standard: AGENTS.md
The Linux Foundation is standardizing `.agent` YAML/Markdown format: https://agents.md/
Your CLAUDE.md + skills approach is aligned with where this is heading.

### Your AIOS bets that are validated
- Markdown SOPs as skills ✅ (Fabric, AGENTS.md, BMAD all confirm)
- Session memory as first-class ✅ (every major framework added this in 2024-2025)
- Dispatcher pattern ✅ (mirrors LangGraph conditional edges)
- File-driven, no compiled code ✅ (PAI is the only comparable system — differentiated)

### Your AIOS gaps vs. community
- **No structured handoff protocol** — agents pass context implicitly; BMAD and LangGraph use explicit deliverables + state objects
- **No per-agent tool allowlist** — your skills don't declare which tools they need; oh-my-pi and CrewAI both do this
- **No agent memory scoping** — all agents share the same memory; MIRIX assigns memory types to dedicated agents
- **skill-navigator is fragile** — community solved this with graph routing (LangGraph) or role-based dispatch (CrewAI), not per-turn SOP scanning

---

## 6. Research Gaps (Complete Next Session)

These 3 agents hit usage limits — pick up when ready:

- [ ] **BMAD deep-dive** — full agent config format, checklists, handoff protocol, community forks
- [ ] **Agent config standards comparison** — CrewAI vs AutoGen vs LangGraph vs MetaGPT config formats side-by-side; AgentCard and Agent2Agent protocol status
- [ ] **BMAD-adjacent projects** — full list of BMAD-inspired repos, Claude/Cursor rule ecosystems, agent persona sharing communities

---

## 7. Recommended Starting Points When You Resume

1. **Read first:** https://github.com/bmadcode/BMAD-METHOD — most directly applicable to your agent taxonomy work
2. **Read second:** https://github.com/danielmiessler/Personal_AI_Infrastructure — closest architectural twin
3. **Install first:** Serena MCP (`pip install serena && serena mcp`) — biggest immediate upgrade to any dev agent
4. **Reference:** https://agents.md — emerging standard your skills should align with
5. **Then:** Come back to the agent taxonomy design with the skills inventory + this research doc as inputs
