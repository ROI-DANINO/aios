---
name: business-setup
description: >
  AIOS onboarding wizard — one conversation to configure the entire system for your business.
  Captures business identity, voice, offer, ICP, sales process, tools, and goals. Writes all
  context files and routes to the right starting point. Use when context/my-business.md is empty
  or placeholder, user says "set up my business", "configure", "initialize", "start fresh",
  "onboard me", "set up the system", "get me started", or on first use of the AIOS.
user-invocable: true
---

# AIOS Setup

One conversation. Everything the system needs to know about you, your business, and how you operate.

## When to Trigger

- `context/my-business.md` doesn't exist or contains placeholder text
- User says "set up", "configure", "initialize", "get me started", "onboard me"
- First-time use of any skill that needs business context

## Process

Run conversationally — ask a batch, wait for answers, move on. Don't dump all questions at once.

### Phase 1: Your Business

1. What does your business do? (one sentence)
2. Who do you sell to? (industry, company size, job title of the buyer)
3. How long have you been doing this?
4. What's your rough revenue or stage? (Pre-revenue, side hustle, $5K/mo, $50K/mo — whatever's honest. This calibrates the system.)
5. What's your biggest business challenge right now?

### Phase 2: Your Voice

1. How would you describe your communication style? (direct and no-BS, warm and approachable, technical, casual)
2. Paste a message, email, or post you've written that sounds like "you" — something you'd actually send
3. What words or phrases do you use often?
4. What tone do you NEVER want to sound like? (corporate, salesy, overly casual)

### Phase 3: Your Offer

1. Do you have an existing offer or are you building from scratch?
   - If existing: "Paste your offer page, description, or just tell me what you sell, the price, and what they get."
   - If from scratch: "What problem do you solve and for whom? Even a rough idea is fine."
2. What's your price point? (Or where do you think it should be?)
3. Do you have a guarantee? What is it?
4. How many customers/clients do you have right now?

### Phase 4: Your ICP & Lead Gen

1. Do you have a defined ICP (ideal client profile) or still figuring it out?
   - If yes: "Describe them — industry, size, titles, signals that tell you they're a good fit."
   - If no: "That's fine — the offer-engine will help you build one."
2. Where do your leads come from now? (Referrals, LinkedIn, cold outreach, content, ads, nothing yet)
3. What lead gen tools do you use or plan to use? (Apollo, Clay, LinkedIn Sales Nav, or none)
4. Are you doing any outbound right now? If so, what does it look like?

### Phase 5: Your Sales Process

1. What outreach tool do you use or want to use?
   - HeyReach (LinkedIn automation), Instantly (cold email), SmartLead, manual, or none yet
2. How do you close deals?
   - Discovery/sales calls, DM conversations, proposals/SOWs, self-serve, or mix
3. What's your biggest pipeline bottleneck?
   - Not enough leads / leads but no responses / responses but can't close / closing but can't retain / haven't started

### Phase 6: Your Tools & Goals

1. What tools do you use daily? (CRM, email, project management, calendar)
2. Do you create content? If so, what platforms? (LinkedIn, YouTube, blog, newsletter)
3. What tasks drain your energy and you want off your plate?
4. What are your top 3 priorities for the next 90 days?
5. What timezone are you in?

## Scaffold Workspace

Before writing any context files, create the folder structure if it doesn't exist. This ensures the AIOS has a consistent workspace whether running in Claude Code CLI or Cowork.

```bash
mkdir -p context deliverables data .tmp
```

**What each folder does:**
- `context/` — Business identity, voice, ICP, GTM profile. Shared across all skills and projects.
- `deliverables/` — Output space. Proposals, reports, content, diagrams land here.
- `data/` — Databases, logs, intermediate data files.
- `.tmp/` — Scratch space. Nothing important lives here.

### Create `.env` if missing

If `.env` doesn't exist, create it with placeholder API keys so the user knows what's available:

```
# API Keys — fill in what you have, leave blank what you don't
# Skills will tell you when they need a key you haven't set

# Required for outbound research
PERPLEXITY_API_KEY=

# Required for lead research (LinkedIn scraping)
FIRECRAWL_API_KEY=

# Required for Telegram mobile access
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=

# Required for YouTube analytics
# (configured via MCP connector in Cowork — no key needed here)

# Required for email
# (configured via MCP connector in Cowork — no key needed here)

# Optional — for thumbnail generation
GEMINI_API_KEY=

# Optional — for Apollo lead gen
# (configured via MCP connector in Cowork — no key needed here)
```

Tell the user: "Fill in the keys you have. Skills will tell you when they need one you haven't set. In Cowork, most integrations (Gmail, ClickUp, Apollo) use MCP connectors instead of API keys — you'll set those up in the connectors panel."

## Auto-Configure

After collecting all answers:

### 1. Write `context/my-business.md`

Structured business profile from Phase 1. Include: business description, target customer, main offer, lead sources, current challenge, revenue stage.

### 2. Write `context/my-voice.md`

Voice guide from Phase 2. Include: communication style, sample text, characteristic phrases, anti-patterns.

### 3. Write `context/gtm-profile.md`

GTM configuration from Phases 3-5:

```markdown
# GTM Profile

## Current Offer
- **Status:** [Existing / Building from scratch]
- **Description:** [their offer or rough idea]
- **Price:** [price point]
- **Guarantee:** [guarantee or "None yet"]
- **Current customers:** [count]

## ICP
- **Status:** [Defined / Needs building]
- **Description:** [ICP details or "To be built via offer-engine"]
- **Lead sources:** [where leads come from now]

## Tools
- **Lead gen:** [Apollo / Clay / LinkedIn Sales Nav / None]
- **Outreach:** [HeyReach / Instantly / SmartLead / Manual / None]
- **CRM:** [if mentioned]

## Sales Process
- **Close method:** [calls / DMs / proposals / self-serve / mix]
- **Bottleneck:** [their answer]
```

### 4. Write `context/my-icp.md` (if ICP details provided)

```markdown
# ICP — [Business Name]

## Target Company
- Industry: [industries]
- Revenue: [range]
- Employee count: [range]
- Geography: [regions]

## Target Contact
- Titles: [job titles]
- Seniority: [levels]
- Department: [departments]

## Buying Signals
- [signal 1]
- [signal 2]

## Disqualifiers
- [what makes a bad fit]
```

If no ICP yet: create placeholder noting "Run /offer-engine to build this."

### 5. Update `args/preferences.yaml`

Set timezone, content platform preferences.

### 6. Update `memory/MEMORY.md`

Add goals, key business facts, preferences.

### 7. Validation Test

Write a 2-sentence introduction of their business in their voice. Ask: "Does this sound like you?" If not, refine the voice guide.

### 8. Route to First Action

Based on their answers, tell them exactly where to start:

**No offer yet:**
> "Start with `/offer-engine` — it'll walk you through building your offer, then generate your ICP and search filters."

**Existing offer, no ICP:**
> "Start with `/offer-engine` in audit mode — paste your offer and let it score what's working. Then it'll build your ICP."

**Offer + ICP, no outreach:**
> "You're ready for `/research-lead` — find leads matching your ICP and the system will research each one and write personalised outreach."

**Offer + ICP + outreach, can't close:**
> "Run `/meeting-prep` before your next sales call for a full battle card. Or `/sales-closer` for CLOSER scripts and objection playbooks."

**Everything running, retention problem:**
> "Run `/offer-engine` Phase 8 (Money Model) to design your upsell/downsell/continuity architecture."

## Edge Cases

- **Wants to skip phases** — Fine. Write what you have. Skills ask for missing context at runtime.
- **Short answers** — Ask one follow-up max on critical info.
- **Existing context files** — Read them first. Pre-fill what you can, only ask for what's missing.
- **Reconfiguring** — Back up existing context files to `.tmp/` before overwriting.
- **Multiple offers** — Pick the primary one. Note the others. They can run offer-engine separately for each.
- **Doesn't know what tools to use** — Recommend Apollo (free tier) + HeyReach (LinkedIn) or Instantly (email). One lead gen + one outreach tool is enough to start.
