---
name: pod-mapper
description: >
  Interactive business workflow audit — map any business function into a "pod" with clear workflows,
  tools, data sources, automation opportunities, and technical translation. Helps avoid overwhelm by
  breaking the AIOS build into one department at a time. Use when user says "map my business",
  "pod mapping", "audit my workflow", "where do I start", "what should I automate", "help me plan
  my AIOS", "map my sales process", "map my content workflow", or wants to figure out what to build first.
user-invocable: true
argument-hint: "[engine] e.g. acquisition, delivery, support, operations"
---

# Pod Mapper

Interactive workflow audit. One business function at a time. No overwhelm.

## Philosophy

Bottom-up, not top-down. Start with the pain, not the architecture. Map one pod, get it running, then map the next. The architecture emerges — you don't design it upfront.

## When to Trigger

- User doesn't know where to start building their AIOS
- User wants to audit a specific business function before automating it
- User says "what should I automate first", "where do I start", "map my workflow"
- After business-setup is complete and user is ready to build

## Process

Run conversationally. One phase at a time. Wait for answers before moving on.

### Phase 1: Pick Your Engine

Every business runs on four engines:

1. **Acquisition** — Getting clients in the door. Content, lead gen, outreach, sales calls, proposals, closing.
2. **Delivery** — Doing the actual work. Building, shipping, fulfilling the promise.
3. **Support** — Keeping clients happy. Onboarding, communication, check-ins, retention.
4. **Operations** — Keeping the business running. Planning, reviews, email, admin, health checks.

Ask:
1. "Which of these four engines is eating the most of your time right now? Or costing you the most in missed revenue?"
2. "Rate the pain 1-10."
3. "What specifically about that engine is painful? Is it the volume, the repetitiveness, or not knowing what to do?"

Pick the highest-pain engine. That's the first pod.

### Phase 2: Map the Workflow

Ask:
"Walk me through exactly what you do for [function], step by step. Start from the trigger (what kicks it off?) to the end result. Don't skip the boring parts — those are usually the ones we automate."

Write it back as a numbered workflow:

```
## [Pod Name] Workflow

1. [Trigger] → e.g. "New lead comes in from Apollo"
2. [Step] → e.g. "Check their LinkedIn profile"
3. [Step] → e.g. "Research their company"
4. [Step] → e.g. "Write a personalised DM"
5. [Step] → e.g. "Send via HeyReach"
...
N. [Output] → e.g. "Call booked on Calendly"
```

Confirm: "Does this capture your actual workflow? Anything missing?"

### Phase 3: Identify the Stack

For each step, ask:
1. "What tool do you use for this step?" (or "manual / in my head")
2. "Where does the data for this step live?"

Build a stack map:

```
| Step | Tool | Data Source |
|---|---|---|
| Find leads | Apollo | Apollo database |
| Check LinkedIn | Manual browsing | LinkedIn |
| Research company | Google / manual | Various |
| Write DM | Manual typing | My head |
| Send outreach | HeyReach | Google Sheets |
```

Flag any step where data source is "my head" or "nowhere" — those need externalising into context files first.

### Phase 4: Circle the Waste

Present the workflow and categorise each step:
- **AUTOMATE** — AI can do this without your judgment → becomes a scheduled skill
- **ASSIST** — AI preps it, you make the final call → becomes a manual skill with auto-prep
- **KEEP** — Genuinely needs your brain → stays human

Build the automation map:

```
| Step | Verdict | Why |
|---|---|---|
| Find leads | AUTOMATE | Criteria-based, no judgment |
| Check LinkedIn | AUTOMATE | Research task, AI scrapes and summarises |
| Research company | AUTOMATE | Perplexity + Firecrawl handle this |
| Write DM | ASSIST | AI drafts, you approve before sending |
| Send outreach | KEEP | You review and hit send |
```

If user says everything needs their judgment, push back: "You said you research companies manually. What are you actually looking for? Revenue? Tech stack? Recent news? Those are criteria AI can search for."

### Phase 5: Translate to Technical

For each AUTOMATE and ASSIST step, map to:
1. **Which skill handles it** — check existing AIOS skills. If none exists, note "needs new skill."
2. **Which MCP connectors needed** — Gmail, Apollo, ClickUp, YouTube Analytics, etc.
3. **Scheduled or manual** — AUTOMATE → scheduled. ASSIST → manual with prep.
4. **Data requirements** — what context files must exist.

```
| Step | Skill | MCP/Connector | Schedule | Needs |
|---|---|---|---|---|
| Find leads | /research-lead | Apollo MCP | Daily 7am | context/my-icp.md |
| Check LinkedIn | /research-lead | Firecrawl | (same run) | — |
| Research company | /research-lead | Perplexity | (same run) | — |
| Write DM | /research-lead | — | (manual approve) | context/my-voice.md |
| Prep for call | /meeting-prep | ClickUp, Gmail | 1hr before call | context/gtm-profile.md |
```

Tell the user:
- "Here's what you need to install/configure: [list MCP connectors]"
- "Here's what runs on autopilot: [list scheduled skills]"
- "Here's what you still do, but with AI prep: [list assisted skills]"
- "Here's what's missing: [list gaps — new skills needed, context files to write]"

### Phase 6: Connection Map (only after 2+ pods mapped)

If the user has already mapped at least one other pod (check for `deliverables/pod-map-*.md` files), run the connection phase:

Ask: "Now that you have [Pod A] and [Pod B] mapped, let's connect them. What does [Pod A] produce that [Pod B] needs?"

Build a simple connection map:

```
[Content OS] → publishes video → creates awareness → [GTM OS]
[GTM OS] → closes deal → triggers onboarding → [Operations]
[Operations] → daily brief → pulls metrics from → [Content OS] + [GTM OS]
```

Tell the user: "These connections are the LAST thing you build. Get each pod running independently first. Then wire them together."

### Phase 7: Save and Route

Save the complete pod map to `deliverables/pod-map-[name].md` with all sections.

Route to next action:
- Missing context files → "Run /business-setup first"
- MCP connectors to configure → "Set up [connector] in your Cowork connectors panel"
- Skills exist → "You're ready to run /[skill-name] — try it now"
- Skills missing → "You need a custom skill for [step]. We can build one."
- Another pod to map → "Ready for the next pod? Which function is next?"

## Edge Cases

- **Can't articulate workflow** — Ask them to describe their last client/project from start to finish. Walk through that specific example.
- **No tools yet** — Recommend minimum: one lead gen tool (Apollo free), one outreach tool (HeyReach or Instantly), one PM tool (ClickUp or Notion free).
- **Everything needs judgment** — Push back gently. Identify the criteria behind their "judgment" — those criteria become automation rules.
- **Wants to map everything at once** — Stop them. "Pick the one that hurts most. We'll get that running first."
- **Workflow too simple (3 steps)** — That's fine. Map it, automate what you can, move on.
- **Workflow too complex (20+ steps)** — Break into sub-pods. "Your sales workflow has three phases: prospecting, outreach, and closing. Let's map prospecting first."
