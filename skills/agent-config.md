---
name: agent-config
description: >
  Manage AIOS agent definitions in .claude/agents/ — view roster, inspect individual agents,
  edit an agent, or add a new one via guided wizard. Use when user says "/agent-config",
  "show me the agents", "add a new agent", "update agent permissions", "what agents do I have".
user-invocable: true
argument-hint: '[view <agent-name> | edit <agent-name> | add]'
tools:
  - Read
  - Write
  - Edit
  - Glob
---

# Agent Config

View, edit, or add AIOS agent definitions.

## When to Trigger

- User types `/agent-config` with no argument — show roster
- User types `/agent-config view <name>` — show full agent file
- User types `/agent-config edit <name>` — guided edit
- User types `/agent-config add` — guided wizard to create new agent
- User says "show me the agents", "add a new agent", "update agent permissions", "what agents do I have"

## Process

### No argument — roster

1. Glob `.claude/agents/*.md` to get all agent files.
2. For each file, read the frontmatter (name, model, permissionMode, tools list).
3. Output a summary table:

```
| Agent | Model | permissionMode | Tools |
|-------|-------|----------------|-------|
| ...   | ...   | ...            | N     |
```

4. End with: "Run `/agent-config view <name>` to inspect any agent."

### `view <agent-name>`

1. Locate `.claude/agents/<agent-name>.md`. If not found, try fuzzy match (partial name).
2. Read and display the full file contents.
3. No edits — read-only mode.

### `edit <agent-name>`

1. Read the agent file.
2. Show current state. Ask: "What would you like to change? (description, tools, permissionMode, model)"
3. Apply the requested change using Edit tool.
4. Confirm: "Updated. Run `/agent-config view <name>` to verify."

### `add` — wizard

Ask these questions in sequence (one at a time):

1. **Name:** "What should this agent be called? (slug, e.g. `planner`)"
2. **Description:** "One sentence — what does this agent do?"
3. **Model:** "Which model? (default: claude-sonnet-4-5, or specify)"
4. **permissionMode:** "Permission mode? `default` or `bypassPermissions`"
5. **Tools:** "Which tools should it have access to? (e.g. Read, Glob, Bash — or 'all')"
6. **Responsibilities:** "List 2-3 core responsibilities for this agent."

Then write `.claude/agents/<name>.md` with standard frontmatter format:

```markdown
---
name: <name>
description: <description>
model: <model>
permissionMode: <permissionMode>
tools:
  - <tool1>
  - <tool2>
---

# <Name> Agent

<description>

## Responsibilities

- <responsibility 1>
- <responsibility 2>
- <responsibility 3>
```

Confirm: "Agent `<name>` created at `.claude/agents/<name>.md`."

## Edge Cases

- **Agent not found** — List available agents and ask which they meant.
- **Name collision on add** — Show existing file, ask: "This agent already exists. Edit instead?"
- **No agents dir** — Warn: "`.claude/agents/` not found. Is this a fresh AIOS install?"

## See Also

- `/tool-registry` — read-only catalog of tools per agent role
- `/aios-health` — full system audit including agent roster check
- `/session-health` — quick agent presence check
