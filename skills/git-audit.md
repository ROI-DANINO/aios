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
