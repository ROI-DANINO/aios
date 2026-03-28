# AIOS Foundation Design
Date: 2026-03-29

## Overview

A dev-first AI Operating System for a hobbyist coder going pro. The system acts as a professional co-pilot — handling discipline, structure, and blind spots so the user can stay focused on creativity. Built on Claude Code CLI with a Paperclip web UI layer added after the foundation is solid.

**Primary focus:** Operations + Second Brain (Pod 1)
**User profile:** Comfortable following instructions, relies on Claude for execution, directs the work

---

## 1. Folder Structure

```
aios/
├── claude.md                  ← System handbook (identity, rules, directives)
├── .env                       ← API keys (never committed to git)
├── .gitignore                 ← Protects .env, .tmp/, data/*.db
├── context/
│   ├── my-business.md         ← Who the user is, what they're building
│   ├── my-voice.md            ← Communication style and tone
│   └── my-goals.md            ← 90-day priorities + long-term vision
├── skills/
│   ├── business-setup.md      ← Onboarding wizard
│   ├── pod-mapper.md          ← Workflow audit tool
│   └── system-architect.md   ← Architecture brief template
├── deliverables/              ← Outputs: plans, reports, pod maps
├── data/                      ← Databases, logs, structured data
├── memory/                    ← MEMORY.md + individual memory files
├── docs/
│   └── superpowers/specs/     ← Design docs
└── .tmp/                      ← Scratch space
```

---

## 2. claude.md Contents

1. **Identity** — Co-pilot for a hobbyist coder going pro. Creativity is the user's job; discipline and structure are Claude's job.
2. **Directives** — Step-by-step always. Explain as we go. Check in before writing large amounts of code or moving to the next stage.
3. **Workflow rules** — Always follow Superpowers skills: brainstorm → writing-plans → TDD → code review → finishing branch.
4. **Context files** — Read `context/` at session start for business profile, voice, and goals.
5. **Skills index** — List of available skills and when to use each.
6. **Security rules** — Never send, delete, or write to external systems without explicit user approval. All destructive/external actions require a confirm step.
7. **Pod structure** — Pod 1 is Operations + Second Brain. Paperclip web UI is the next layer after foundation is stable.

---

## 3. Skills

Three skills installed at launch, callable as slash commands:

| Skill | Command | Purpose |
|---|---|---|
| business-setup | `/business-setup` | Onboarding wizard — fills all context files in one conversation |
| pod-mapper | `/pod-mapper` | Maps any business function into automatable workflow steps |
| system-architect | `/system-architect` | Walks through architecture decisions and produces a brief |

Additional skills added as needed (daily brief, second brain capture, dev loop).

---

## 4. Context Files

Created as empty placeholders at setup. Filled by running `/business-setup` as the first action after initialization.

- `context/my-business.md` — business description, stage, current challenge
- `context/my-voice.md` — communication style, sample text, anti-patterns
- `context/my-goals.md` — 90-day priorities, long-term vision (going pro)

---

## 5. Git + Security

- Git initialized at project root
- `.gitignore` covers `.env`, `.tmp/`, `data/*.db`
- `.env` created with placeholder API keys
- Hard security rule in `claude.md`: no send/delete/write to external systems without explicit approval

---

## 6. Build Order

1. Initialize git repo
2. Create folder structure
3. Write `claude.md`
4. Create `.env` and `.gitignore`
5. Copy skills into `skills/`
6. Create placeholder context files
7. First commit
8. Run `/business-setup` to fill context files
9. Run `/pod-mapper` for Operations pod
10. Install Paperclip (next phase)

---

## Next Phase: Paperclip

After foundation is stable and context files are filled, install Paperclip as the web UI layer. It connects to this workspace and provides a visual dashboard for running skills, managing agents, and tracking work.
