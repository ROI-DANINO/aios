---
name: tool-registry
description: >
  Read-only catalog of which tools each AIOS agent role can use. Shows tool allowlists
  for all 8 agents and a reference table of what each Claude Code tool does.
  Use when user says "/tool-registry", "what tools does X agent have", "can X agent do Y", "show tool allowlists".
user-invocable: true
argument-hint: '[<agent-name>]'
tools:
  - Read
  - Glob
---

# Tool Registry

Which agent can do what. Read-only reference.

## When to Trigger

- User types `/tool-registry`
- User asks "what tools does X agent have", "can X agent do Y", "show tool allowlists"
- When designing a new agent and need to reference standard patterns
- When debugging why an agent can't perform a certain action

## Process

### No argument — show full allowlist table

Display the standard AIOS agent tool allowlist:

| Agent | Tools |
|-------|-------|
| **Analyst** | Read, Glob, Grep, WebSearch, WebFetch |
| **PM** | Read, Write, Edit, Glob, Grep |
| **Architect** | Read, Write, Edit, Glob, Grep, Bash |
| **Developer** | Read, Write, Edit, Bash, Glob, Grep |
| **QA** | Read, Bash, Glob, Grep |
| **Scrum Master** | Read, Write, Edit, Glob |
| **Session Agent** | Read, Write, Edit, Glob, Grep |
| **Health Agent** | Read, Glob, Grep, Bash |

Then show the Claude Code tool reference table:

| Tool | What it does |
|------|-------------|
| `Read` | Read file contents from the filesystem |
| `Write` | Write or overwrite a file |
| `Edit` | Make targeted string replacements in a file |
| `Bash` | Execute shell commands |
| `Glob` | Find files matching a pattern |
| `Grep` | Search file contents with regex |
| `WebSearch` | Search the web |
| `WebFetch` | Fetch contents of a URL |
| `Agent` | Spawn a subagent for a parallel or delegated task |

### With argument — inspect specific agent

1. Read `.claude/agents/<agent-name>.md`.
2. Extract and display the `tools:` frontmatter.
3. Note any tools present that differ from the standard allowlist above.
4. If agent file not found: list available agent files and ask which they meant.

## Notes

- This skill is **read-only** — it never modifies agent files.
- To edit an agent's tools, use `/agent-config edit <name>`.
- The standard allowlist is a reference baseline. Actual agent files may differ — always check the file for ground truth.

## See Also

- `/agent-config` — view, edit, or add agent definitions
- `/session-health` — confirms all 8 agents are present
- `/aios-health` — full system audit including agent validation
