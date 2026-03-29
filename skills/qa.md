---
name: qa
description: >
  QA pass before shipping. Reads the current branch diff and test files, runs
  existing tests, flags untested paths, edge cases, and regressions. Outputs a
  pass/fail checklist. Use when user says "qa this", "test coverage", "edge cases",
  "before I ship", or "is this ready to ship".
user-invocable: true
argument-hint: "[path/to/project] — defaults to current working directory"
---

# QA

No guessing. Read the diff. Run the tests. Report the truth.

## When to Trigger

- "qa this"
- "test coverage"
- "edge cases"
- "before I ship"
- "is this ready"
- After implementation, before `/ship`

## Process

### Phase 1: Load context (silent)

1. Identify project root — use argument if provided, else current directory
2. Run `git diff main...HEAD --name-only` to get changed files
3. Find test files: look for `tests/`, `__tests__/`, `*.test.*`, `*.spec.*` in the project
4. Read changed files and their corresponding test files

### Phase 2: Run tests

Run the appropriate test command for the project. Try in order:
```bash
# Python
pytest --tb=short -q

# JavaScript/TypeScript
npm test -- --passWithNoTests

# Bun
bun test
```

Capture output. Note: pass count, fail count, any errors.

### Phase 3: Analyse coverage gaps

For each changed file:
- List functions/methods changed
- Check if corresponding tests exist
- Flag any changed logic with no test coverage
- Identify obvious edge cases not covered (null inputs, empty arrays, auth failures, network errors)

### Phase 4: Output the checklist

```
## QA Report — {project} — {date}

### Test Results
- Status: {PASS / FAIL / UNKNOWN}
- {N} passing, {N} failing
- {Note if tests could not be run and why}

### Coverage Gaps
{For each changed file with gaps:}
- `path/to/file.py` — {function()} has no test for {edge case}

### Regressions to Watch
{Any changed logic that could affect existing behaviour — flag these specifically}

### Verdict
{One line: "Ready to ship." OR "N issues to address before shipping."}
```

### Phase 5: Route

| Verdict | Next step |
|---------|-----------|
| All pass, no gaps | "Run `/ship` when ready." |
| Tests failing | "Fix failing tests before shipping. Run `/systematic-debugging` if stuck." |
| Coverage gaps only | "Consider adding tests for: {list}. Or accept the risk and run `/ship`." |
| Could not run tests | "Set up your test runner first. Then re-run `/qa`." |

## Edge Cases

- **No tests exist** — Report: "No test files found. Flagging all changed logic as untested." List changed functions.
- **Tests pass but no assertions** — Flag: "Tests exist but may not be asserting anything meaningful."
- **Docker required** — If tests need Docker and it's not running, skip live run and use grep to count test functions.
- **Monorepo** — Run tests only in the affected package directory.
