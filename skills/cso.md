---
name: cso
description: >
  Security officer review. Scans changed files for OWASP top 10 issues, exposed
  secrets, unsafe inputs, and permission problems. Outputs findings with severity
  (critical/warn/info). Use when user says "security check", "is this safe to ship",
  "cso", or "check for vulnerabilities".
user-invocable: true
argument-hint: "[path/to/file or directory] — defaults to git diff from main"
---

# CSO — Chief Security Officer

Read the code. Find the holes. Report them before they ship.

## When to Trigger

- "security check"
- "is this safe to ship"
- "cso"
- "check for vulnerabilities"
- "audit this"
- After `/qa`, before `/ship` on any externally-facing feature

## Process

### Phase 1: Load context (silent)

1. Get changed files: `git diff main...HEAD --name-only`
2. If argument provided, scope to that file/directory instead
3. Read all changed files in full

### Phase 2: Scan for issues

Check each file against this list. Flag every instance found.

**CRITICAL (block ship):**
- Hardcoded secrets, API keys, passwords, tokens in code
- SQL queries built with string concatenation (SQL injection)
- `eval()` or `exec()` called with user input
- File paths constructed from user input without sanitisation
- Missing authentication on routes that modify data
- Credentials committed to git (check git diff for .env-like patterns)

**WARN (fix before ship unless risk accepted):**
- User input rendered directly into HTML (XSS)
- Unvalidated file uploads (type, size, path)
- Sensitive data logged (emails, tokens, PII)
- CORS set to `*` on an API with auth
- JWT verified without checking algorithm
- Dependency versions pinned to `*` or `latest`

**INFO (note, no action required):**
- `console.log` / `print` statements left in production paths
- TODO/FIXME comments near security-sensitive logic
- Rate limiting absent on public endpoints
- Error messages exposing stack traces to clients

### Phase 3: Output the report

```
## Security Review — {project} — {date}

### CRITICAL 🔴
{finding}: `path/to/file.py:42` — {description of what's wrong and why it matters}
{or "None found."}

### WARN 🟡
{finding}: `path/to/file.py:88` — {description}
{or "None found."}

### INFO 🔵
{finding}: `path/to/file.py:12` — {description}
{or "None found."}

### Verdict
{One line: "Clear to ship." OR "N critical issues must be fixed before shipping."}
```

### Phase 4: Route

| Verdict | Next step |
|---------|-----------|
| No critical issues | "Run `/ship` when ready." |
| Critical issues found | "Fix these before shipping: {list}. Re-run `/cso` after." |
| Warn issues only | "Review warns and decide. Run `/ship` when comfortable." |

## Edge Cases

- **Binary files changed** — Skip them. Note: "Skipped binary files."
- **Generated code** — Flag but note it's generated; fix at the generator level.
- **Test files only changed** — Report: "Only test files changed. No production security surface affected."
- **Can't read a file** — Note the file name and skip it.
