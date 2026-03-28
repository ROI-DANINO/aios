# AIOS Architecture Brief Template

> Paste this into Claude alongside your AI operating system. It will walk through each section, ask you questions about your specific setup, and produce a complete architecture brief for your system.
>
> Instruction to Claude: "Read this template and walk me through each section one at a time. Ask me questions about my specific system, then fill in the brief as we go. Save the completed brief when we're done."

---

## Section 1: Dependency Map

Map every component in your AIOS and what it depends on. For each dependency, document what happens if it goes down and your fallback strategy.

| Component | Depends On | If It Goes Down | Fallback Strategy |
|---|---|---|---|
| All skills | Anthropic (Claude) | Everything stops | Skills are human-readable SOPs — execute manually. Or route to Codex/Gemini via hook-based model switching |
| MCP connections | Individual service APIs | Specific integrations break silently | Fall back to direct API calls via scripts. Claude often does this automatically if .env has the API key |
| Scheduled tasks | Desktop app / cron / n8n | Tasks don't fire | Missed run catch-up on wake (Cowork). Manual trigger as backup. Set alerts for missed schedules |
| Memory system | mem0 + vector DB / Cowork native | Context lost between sessions | MEMORY.md file is local backup. Cowork Projects memory is automatic. Daily logs capture session history |
| Context files | Local filesystem | Claude loses business context | Cloud sync (Dropbox/GitHub) restores files. Context is static — easy to recreate from backup |
| Databases | SQLite (local) / Supabase (cloud) | Data loss or corruption | Supabase has built-in backups. SQLite needs manual backup to cloud. Run integrity checks via health check skill |
| Your machine | Hardware + OS | Complete system loss | Cloud backup of entire workspace. Credentials in password manager. Can restore to new machine in hours |

**Questions Claude should ask you:**
- What skills do you have running? List them.
- Which MCP connections are active?
- What databases are you using (local SQLite, Supabase, other)?
- Do you have cloud backup configured? What service?
- Where are your credentials stored?

---

## Section 2: Integration Architecture

For every external system your AIOS connects to, document HOW it connects and WHY that method was chosen.

### Integration Decision Matrix

| System | Connection Method | Why This Method | Permissions |
|---|---|---|---|
| Gmail | MCP | Claude needs judgment to triage emails — which ones matter | Read-only unless drafting |
| CRM (e.g. HubSpot) | Hybrid — Script for pipeline pushes, MCP for ad-hoc queries | Pipeline is repetitive (script saves tokens). Research is dynamic (needs Claude reasoning) | Read + write for pipeline, read-only for research |
| Apollo | MCP | Lead search requires dynamic query building | Read-only for search, write for list management |
| Supabase | Script (direct API) | Database queries are deterministic — no AI judgment needed | Read + write |
| YouTube Analytics | MCP | Claude interprets metrics and surfaces insights | Read-only |
| Stripe / Xero | MCP (read-only) | Financial data should never be writable by AI | Read-only. Block all write/delete operations |
| Firecrawl | MCP | Web scraping requires dynamic URL handling | N/A |
| Perplexity | MCP | Research queries are dynamic | N/A |

### Three connection methods — when to use each:

**MCP** — Use when Claude needs to reason about the data (email triage, lead research, metric interpretation). Trade-offs: token bloat, added latency, can fail silently (returns 200 OK but fails behind the header).

**Python scripts (direct API)** — Use when the task is the same every time (push data to CRM, pull database records, format reports). Trade-offs: requires API key management, but zero token cost and fully deterministic.

**Webhooks / triggers** — Use for event-driven reactions (new email arrives, call recording ready, deployment completes). Trade-offs: requires setup, can invoke costs if firing frequently.

**Rule of thumb:** If Claude doesn't need to think about it, use a script. If Claude needs to make a judgment call, use MCP. If something external needs to trigger your system, use a webhook.

**Questions Claude should ask you:**
- What external systems does your AIOS connect to?
- For each one, does Claude need to reason about the data or just move it?
- Which systems should be read-only vs read-write?
- Are there any event-driven workflows (things that need to trigger when something happens externally)?

---

## Section 3: Memory and Data Architecture

Document what type of memory your system needs and where data lives.

### Memory Tiers

| Tier | What It Stores | Where It Lives | Who Needs It |
|---|---|---|---|
| MEMORY.md / Cowork Projects memory | Curated facts, preferences, goals | Local file / Cowork native | Everyone — basic session continuity |
| Daily logs | Session events, decisions, completed tasks | Local files or Supabase | Users who want session history across days |
| Vector database (Pinecone, Supabase pgvector, Obsidian Bases) | Semantic facts, auto-extracted from conversations | Cloud (Pinecone/Supabase) or local (SQLite-vec, Obsidian) | Power users with large context needs |
| SQLite | Structured data (tasks, leads, metrics) | Local file | Systems that need queryable data |

### Decision guide:

- **Solo user, simple workflows** → Cowork Projects memory + MEMORY.md is enough. Don't overbuild.
- **Solo user, complex workflows with lots of context** → Add daily logs + Supabase for offsite storage
- **Consultant building for clients** → Keep it simple. Cowork memory or MEMORY.md. Only add vector DB if the client genuinely needs semantic recall across hundreds of sessions.
- **If you don't know** → Start with the simplest option. Add complexity only when you hit a wall.

**Questions Claude should ask you:**
- How many sessions per day do you have with your AIOS?
- Do you need it to remember things from weeks/months ago, or is recent context enough?
- Do you have any structured data needs (leads database, task tracking, metrics)?
- Are you comfortable with cloud storage (Supabase, Pinecone) or do you need everything local?

---

## Section 4: Security and Data Flow

Document where your data goes, what's at risk, and how you've mitigated it.

### Data Flow Audit

| Data Type | Where It Goes | Risk Level | Mitigation |
|---|---|---|---|
| Conversations with Claude | Anthropic servers (processed, not trained on with business account) | Medium | Use business account. Filter sensitive data before sending. |
| Email content (via MCP/API) | Through Anthropic for analysis | Medium-High | Filter PII if needed. Understand NDA implications. |
| Lead data (Apollo) | Apollo servers + Anthropic for research | Medium | Apollo sells data — check if client needs to opt out. GDPR considerations for EU leads. |
| Financial data (Stripe/Xero) | Through Anthropic if using MCP | High | Read-only MCP only. Never give write access. Consider local model for sensitive financial analysis. |
| API keys / credentials | .env file (local) | Critical | .gitignore prevents pushing to Git. Store backup in password manager. Never log to daily logs or MEMORY.md. |
| Client NDA material | Risk of going through Anthropic | High | Filter before processing. Consider local model for NDA-covered analysis. Anonymise where possible. |

### Hooks vs Rules — Security Enforcement

| Security Need | Rule (best effort) | Hook (enforced) | Recommendation |
|---|---|---|---|
| Don't delete production data | "Never delete without asking" in CLAUDE.md | PreToolUse hook blocks `rm -rf` on specific paths | **Use hook** — deletion is irreversible |
| Don't expose API keys | "Never show API keys" in rules | Stop hook sanitises output before displaying | **Use hook** — credential exposure is critical |
| Don't push .env to Git | .gitignore file | PreToolUse hook blocks `git add .env` | **Use both** — belt and suspenders |
| Don't send emails without approval | "Always ask before sending" in CLAUDE.md | Rule is fine here — low risk if it occasionally asks | **Use rule** — the consequence of sending without asking is low |
| Don't write to financial systems | MCP permission set to read-only | Block toggle in MCP connector settings | **Use MCP permissions** — enforced at the connector level |

### Credential Management

- `.env` file holds all API keys — never committed to Git (.gitignore)
- `.claudeignore` prevents Claude from reading files it shouldn't see (though question why those files are in the workspace at all)
- Rotate API keys every 30-90 days. Set reminders. Monitor for silent failures when tokens expire.
- OAuth tokens expire — if MCP can't authenticate but the rest of the chain still runs, you'll get garbage output for days without knowing. Set up monitoring.
- Store credential backups in a password manager (1Password, Bitwarden, etc.) — NOT in the AIOS itself.

### GDPR / Data Privacy Checklist

- [ ] Identified which data passes through Anthropic servers
- [ ] Checked local data privacy laws for client's region
- [ ] Confirmed whether Apollo data selling opt-out is needed
- [ ] Verified NDA compliance — no NDA-covered data sent to external APIs without filtering
- [ ] Set up data anonymisation for sensitive fields (if required)
- [ ] Documented data flow in client-facing architecture brief

**Questions Claude should ask you:**
- What's the most sensitive data in your system?
- Do you work under any NDAs?
- Are any of your clients or leads in the EU (GDPR)?
- What credential management do you currently use?
- Have you set up any hooks for security enforcement?

---

## Section 5: Backup and Recovery

| What | Backup Method | Frequency | Restore Test |
|---|---|---|---|
| Entire workspace folder | Cloud sync (Dropbox/OneDrive with version history) or GitHub | Continuous (Dropbox) or daily (Git push) | Quarterly — restore to fresh folder, verify everything works |
| Databases (SQLite) | Copy to Supabase or cloud storage | Daily | Quarterly — restore and run integrity check |
| Credentials (.env) | Password manager | On change | Verify you can recreate .env from password manager backup |
| MCP configurations | Documented in architecture brief | On change | Verify you can reconfigure all connections from documentation |
| OAuth tokens | Regenerate from source | On expiry (30-90 day rotation) | Monitor for silent auth failures |

**The backup test:** Every quarter, sync your workspace down to a completely new folder. Check that everything runs. If it doesn't, you've found a gap before it matters.

**Questions Claude should ask you:**
- Do you have cloud backup configured right now?
- When was the last time you tested a restore?
- Where are your database backups stored?
- Do you have a credential rotation schedule?

---

## Section 6: Architecture Summary

After completing all sections, Claude should produce a one-page summary:

```
AIOS Architecture Brief — [Business Name]
Date: [date]

DEPENDENCIES: [count] components mapped, [count] with fallback strategies
INTEGRATIONS: [count] external systems, [count] via MCP, [count] via scripts
MEMORY: [tier level] — [description of what's in use]
SECURITY: [count] hooks enforced, [count] rules set, credential rotation every [X] days
BACKUP: [method] with [frequency], last restore test [date]
DATA FLOW: [count] data types audited, [count] with GDPR/privacy considerations

TOP 3 RISKS:
1. [highest risk and mitigation]
2. [second risk and mitigation]
3. [third risk and mitigation]

NEXT ACTIONS:
- [ ] [most important thing to fix/configure]
- [ ] [second priority]
- [ ] [third priority]
```

---

## How to Use This Template

1. Open Claude (Code, Cowork, or chat)
2. Paste this entire template
3. Tell Claude: "Walk me through this section by section for my AIOS. Ask me the questions and build my architecture brief."
4. Claude will ask you about your specific setup, fill in each table, and produce the completed brief
5. Save the output as your architecture document — reference it when building, troubleshooting, or onboarding clients
