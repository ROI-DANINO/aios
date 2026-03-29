#!/usr/bin/env bash
# update-skills-map.sh
# Scans skills/*.md for frontmatter names not yet in skills-map.md.
# Appends any new skills below the TODO marker with a review tag.
# Safe to run multiple times — only adds, never modifies existing entries.

set -euo pipefail

SKILLS_DIR="$(dirname "$0")/../skills"
MAP_FILE="$SKILLS_DIR/skills-map.md"
MARKER="<!-- NEW SKILLS APPENDED BELOW BY update-skills-map.sh — REVIEW PLACEMENT -->"

# Only run if the changed file is inside skills/ and is a .md file
# CLAUDE_TOOL_INPUT is set by Claude Code hooks to the tool's arguments (JSON)
if [ -n "${CLAUDE_TOOL_INPUT:-}" ]; then
  changed_file=$(echo "$CLAUDE_TOOL_INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null || true)
  if [ -n "$changed_file" ]; then
    # Only proceed if the changed file is in skills/ and isn't skills-map.md itself
    case "$changed_file" in
      */skills/*.md)
        [[ "$changed_file" == *"skills-map.md"* ]] && exit 0
        [[ "$changed_file" == *"skill-navigator.md"* ]] && exit 0
        ;;
      *) exit 0 ;;
    esac
  fi
fi

# Ensure marker exists in map
if ! grep -qF "$MARKER" "$MAP_FILE"; then
  echo "" >> "$MAP_FILE"
  echo "$MARKER" >> "$MAP_FILE"
fi

# For each skill file, check if its name is already in the map
for skill_file in "$SKILLS_DIR"/*.md; do
  basename_file=$(basename "$skill_file")
  [[ "$basename_file" == "skills-map.md" ]] && continue
  [[ "$basename_file" == "skill-navigator.md" ]] && continue

  # Extract name from frontmatter
  skill_name=$(awk '/^---/{p++} p==1 && /^name:/{print $2; exit}' "$skill_file" 2>/dev/null || true)
  [ -z "$skill_name" ] && continue

  # Check if already in map (look for the skill name in backticks)
  if grep -qF "\`$skill_name\`" "$MAP_FILE"; then
    continue
  fi

  # Extract description from frontmatter (handles single-line and multiline `>` YAML)
  skill_desc=$(awk '
    /^---/{p++; next}
    p==1 && /^description:/{
      val=$0; sub(/^description:[[:space:]]*/,"",val); gsub(/^>[[:space:]]*/,"",val)
      if (val != "" && val != ">") { print val; exit }
      in_desc=1; next
    }
    p==1 && in_desc {
      if (/^[a-z_]/) exit
      line=$0; sub(/^[[:space:]]]+/,"",line)
      if (line != "") { print line; exit }
    }
  ' "$skill_file" 2>/dev/null || echo "No description")
  skill_desc=$(echo "$skill_desc" | xargs)

  # Append to map below marker
  echo "| \`$skill_name\` | utility | <!-- TODO: add triggers --> | $skill_desc | <!-- TODO: review placement -->" >> "$MAP_FILE"
  echo "Skill navigator: added '$skill_name' to skills-map.md — review placement and triggers"
done
