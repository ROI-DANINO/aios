---
name: ship
description: >
  Release checklist. Bumps version, writes changelog entry from git log, creates
  a git tag, outputs deploy command. Confirms before any destructive or external
  action. Use when user says "ship this", "release", "deploy", "tag this", or
  "time to ship".
user-invocable: true
argument-hint: "[version] — e.g. 1.2.0. If omitted, suggests next semver patch."
---

# Ship

One command from done to deployed. No skipped steps. No surprises.

## When to Trigger

- "ship this"
- "release"
- "deploy"
- "tag this"
- "time to ship"
- After `/qa` and `/cso` pass

## Pre-Flight Check

Before doing anything, verify:

1. `git status` — working tree must be clean
2. Current branch — warn if not on `main` or a release branch
3. Last QA/CSO — ask: "Has this been through `/qa` and `/cso`?" If no, recommend running them first. Don't block — Roi decides.

If anything fails pre-flight, report it and ask: "Fix this first, or proceed anyway?"

**HARD RULE: Never proceed past pre-flight without explicit confirmation.**

## Process

### Phase 1: Determine version

1. If argument provided, use it as the new version
2. If no argument: read current version from `package.json`, `pyproject.toml`, or `VERSION` file (try in that order)
3. Suggest next patch version (e.g. `1.2.3` → `1.2.4`)
4. Ask: "Releasing as v{version}. Confirm?"

Wait for confirmation before proceeding.

### Phase 2: Write changelog entry

1. Run: `git log {last_tag}...HEAD --oneline`
2. Group commits by type (feat, fix, chore, docs)
3. Write a changelog entry:

```
## v{version} — {date}

### Features
- {feat commits summarised}

### Fixes
- {fix commits summarised}

### Other
- {chore/docs commits if notable}
```

4. If a `CHANGELOG.md` exists, prepend the entry. If not, create it.
5. Stage the file: `git add CHANGELOG.md`

### Phase 3: Commit + tag

Run these commands. Show each one before running and wait for confirmation on the tag step.

```bash
git commit -m "chore: release v{version}"
```

Then ask: "Create tag v{version}? This will be visible in git history."

On confirmation:
```bash
git tag -a v{version} -m "Release v{version}"
```

### Phase 4: Deploy

Ask: "Push and deploy now?"

On confirmation, run:
```bash
git push origin main --tags
```

Then output the deploy command for the project (read from `Makefile`, `package.json` scripts, or `Procfile`). If none found, output:
```
No deploy command found. Push complete. Run your deploy manually.
```

### Phase 5: Confirm

```
## Ship Report — v{version} — {date}

- [x] Version bumped
- [x] Changelog written
- [x] Commit created
- [x] Tag created: v{version}
- [x] Pushed to origin
- [ ] Deploy: {status}

Shipped. 🚀
```

## Edge Cases

- **No VERSION file or package.json** — Ask: "What version is this? I can't find a version file."
- **No previous tag** — Use first commit as the base for the changelog: `git log --oneline`
- **Dirty working tree** — Hard stop. "Working tree has uncommitted changes. Clean up first."
- **Not on main** — Warn clearly but let Roi decide: "You're on branch {name}, not main. Proceed?"
