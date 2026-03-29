# UX Decisions

Each entry records why a feature exists, who it's for, and how it's used.
Before building anything new, there must be an entry here.

## session-close
- **Added:** 2026-03-29
- **Purpose:** End a session cleanly — document what happened, what's blocked, and what's next so the next session starts with context instead of fog.
- **Who:** Roi, at the end of any working session or topic.
- **How:** Direct trigger (`/session-close`) or natural language ("bye", "done", "wrapping up"). Optional note as argument. Derives context from conversation history and git log — no questions asked. Writes session log and extracts memory.

## dev-audit
- **Added:** 2026-03-29
- **Purpose:** Orient around any project — understand current phase, what's done, what's next, and what's blocking.
- **Who:** Roi, any active project context. Used whenever starting work on a project and needing a status snapshot.
- **How:** User invokes `/dev-audit [path]` when they want to re-orient. Reads PLAN.md, runs tests, checks git log, returns a structured phase report.
