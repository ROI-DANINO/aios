# Research: Open-Source Slack Alternatives as Agent Communication Layer

**Status:** Stub — not yet researched
**Added:** 2026-04-03

## Question

Could an open-source Slack alternative serve as the communication backbone for AIOS agents — replacing or augmenting the current claude-peers MCP approach?

## Candidates to Evaluate

- **Mattermost** — self-hosted, REST + WebSocket API, bot framework, Slack-compatible
- **Rocket.Chat** — self-hosted, rich API, webhooks, omnichannel
- **Zulip** — topic-threaded model, strong bot/API story, open source
- **Matrix / Element** — federated, bridges everything, strong E2E story
- Others worth checking: Revolt, Spacebar, Natter

## Questions to Answer

1. Does any of these offer a programmable API good enough for agent-to-agent messaging (not just human chat)?
2. How does the threading/channel model map to agent coordination patterns (task handoffs, broadcasts, direct)?
3. Could this replace claude-peers, or complement it (e.g. persistent logs, human visibility into agent comms)?
4. What's the operational overhead of self-hosting vs the simplicity of file-based or MCP messaging?
5. Does any of these have an existing Claude Code / MCP integration?

## Hypothesis

A self-hosted Slack alternative could give agents a persistent, observable, human-readable communication channel — especially useful for async coordination and audit trails. Tradeoff: operational complexity vs current lightweight MCP approach.

## Related

- claude-peers MCP (current agent comms mechanism)
- AI team system design spec (`docs/superpowers/specs/`)
- Hermes integration research
