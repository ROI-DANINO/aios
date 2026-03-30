# Skill Improvement Backlog

## Wiring tasks
<!-- Items appended by /skill-scan -->
- [x] `git-audit` — add `## See Also` section pointing to related skills (skill-scan, context-clean) — missing all chain connections ✓ done
- [x] `session-redo` — add `## Next Step` pointing back to session-close or daily-brief — orphaned from session-loop chain ✓ done

## Cleanup tasks
<!-- Items appended by /skill-scan -->
- [x] `git-audit` — add trigger phrases to frontmatter description ✓ done
- [x] `git-audit` — add `user-invocable: true` to frontmatter ✓ done
- [x] `pod-mapper` — decide: keep AIOS local or defer to `superpowers:pod-mapper` — duplicate active, not in known-duplicates resolution table ✓ resolved: keep local, documented in known-duplicates table
- [x] `business-setup` — decide: keep AIOS local or defer to `superpowers:business-setup` — duplicate active, not in known-duplicates resolution table ✓ resolved: keep local, documented in known-duplicates table
- [x] deprecated superpowers skills — unregister `superpowers:brainstorm`, `superpowers:execute-plan`, `superpowers:write-plan` from plugin cache — stale deprecated registrations still active in session ✓ no action needed — managed redirect stubs with `disable-model-invocation: true`; controlled by superpowers plugin package

## Exploration tasks
<!-- Ideas promoted from notes.md -->
- [ ] **skill-creator** — build a skill that auto-generates new AIOS skills when a gap is detected (self-improvement / Hermes plan)
- [ ] **parallel-agents dispatch** — build an agent skill to spawn multiple subagents with dependency/blocking support (replaces or wraps `/conductor`)
- [ ] **Paperclip integration** — research Paperclip as UI layer for agent management before building custom dashboard; revisit when Captionate v3 reaches data/testing phase

## Hermes Phase 0
<!-- Promoted from notes.md -->
- [ ] Answer 4 open questions in `~/Desktop/Projects/hermes-integration/status.md`
- [ ] Clone + install hermes-agent
- [ ] Link progress to `deliverables/hermes-integration-plan.md`

## Open questions
- [ ] `system-architect` — clarify whether it's a standalone entry point or always follows `init`
- [ ] `office-hours` — validate that merged gstack format doesn't conflict with local debugging route
- [ ] `conductor` vs `superpowers:dispatching-parallel-agents` — document the difference clearly in both skill files
