---
name: Subagents must end with session-close
description: Dispatch prompts for implementation subagents must instruct them to run /session-close at the end of their work
type: feedback
---

Subagents dispatched via subagent-driven-development (or any dispatch pattern) must always end their session by running the `/session-close` skill so their work gets logged in `data/session-log-*.md`.

**Why:** Without this, there's no record of what the subagent actually did. The main session can't distinguish "work was pre-existing" from "subagent did it this session." This makes audit and retrospective unreliable.

**How to apply:** In every implementer subagent prompt, add a final step: "After committing your work, run the session-close skill to log what you did." Include context like the task name and session date so the log entry is meaningful.
