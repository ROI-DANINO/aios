# Agentic Dev Community Research — 2026-03-30
> Context for AIOS agent taxonomy design. Compiled from 6 research agents. Complete as of 2026-03-30.

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

## 2. BMAD Method — Full Deep-Dive

**GitHub:** https://github.com/bmad-code-org/BMAD-METHOD — ~42,900 stars, ~5,200 forks, v6.0.0-alpha
**Docs:** https://docs.bmad-method.org | Active Discord + YouTube channel

The dominant reference point in the agentic dev team space. Every other methodology is measured against it.

### Agent Roles (BMM Module — 9 Core + 1 Master)

| Agent | Persona | Owns | Deliverable |
|---|---|---|---|
| **Analyst** | Mary | Research, brainstorming, product strategy | `brainstorming-report.md`, `product-brief.md` |
| **PM** | John | Requirements, epic/story ownership | `PRD.md`, `epics/*.md` |
| **Architect** | Winston | Tech decisions, ADRs, system design | `architecture.md` |
| **UX Designer** | Sally | User flows, wireframes, interaction design | `ux-spec.md` |
| **Scrum Master** | Bob | Sprint coordination, story prep, readiness gating | `sprint-status.yaml`, story queue |
| **Developer** | Amelia | Story implementation, TDD cycle | Working code + 100% passing tests |
| **QA** | Quinn | Test automation strategy | Automated test suites |
| **Tech Writer** | Paige | Documentation, diagrams | Technical docs, visuals |
| **Quick Flow Dev** | Barry | Fast spec-to-code for small projects | `tech-spec.md` + implementation |
| **BMad Master** | Master | Universal guidance, workflow navigation | Recommendations, next-step suggestions |

**Key principle:** Agents are facilitators, not generators — they ask questions, load context, and guide rather than auto-generate.

### Agent Config Format (`.agent.yaml` → compiled to `.md`)

```yaml
metadata:
  id: _bmad/bmm/agents/dev.md
  name: Amelia
  title: Developer Agent
  icon: 👨‍💻
  module: bmm
  capabilities: [story-execution, TDD]
  hasSidecar: true               # persistent memory flag

persona:
  role: Senior Software Engineer
  identity: Strict story adherence
  communication_style: Ultra-succinct
  principles:
    - 100% test passing before story complete
    - Never lie about test status

menu:
  - trigger: DS                  # user types this to invoke
    exec: dev-story              # workflow to run
    description: Implement story

critical_actions:
  - READ entire story first
  - Execute tasks IN ORDER
  - NEVER lie about test status
```

The compiled `.md` body has: persona section → XML activation block → 9-step protocol (load persona → load config → greet → display menu → **HALT and WAIT**) → supporting guidelines.

### Handoff Protocol

Agents **never communicate directly**. All handoff is artifact-driven:

```
Analyst   → product-brief.md
PM        → PRD.md + ux-spec.md
Architect → architecture.md
SM        → story-{slug}.md  (hyper-detailed: AC, project rules, prior stories)
Dev       → working code + tests
QA/Review → merge-ready or findings
```

**Quality gates block progression** — `check-implementation-readiness` validates all three artifacts (PRD + arch + epics) align before dev starts. FAIL = return to Phase 3, no bypass.

Every workflow ends writing `_bmad-output/step-XX-complete.md` and auto-invoking `bmad-help` to surface the next step.

### Full Workflow

**Quick Flow (1–15 stories):**
```
/bmad-barry → quick-spec → tech-spec.md → quick-dev → working code
```

**Full BMM Track (10–50+ stories):**
```
PHASE 1 — Analysis (optional)
  /bmad-analyst → brainstorming + domain-research + create-product-brief

PHASE 2 — Requirements (required)
  /bmad-pm      → create-prd
  /bmad-ux      → create-ux-design

PHASE 3 — Solutioning (required)
  /bmad-arch    → create-architecture
  /bmad-pm      → create-epics-and-stories
  /bmad-arch    → check-implementation-readiness  ← GATE

PHASE 4 — Implementation (repeat per story)
  /bmad-sm      → sprint-planning (once)
  For each story:
    /bmad-sm    → create-story
    /bmad-dev   → dev-story (TDD cycle)
    /bmad-dev   → code-review
  /bmad-sm      → retrospective
```

### Claude Code Integration

BMAD uses Claude Code's native Skills API — no CLAUDE.md required.
- Installs to `.claude/skills/bmad-{name}/SKILL.md`
- Slash commands: `/bmad-dev`, `/bmad-pm`, `/bmad-create-prd`, `/bmad-help`

### Notable Community Forks

| Repo | Stars | What's different |
|---|---|---|
| [aj-geddes/claude-code-bmad-skills](https://github.com/aj-geddes/claude-code-bmad-skills) | ~358 | 70–85% token reduction, no npm deps, project complexity levels 0–4, YAML status tracking |
| [24601/BMAD-AT-CLAUDE](https://github.com/24601/BMAD-AT-CLAUDE) | — | Direct BMAD port to Claude Code slash commands |
| [robertguss/bmad_automated](https://github.com/robertguss/bmad_automated) | ~69 | CLI tool automating BMAD workflows |
| [ibadmore/bmad-progress-dashboard](https://github.com/ibadmore/bmad-progress-dashboard) | ~59 | Terminal progress tracker |

---

## 3. Comparable Methodologies

### SPARC — ruvnet/rUv-dev (~425 stars)

**What it is:** Specification → Pseudocode → Architecture → Refinement → Completion — 17 specialized modes dispatched by an Orchestrator agent. Each subtask runs in isolated context; returns summary to parent.

**Key modes:** Orchestrator, Spec Writer, Architect, Auto-Coder, TDD, Debug, Security Reviewer, Documentation Writer, System Integrator, DevOps, MCP Integration

**CLAUDE.md pattern:** SPARC uses a **living CLAUDE.md as persistent spec** — requirements, prior outputs, and project conventions accumulate there across sessions. Central to cross-session memory.

**Roo Code integration:** Built into Roo Code's official Boomerang/Orchestrator Mode. Child tasks run with their own conversation history; orchestrator stays uncluttered.

**vs. BMAD:** Mode-switching within one tool vs. distinct named persona agents. Phase-focused pipeline vs. team-focused org chart.

### RIPER-5 — Community (Cursor forum → ported to Claude Code)

**What it is:** Single-agent discipline protocol — Research → Innovate → Plan → Execute → Review. Agent must declare its current mode at the top of every response.

**Mode rules:**
- RESEARCH — read files only; no suggestions permitted
- INNOVATE — brainstorm as possibilities only; no decisions
- PLAN — exhaustive spec; no implementation
- EXECUTE — implement exactly the plan; zero deviations
- REVIEW — line-by-line comparison vs. plan; flag any deviations

**vs. BMAD:** Not multi-agent. A single-agent discipline layer to prevent premature implementation and undocumented decisions. Lightest of the three — inject via system prompt.

---

## 4. BMAD-Adjacent Projects — Space Map

### Tier 1: Named Role + Full SOP Workflows

| Project | Stars | Format | Key roles |
|---|---|---|---|
| [bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) | 42.9k | `.agent.yaml` + `.md` | PM, Architect, Dev, QA, UX, SM, Analyst, Writer |
| [ruvnet/rUv-dev](https://github.com/ruvnet/rUv-dev) | 425 | `.roomodes` JSON + `.roo/mcp.json` | 15+ SPARC modes with file permission scoping |
| [valllabh/claude-agents](https://github.com/valllabh/claude-agents) | 19 | Markdown → `~/.claude/agents/` | 8 named personas matching full agile team |
| [mthalman/agent-personas](https://github.com/mthalman/agent-personas) | 2 | Markdown in `/personas/` | 21 personas incl. Persona Architect (meta) |

### Tier 2: Claude Code Subagent Collections

| Project | Stars | What it is |
|---|---|---|
| [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) | 15.7k | 127+ agents across 10 categories — installs to `.claude/agents/` |
| [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) | 23.8k | 600+ agents via `npx claude-code-templates` — aggregates community collections |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | 34.4k | Canonical awesome-list — agents, hooks, slash commands, CLAUDE.md templates |

### Tier 3: Agent OS / Orchestration Infrastructure

| Project | Stars | Why relevant |
|---|---|---|
| [intertwine/hive-orchestrator](https://github.com/intertwine/hive-orchestrator) | 16 | Git-native, markdown-as-state OS — `.hive/tasks/*.md`, `GLOBAL.md`, `PROGRAM.md`. Closest to how AIOS uses `data/` and `memory/` |
| [strands-agents/agent-sop](https://github.com/strands-agents/agent-sop) | 859 | AWS Strands: SOPs as markdown with RFC 2119 (MUST/SHOULD/MAY) + JSON MCP config |
| [steipete/agent-rules](https://github.com/steipete/agent-rules) | 5.7k (archived) | Popularized global vs project-scoped rule sets — maps to AIOS `context/` + `skills/` split |

### Cursor/Other IDE Ecosystems

| Project | Stars | What it is |
|---|---|---|
| [PatrickJS/awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) | 38.8k | Framework coding-style rules as `.cursorrules` files — same primitive (drop file, change behavior) |
| [BuildSomethingAI/cursor-custom-agents-rules-generator](https://github.com/BuildSomethingAI/cursor-custom-agents-rules-generator) | Early | Cursor-native BMAD equivalent: `.mdc` rules + `.cursor/modes.json` |

### Three Patterns in This Space

| Pattern | Examples | How it works |
|---|---|---|
| **Role-first** | BMAD, valllabh | Named agent files (PM, Architect, Dev, QA). Workflow = sequence of agent handoffs. Your `skills/` is already this pattern. |
| **Phase-first** | SPARC, rUv-dev | Phases of work (Spec→Arch→Code→Review). Agents attached to phases. Closer to pipeline than team. |
| **State-first** | hive-orchestrator, AIOS | Repo IS the memory. Tasks are markdown files. Agents read/write shared state. Closest to how AIOS uses `data/` today. |

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

## 6. Agent Config Standards — Cross-Framework Comparison

### Minimal portable agent definition (works across all frameworks)

```yaml
name: string           # unique identifier
description: string    # when/why to use (routing signal)
model: string          # model id or alias
tools: [string]        # allowlist of tool names
system_prompt: string  # behavioral instructions
memory: bool | scope   # whether to persist cross-session
```

Everything else is framework-specific enrichment on top of this core.

### Side-by-side field comparison

| Field | CrewAI | AutoGen/AG2 | LangGraph | MetaGPT | Claude Subagents | A2A AgentCard |
|---|---|---|---|---|---|---|
| Identity | `role` | `name` | node name | `name` + `profile` | `name` (frontmatter) | `name` |
| Purpose | `goal` | `system_message` | node docstring | `goal` | `description` | `description` |
| Persona | `backstory` | `system_message` | prompt in node | `profile` + `constraints` | MD body | — |
| Model | `llm` | `llm_config` dict | `ChatOpenAI(model=...)` | config file | `model` (frontmatter) | — |
| Tool access | `tools=[...]` per agent | `register_for_llm` per agent | `llm.bind_tools([...])` | `set_actions([...])` | `tools:` allowlist | `skills:[...]` |
| Tool deny | — | — | — | — | `disallowedTools:` | — |
| Memory | `knowledge_sources` | external only | state TypedDict | `get_memories()` | `memory: user/project/local` | — |
| Permissions | `allow_delegation` | `human_input_mode` | conditional edges | message routing | `permissionMode:` | `securitySchemes:` |
| Turn limit | `max_iter` | `max_consecutive_auto_reply` | graph loop design | — | `maxTurns:` | — |
| Delegation | `allow_delegation=True` | multi-agent chat | edge routing | `_watch` subscriptions | `Agent(name)` in tools | task routing |
| Hooks | `step_callback` | — | custom nodes | — | `hooks: PreToolUse/PostToolUse` | — |
| I/O schema | — | type annotations | TypedDict state | — | — | `skills[].inputSchema/outputSchema` |

### What's universal vs. framework-specific

**Universal:** name, purpose/description, tool access, model spec

**Claude-only (most granular permission model):** `permissionMode`, `isolation`, `disallowedTools`, `mcpServers`, `hooks`, `memory` scope

**A2A-only (interop focused):** `securitySchemes`, `capabilities.streaming`, `url`, I/O JSON schemas

### Claude Code subagent full format

```markdown
---
name: code-reviewer
description: >
  Reviews code for quality and security. Use proactively after code changes.
tools: Read, Grep, Glob, Bash
disallowedTools: Write, Edit
model: sonnet
permissionMode: default
maxTurns: 20
memory: project
skills:
  - api-conventions
mcpServers:
  - github
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate.sh"
isolation: worktree
---

You are a senior code reviewer...
```

### A2A AgentCard (discovery format — served at `/.well-known/agent-card.json`)

```json
{
  "name": "Currency Exchange Agent",
  "description": "Converts currencies using live exchange rates",
  "url": "https://agent.example.com",
  "version": "1.0.0",
  "capabilities": { "streaming": true },
  "skills": [{
    "id": "convert-currency",
    "name": "Convert Currency",
    "inputSchema": { "type": "object", "properties": { "amount": {"type": "number"} } },
    "outputSchema": { "type": "object", "properties": { "result": {"type": "number"} } }
  }]
}
```

JSON-RPC 2.0 over HTTP(S). 50+ partners including LangChain, Salesforce, SAP. Agents advertise capabilities; orchestrators discover and route. Linux Foundation stewardship (alongside AGENTS.md).

### AGENTS.md — intentionally freeform

No required fields. Recommended sections: project overview, dev environment, build/test commands, code style, git workflow, agent boundaries, architecture. Your existing `AGENTS.md` already follows this well.

---

## 7. Your AIOS Gaps vs. Community (Updated)

| Gap | Community solution | What to build |
|---|---|---|
| No structured handoff | BMAD artifact files, LangGraph state objects | Each skill/agent declares its output deliverable |
| No per-agent tool allowlist | Every framework does this | Add `tools:` frontmatter to agent definitions |
| No agent memory scoping | MIRIX: one agent per memory type | Consider dedicated session/memory agent |
| skill-navigator is fragile | LangGraph graph routing, CrewAI role dispatch | Replace with explicit agent routing table |
| No complexity detection | BMAD Barry (quick flow) vs. full track | Add project sizing to `dev-audit` |
| No done checklists | BMAD `check-implementation-readiness` gate | Add explicit AC + done criteria to stories |

---

## 8. Recommended Starting Points When You Resume

1. **Read:** https://github.com/bmad-code-org/BMAD-METHOD — install the Claude Code skills fork: https://github.com/aj-geddes/claude-code-bmad-skills
2. **Read:** https://github.com/danielmiessler/Personal_AI_Infrastructure — closest architectural twin to AIOS
3. **Browse:** https://github.com/VoltAgent/awesome-claude-code-subagents — 127 ready-made subagent definitions, 10 categories
4. **Browse:** https://github.com/hesreallyhim/awesome-claude-code — canonical index for all Claude Code agent patterns
5. **Install:** Serena MCP — `pip install serena && serena mcp` — biggest immediate dev agent upgrade
6. **Reference:** https://agents.md — Linux Foundation standard your agent definitions should align with
7. **Then:** Sit down with `skills-inventory-2026-03-30.md` + this doc and design your agent teams
