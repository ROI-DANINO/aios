---
name: session-close behavior preference
description: Roi does not want session-close to ask questions — derive from context, accept optional note
type: feedback
---

Don't ask questions at session close. Derive what happened from conversation history and git log. Accept an optional note argument for anything the user wants to add manually.

**Why:** Asking three questions at the end of every session is friction. The session context is already available — use it.

**How to apply:** `/session-close` runs silently and infers. If user passes an argument (e.g. `/session-close fixed the auth bug`), include it as a note. Never prompt for Q&A at close.
