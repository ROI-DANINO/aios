---
name: git-audit
description: >
  Interactive git and GitHub repo audit — stale branches, commit quality, repo settings,
  optional PR/issue/CI scan. Works on any repo. Auto-fixes safe issues, confirms destructive ones.
  Use when user says "git audit", "scan this repo", "stale branches", "commit quality",
  "repo health", "github audit", or "/git-audit".
type: utility
user-invocable: true
argument-hint: "[owner/repo | report] — defaults to current repo"
---

# Git Audit Skill

Portable, interactive audit of any git/GitHub repository. Works on whatever project you point it at — not just AIOS. Surfaces findings category by category, lets you act on them inline, and optionally saves a structured report.

**No token required** — reads use the GitHub MCP plugin, writes use the `gh` CLI.

**Invocation:**
```
/git-audit              # interactive triage on current repo
/git-audit owner/repo   # explicit repo target
/git-audit report       # interactive triage + save report to data/
```

---

## Step 0 — Setup: Detect Repo

### Repo Detection

```bash
REMOTE_URL=$(git remote get-url origin 2>/dev/null)
REPO_SLUG=$(echo "$REMOTE_URL" | sed -E 's|.*github\.com[:/]([^/]+/[^/]+)(\.git)?$|\1|')
GITHUB_USER=$(echo "$REPO_SLUG" | cut -d'/' -f1)
REPO=$(echo "$REPO_SLUG" | cut -d'/' -f2)
echo "$GITHUB_USER/$REPO"
```

If the result is empty, ask:
> "I couldn't detect a GitHub repo from the current directory. What's the repo? (e.g. `owner/repo-name`)"

No token or auth setup needed — all GitHub reads use the MCP plugin, all writes use `gh` CLI.

---

## Phase 1 — Repo Setup

Use MCP tools and `gh` CLI — no curl.

### Read repo metadata

```bash
# Description, topics, visibility, default branch
gh repo view $GITHUB_USER/$REPO --json description,repositoryTopics,isPrivate,defaultBranchRef \
  --jq '{description: .description, topics: (.repositoryTopics | length), defaultBranch: .defaultBranchRef.name, private: .isPrivate}'
```

### Check README

Call MCP tool: `mcp__plugin_github_github__get_file_contents`
- owner: `$GITHUB_USER`, repo: `$REPO`, path: `README.md`
- If it returns content → README exists. If it errors → missing.

### Check branch protection

Call MCP tool: `mcp__plugin_github_github__list_branches`
- owner: `$GITHUB_USER`, repo: `$REPO`
- Find the default branch entry and check `protected` field.

Store `DEFAULT_BRANCH` from the `gh repo view` output above.

Present findings:

```
⚙️  Repo Setup — owner/repo

  Description       [✅ set / ⚠️ missing]
  Topics            [✅ N topics / ⚠️ none set]
  README            [✅ found / ⚠️ missing]
  Default branch    [✅ main / ⚠️ <name> (not main)]
  Branch protection [✅ enabled / ⚠️ not set]
  Visibility        [public / private]
```

**Available fixes (confirm each individually before running):**

Create README (use MCP tool `mcp__plugin_github_github__create_or_update_file`):
- owner: `$GITHUB_USER`, repo: `$REPO`, path: `README.md`, branch: `$DEFAULT_BRANCH`
- message: `docs: add README`
- content: generate a meaningful README based on the repo's actual content

Add/update description:
```bash
gh repo edit $GITHUB_USER/$REPO --description "<user-provided description>"
```

Add topics:
```bash
gh repo edit $GITHUB_USER/$REPO --add-topic "<topic>"
```

Enable branch protection (require PR reviews, block force-push):
```bash
gh api -X PUT /repos/$GITHUB_USER/$REPO/branches/$DEFAULT_BRANCH/protection \
  -F required_status_checks=null \
  -F enforce_admins=false \
  -F 'required_pull_request_reviews[required_approving_review_count]=1' \
  -F restrictions=null
```

End with triage prompt:
> "Here's what I found — want me to fix anything, skip, or move to stale branches?"

---

## Phase 2 — Stale Branches

### Read all branches

Call MCP tool: `mcp__plugin_github_github__list_branches`
- owner: `$GITHUB_USER`, repo: `$REPO`, perPage: 100

For each branch, get its last commit date by calling MCP tool: `mcp__plugin_github_github__list_commits`
- owner: `$GITHUB_USER`, repo: `$REPO`, sha: `<branch-name>`, perPage: 1
- Take `commit.author.date` from the first result

Calculate days since last commit for each branch. Flag branches with `days_ago >= 30`.

### Check which branches are merged

```bash
git fetch --all --quiet 2>/dev/null
git branch -r --merged "origin/$DEFAULT_BRANCH" 2>/dev/null | \
  sed 's|origin/||' | tr -d ' ' | grep -v "^$DEFAULT_BRANCH$"
```

Present findings grouped:

```
🌿  Stale Branches

  ALREADY MERGED (safe to delete):
    fix/typo-header       last commit 62 days ago    ✅ merged into main

  STALE, NOT MERGED (30+ days, no activity):
    feature/old-login     last commit 47 days ago
    experiment/new-ui     last commit 91 days ago
```

**Auto-fix rules:**

Already-merged stale branches → delete without extra confirm (safe):
```bash
for BRANCH in $MERGED_STALE_BRANCHES; do
  gh api -X DELETE /repos/$GITHUB_USER/$REPO/git/refs/heads/$BRANCH
  echo "🗑️  Deleted merged branch: $BRANCH"
done
```

Unmerged stale branches → confirm batch first:
> "Delete these N unmerged stale branches? They haven't had activity in 30+ days and aren't merged into $DEFAULT_BRANCH. [y/n/skip]"

```bash
# Only run after explicit y from user
for BRANCH in $UNMERGED_STALE_BRANCHES; do
  gh api -X DELETE /repos/$GITHUB_USER/$REPO/git/refs/heads/$BRANCH
  echo "🗑️  Deleted: $BRANCH"
done
```

End with:
> "Here's what I found — want me to fix anything, skip, or move to commit quality?"

---

## Phase 3 — Commit Quality

Read-only phase. No actions — findings flagged for awareness only. Uses local git only.

```bash
# Large commits (diff > 500 lines) in last 50 commits
git log --oneline -50 --format="%H %s" 2>/dev/null | while IFS=' ' read -r SHA MSG; do
  TOTAL=$(git diff --shortstat "$SHA^" "$SHA" 2>/dev/null | \
    python3 -c "
import sys, re
line = sys.stdin.read()
ins = int(re.search(r'(\d+) insertion', line).group(1) if re.search(r'(\d+) insertion', line) else 0)
dels = int(re.search(r'(\d+) deletion', line).group(1) if re.search(r'(\d+) deletion', line) else 0)
print(ins + dels)
" 2>/dev/null || echo 0)
  if [ "$TOTAL" -gt 500 ] 2>/dev/null; then
    echo "LARGE	${SHA:0:8}	$TOTAL lines	$MSG"
  fi
done

# Non-conventional commit messages
git log --oneline -50 --format="%H %s" 2>/dev/null | \
python3 -c "
import sys, re
pattern = re.compile(r'^(feat|fix|chore|docs|refactor|test|perf|ci|build|style)(\(.+\))?!?:')
for line in sys.stdin:
    parts = line.strip().split(' ', 1)
    if len(parts) < 2: continue
    sha, msg = parts
    if not pattern.match(msg):
        print(f'NON-CONV\t{sha[:8]}\t{msg}')
"

# Direct pushes to default branch (single-parent commits = not a merge commit)
git log "origin/$DEFAULT_BRANCH" --format="%H %P %s" -20 2>/dev/null | \
python3 -c "
import sys
for line in sys.stdin:
    parts = line.strip().split()
    if len(parts) < 2: continue
    sha = parts[0]
    parents = []
    i = 1
    while i < len(parts) and len(parts[i]) == 40:
        parents.append(parts[i])
        i += 1
    msg = ' '.join(parts[i:])
    if len(parents) == 1:
        print(f'DIRECT\t{sha[:8]}\t{msg}')
"
```

Present findings:

```
📝  Commit Quality (last 50 commits)

  LARGE COMMITS (>500 lines):
    a1b2c3  Refactor entire auth module   (1,240 lines changed)

  NON-CONVENTIONAL MESSAGES:
    9f8e7d  "update stuff" — missing type prefix
    3d4e5f  "WIP" — missing type prefix

  DIRECT PUSHES TO main:
    bb1234  fix null pointer in auth
```

If no issues found in a category, show: `  ✅ None found`

End with:
> "Commit quality check done — these are for awareness only, no automated fixes. Want me to also check open PRs, issues, and CI status?"

---

## Phase 4 — PRs, Issues, CI (on-demand)

Only run if user says yes to the Phase 3 prompt.

### Open PRs

Call MCP tool: `mcp__plugin_github_github__list_pull_requests`
- owner: `$GITHUB_USER`, repo: `$REPO`, state: `open`, perPage: 20

For each PR compute age from `created_at`, count `requested_reviewers`.

```
🔀  Open PRs

  #42   3d old   no reviewer   Add login page
  #38  12d old   1 reviewer    Refactor auth middleware
```

If none: `  ✅ No open PRs`

### Open Issues

Call MCP tool: `mcp__plugin_github_github__list_issues`
- owner: `$GITHUB_USER`, repo: `$REPO`, state: `OPEN`, perPage: 30

Flag issues that are: unlabeled, stale (no update in 30+ days), or unassigned.

```
🐛  Open Issues (flagged)

  #15  Bug: login fails on mobile  [unlabeled, stale 45d, unassigned]
  #9   Add dark mode               [unlabeled, unassigned]
```

If none flagged: `  ✅ No flagged issues`

**Available actions:**

Add label to issue (use MCP tool `mcp__plugin_github_github__issue_write`):
- owner: `$GITHUB_USER`, repo: `$REPO`, issue_number: `<N>`, labels: `["<label>"]`

Close stale issues (confirm batch first):
> "Close these N issues with no activity in 30+ days? [y/n/skip]"

```bash
# Only after explicit y from user
for ISSUE_NUMBER in $STALE_ISSUES; do
  gh issue close $ISSUE_NUMBER --repo $GITHUB_USER/$REPO --reason "not planned"
done
```

### CI / GitHub Actions

```bash
gh run list --repo $GITHUB_USER/$REPO --limit 5 --json status,conclusion,name,headBranch,createdAt \
  --jq '.[] | [if .conclusion == "success" then "✅" elif .conclusion == "failure" then "❌" else "🔄" end, .name, "(\(.headBranch))", .createdAt[:10]] | join("  ")'
```

Retrigger failed workflow (confirm first):
> "Retrigger `<workflow-name>` on `$DEFAULT_BRANCH`? [y/n]"

```bash
# Only after explicit y from user
WORKFLOW_ID=$(gh workflow list --repo $GITHUB_USER/$REPO --json name,id \
  --jq '.[] | select(.name == "<workflow-name>") | .id')
gh workflow run $WORKFLOW_ID --repo $GITHUB_USER/$REPO --ref $DEFAULT_BRANCH
```

---

## Report Mode

Only triggered when invoked as `/git-audit report`. After all phases complete, save a structured report.

**Output path:** `data/git-audit-<owner>-<repo>-<YYYY-MM-DD>.md`

```bash
REPORT_DATE=$(date +%Y-%m-%d)
REPORT_PATH="data/git-audit-${GITHUB_USER}-${REPO}-${REPORT_DATE}.md"
```

After triage is complete, write this structure to `$REPORT_PATH` (filling in actual findings):

```markdown
# Git Audit — owner/repo — YYYY-MM-DD

## Health Score: N/10

Score calculation:
- Start at 10
- -1 per missing repo setup item (description, topics, README, branch protection) — max -4
- -1 per unresolved stale branch remaining after cleanup — max -2
- -1 per commit quality flag category with 3+ instances (large commits, non-conventional, direct pushes) — max -2
- -1 if CI has failing runs on default branch
- -1 if 5+ issues are stale/unlabeled (only if phase 4 was run)

### Repo Setup      ✅/⚠️  X/6 checks passed
### Stale Branches  ✅/⚠️  N found, N cleaned, N remaining
### Commit Quality  ✅/⚠️  N flags (large: X, non-conventional: Y, direct pushes: Z)
### PRs/Issues/CI   ✅/⚠️/skipped
```

Announce when saved:
> "Report saved to `data/git-audit-owner-repo-YYYY-MM-DD.md`"

## See Also

- `/skill-scan` — full skill audit; complement to git-audit for repo health
- `/context-clean` — periodic AIOS data maintenance
- `/session-close` — run after audit to log findings
