---
name: git-audit
description: Interactive git and GitHub repo audit — stale branches, commit quality, repo settings, optional PR/issue/CI scan. Works on any repo. Auto-fixes safe issues, confirms destructive ones.
type: utility
---

# Git Audit Skill

Portable, interactive audit of any git/GitHub repository. Works on whatever project you point it at — not just AIOS. Surfaces findings category by category, lets you act on them inline, and optionally saves a structured report.

**Invocation:**
```
/git-audit              # interactive triage on current repo
/git-audit owner/repo   # explicit repo target
/git-audit report       # interactive triage + save report to data/
```

---

## Step 0 — Setup: Detect Repo + Auth

### Repo Detection

Run in order, stop at first success:

```bash
# 1. Was a repo argument passed? Use it directly.
# 2. Try to detect from git remote
git remote get-url origin 2>/dev/null
```

Parse `owner/repo` from remote URL:
```bash
# HTTPS: https://github.com/owner/repo.git → owner/repo
# SSH:   git@github.com:owner/repo.git     → owner/repo
REMOTE_URL=$(git remote get-url origin 2>/dev/null)
REPO_SLUG=$(echo "$REMOTE_URL" | sed -E 's|.*github\.com[:/]([^/]+/[^/]+)(\.git)?$|\1|')
GITHUB_USER=$(echo "$REPO_SLUG" | cut -d'/' -f1)
REPO=$(echo "$REPO_SLUG" | cut -d'/' -f2)
```

If this produces an empty result, ask the user:
> "I couldn't detect a GitHub repo from the current directory. What's the repo? (e.g. `owner/repo-name`)"

### Auth

```bash
# Check .env first
if [ -f .env ]; then
  GITHUB_TOKEN=$(grep -E '^GITHUB_TOKEN=' .env | cut -d'=' -f2- | tr -d '"'"'"'')
  export GITHUB_TOKEN
fi
# Fall back to existing env var — if GITHUB_TOKEN already set in shell, it stays
# If still empty, prompt user
```

If `GITHUB_TOKEN` is empty after both checks, say:
> "I need a GitHub token to check remote state. You can either:
> 1. Add `GITHUB_TOKEN=ghp_...` to your `.env` file (recommended — persists across sessions)
> 2. Paste it now — I'll assign it for this session only and won't echo it back
>
> If you paste it, I'll set: `export GITHUB_TOKEN=<your-token>` in this session only."

**Required PAT scopes:** `repo`, `workflow`

**Never echo or expose `GITHUB_TOKEN` in any response.**

### Base API helper (reused across all phases)

```bash
gh_api() {
  local ENDPOINT="$1"
  local GH_RESP_FILE="/tmp/gh_resp_$$.json"
  local HTTP_CODE
  HTTP_CODE=$(curl -s \
    -o "$GH_RESP_FILE" \
    -w "%{http_code}" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com${ENDPOINT}")
  if [ "$HTTP_CODE" -ge 400 ]; then
    echo "GitHub API error $HTTP_CODE:" >&2
    cat "$GH_RESP_FILE" >&2
    rm -f "$GH_RESP_FILE"
    return 1
  fi
  cat "$GH_RESP_FILE"
  rm -f "$GH_RESP_FILE"
}
```

---

## Phase 1 — Repo Setup

Run these checks first. Fast — all via one GitHub API call.

```bash
REPO_JSON=$(gh_api "/repos/$GITHUB_USER/$REPO")
DESCRIPTION=$(echo "$REPO_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('description') or '')")
TOPICS=$(echo "$REPO_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('topics', [])))")
DEFAULT_BRANCH=$(echo "$REPO_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['default_branch'])")
VISIBILITY=$(echo "$REPO_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print('private' if d['private'] else 'public')")

gh_api "/repos/$GITHUB_USER/$REPO/readme" > /dev/null 2>&1 && HAS_README="yes" || HAS_README="no"

PROT_JSON=$(gh_api "/repos/$GITHUB_USER/$REPO/branches/$DEFAULT_BRANCH/protection" 2>/dev/null || echo "{}")
PROTECTED=$(echo "$PROT_JSON" | python3 -c "
import json, sys
d = json.load(sys.stdin)
print('yes' if 'required_status_checks' in d or 'required_pull_request_reviews' in d else 'no')
")
```

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

Add description:
```bash
curl -s -X PATCH \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"description\":\"<user-provided description>\"}" \
  "https://api.github.com/repos/$GITHUB_USER/$REPO"
```

Enable basic branch protection (require PR reviews, no force-push):
```bash
curl -s -X PUT \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "Content-Type: application/json" \
  -d '{
    "required_status_checks": null,
    "enforce_admins": false,
    "required_pull_request_reviews": {"required_approving_review_count": 1},
    "restrictions": null
  }' \
  "https://api.github.com/repos/$GITHUB_USER/$REPO/branches/$DEFAULT_BRANCH/protection"
```

End with triage prompt:
> "Here's what I found — want me to fix anything, skip, or move to stale branches?"

---

## Phase 2 — Stale Branches

```bash
# Get all branches with age data
BRANCHES_JSON=$(gh_api "/repos/$GITHUB_USER/$REPO/branches?per_page=100")

# For each branch, get its last commit date
echo "$BRANCHES_JSON" | python3 -c "
import json, sys, urllib.request, os
from datetime import datetime, timezone

branches = json.load(sys.stdin)
now = datetime.now(timezone.utc)
token = os.environ.get('GITHUB_TOKEN', '')
results = []

for b in branches:
    name = b['name']
    sha = b['commit']['sha']
    req = urllib.request.Request(
        f'https://api.github.com/repos/$GITHUB_USER/$REPO/commits/{sha}',
        headers={
            'Authorization': f'Bearer {token}',
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28'
        }
    )
    try:
        with urllib.request.urlopen(req) as r:
            commit = json.load(r)
        date_str = commit['commit']['committer']['date']
        date = datetime.fromisoformat(date_str.replace('Z', '+00:00'))
        days_ago = (now - date).days
        results.append({'name': name, 'days_ago': days_ago})
    except Exception as e:
        results.append({'name': name, 'days_ago': -1})

for r in sorted(results, key=lambda x: x['days_ago'], reverse=True):
    print(f\"{r['name']}\t{r['days_ago']}\")
" > /tmp/branch_ages_$$.txt

# Get merged branches (local git check against default branch)
git fetch --all --quiet 2>/dev/null
git branch -r --merged "origin/$DEFAULT_BRANCH" 2>/dev/null | \
  sed 's|origin/||' | tr -d ' ' | grep -v "^$DEFAULT_BRANCH$" > /tmp/merged_branches_$$.txt
```

Parse results and identify:
- Branches in `/tmp/branch_ages_$$.txt` with `days_ago >= 30` → stale
- Branches also in `/tmp/merged_branches_$$.txt` → already merged (safe to delete)
- Branches stale but NOT in merged list → unmerged stale (confirm before delete)

Clean up temp files:
```bash
rm -f /tmp/branch_ages_$$.txt /tmp/merged_branches_$$.txt
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

Already-merged branches → delete without confirm (safe):
```bash
for BRANCH in $MERGED_STALE_BRANCHES; do
  curl -s -X DELETE \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_USER/$REPO/git/refs/heads/$BRANCH"
  echo "🗑️  Deleted merged branch: $BRANCH"
done
```

Unmerged stale branches → confirm batch first:
> "Delete these N unmerged stale branches? They haven't had activity in 30+ days and aren't merged into $DEFAULT_BRANCH. [y/n/skip]"

```bash
# Only run after explicit y from user
for BRANCH in $UNMERGED_STALE_BRANCHES; do
  curl -s -X DELETE \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_USER/$REPO/git/refs/heads/$BRANCH"
  echo "🗑️  Deleted: $BRANCH"
done
```

End with:
> "Here's what I found — want me to fix anything, skip, or move to commit quality?"

---

## Phase 3 — Commit Quality

Read-only phase. No actions — findings flagged for awareness only.

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

# Direct pushes to main (single-parent commits on default branch = not a merge commit)
git log "origin/$DEFAULT_BRANCH" --format="%H %P %s" -20 2>/dev/null | \
python3 -c "
import sys
for line in sys.stdin:
    parts = line.strip().split()
    if len(parts) < 2: continue
    sha = parts[0]
    # collect parent SHAs (40-char hex strings)
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

```bash
PRS_JSON=$(gh_api "/repos/$GITHUB_USER/$REPO/pulls?state=open&per_page=20")
echo "$PRS_JSON" | python3 -c "
import json, sys
from datetime import datetime, timezone
prs = json.load(sys.stdin)
now = datetime.now(timezone.utc)
if not prs:
    print('  ✅ No open PRs')
else:
    for pr in prs:
        created = datetime.fromisoformat(pr['created_at'].replace('Z', '+00:00'))
        age = (now - created).days
        reviewers = len(pr.get('requested_reviewers', []))
        reviewer_label = 'no reviewer' if reviewers == 0 else f'{reviewers} reviewer(s)'
        print(f'  #{pr[\"number\"]}\t{age}d old\t{reviewer_label}\t{pr[\"title\"][:50]}')
"
```

### Open Issues

```bash
ISSUES_JSON=$(gh_api "/repos/$GITHUB_USER/$REPO/issues?state=open&per_page=30")
echo "$ISSUES_JSON" | python3 -c "
import json, sys
from datetime import datetime, timezone
issues = json.load(sys.stdin)
now = datetime.now(timezone.utc)
flagged = []
for i in issues:
    if 'pull_request' in i: continue
    updated = datetime.fromisoformat(i['updated_at'].replace('Z', '+00:00'))
    stale_days = (now - updated).days
    labels = [l['name'] for l in i['labels']]
    assignees = len(i.get('assignees', []))
    flags = []
    if not labels: flags.append('unlabeled')
    if stale_days > 30: flags.append(f'stale {stale_days}d')
    if assignees == 0: flags.append('unassigned')
    if flags:
        flagged.append((i['number'], i['title'][:50], flags))
if not flagged:
    print('  ✅ No flagged issues')
else:
    for num, title, flags in flagged:
        print(f'  #{num}\t{title}\t[{\", \".join(flags)}]')
"
```

**Available actions:**

Add labels to issues in batch (confirm once for all):
```bash
# For each ISSUE_NUMBER in user-approved list:
curl -s -X POST \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"labels\":[\"<label>\"]}" \
  "https://api.github.com/repos/$GITHUB_USER/$REPO/issues/$ISSUE_NUMBER/labels"
```

Close stale issues (confirm batch):
> "Close these N issues with no activity in 30+ days? [y/n/skip]"

```bash
# Only after explicit y from user, for each ISSUE_NUMBER:
curl -s -X PATCH \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"state":"closed","state_reason":"not_planned"}' \
  "https://api.github.com/repos/$GITHUB_USER/$REPO/issues/$ISSUE_NUMBER"
```

### CI / GitHub Actions

```bash
RUNS_JSON=$(gh_api "/repos/$GITHUB_USER/$REPO/actions/runs?per_page=5")
echo "$RUNS_JSON" | python3 -c "
import json, sys
data = json.load(sys.stdin)
runs = data.get('workflow_runs', [])
if not runs:
    print('  ✅ No workflow runs found')
else:
    for r in runs:
        icon = '✅' if r['conclusion'] == 'success' else ('❌' if r['conclusion'] == 'failure' else '🔄')
        print(f'  {icon}  {r[\"name\"]}  ({r[\"head_branch\"]})  {r[\"created_at\"][:10]}')
"
```

Retrigger failed workflow (confirm first):
> "Retrigger `<workflow-name>` on `$DEFAULT_BRANCH`? [y/n]"

```bash
# Get workflow ID
WORKFLOWS_JSON=$(gh_api "/repos/$GITHUB_USER/$REPO/actions/workflows")
WORKFLOW_ID=$(echo "$WORKFLOWS_JSON" | python3 -c "
import json, sys
ws = json.load(sys.stdin)['workflows']
name = '<workflow-name>'  # replace with actual name from findings
for w in ws:
    if w['name'] == name:
        print(w['id'])
        break
")

# Only run after explicit y from user
curl -s -X POST \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"ref\":\"$DEFAULT_BRANCH\"}" \
  "https://api.github.com/repos/$GITHUB_USER/$REPO/actions/workflows/$WORKFLOW_ID/dispatches"
```
