---
name: MCP Tool Adoptions
description: Canonical record of all adopted MCP tools and explicit rejections for the AIOS stack
type: project
---

Canonical record of MCP tool decisions for the AIOS + Pi + Hermes stack. Decided 2026-03-31.

**Adopted tools:**

| Tool | Purpose | Notes |
|------|---------|-------|
| `claude-peers-mcp` | CC↔CC messaging | Transport layer for Claude Code to Claude Code communication |
| Overstory | Pi+Claude coordination | Mixed-runtime teams; shared SQLite mail + git worktrees |
| Conduit | TUI | Terminal UI layer |
| `shared-memory-mcp` | Memory bridge (Phase 1) | Replaces manual sync script; verify storage backend before committing |
| `steipete/claude-code-mcp` | Tool access from AIOS (Phase 3) | Replaces hermes-tool.sh wrapper approach |

**Rejected tools:**

| Tool | Reason |
|------|--------|
| Agent-MCP | Explicitly rejected 2026-03-31 |

**Why:** Consolidating these decisions so they don't get re-litigated. Reference here before proposing new MCP tool adoptions.

**How to apply:** Check this file before suggesting a new MCP server or transport layer. If it conflicts with an adopted tool, flag the overlap instead of proposing the alternative.
