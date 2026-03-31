---
name: Pi Agent Integration Decision
description: oh-my-pi chosen as primary engine alongside Claude Code; approach and stack decided
type: project
---

oh-my-pi (github.com/can1357/oh-my-pi) is being integrated as the primary execution engine alongside Claude Code. Hermes stays as an option.

**Approach B chosen:** oh-my-pi runs standalone, Claude Code plugs in via AIOS skills starting with `pi --print` delegation, upgrading to `pi --mode rpc`, then Overstory for full mixed-runtime teams.

**OSS stack for oh-my-pi capabilities:**
- Memory: Engram (MCP-native, SQLite+FTS5)
- Tools: modelcontextprotocol/servers (40+, MCP-native)
- Self-improvement: AutoSkill (shell bridge needed)
- Multi-platform: LangBot

**Key integration facts:**
- oh-my-pi exposes JSON-RPC 2.0 over stdin/stdout via `pi --mode rpc`
- One-shot invocation: `pi --print "<task>"`
- Overstory coordinates Pi + Claude Code in mixed teams with shared SQLite mail + git worktrees
- Pi reads AGENTS.md; Claude Code reads CLAUDE.md — both can coexist in same project

**Why:** Wanted all three agents (Claude Code, Hermes, Pi) doing what they do best as a codependent system. Pi handles multi-model/parallel implementation, Hermes handles persistent memory + heavy tools, Claude Code orchestrates.

**Messaging layer decisions (2026-03-31):**
- **CC↔CC:** `claude-peers-mcp` — MCP server for Claude Code to Claude Code communication
- **Pi+Claude:** Overstory — coordinates Pi + Claude Code in mixed teams (shared SQLite mail + git worktrees)
- **TUI:** Conduit — terminal UI layer for the system
- **Agent-MCP:** explicitly rejected

**Branch:** `feature/pi-agent-integration`

**How to apply:** When designing the tri-agent system spec, refer to this decision. Don't reopen the approach question — Approach B is locked.
