#!/usr/bin/env bash
# Sync .claude/agents/*.md frontmatter to .omp/agents/*.yaml
# Run after any agent definition changes.
set -e
AGENTS_DIR="$(dirname "$0")/../.claude/agents"
OMP_DIR="$(dirname "$0")/../.omp/agents"

for agent_file in "$AGENTS_DIR"/*.md; do
  agent_name=$(basename "$agent_file" .md)
  name=$(grep "^name:" "$agent_file" | head -1 | awk '{print $2}')
  model=$(grep "^model:" "$agent_file" | head -1 | awk '{print $2}')
  permission=$(grep "^permissionMode:" "$agent_file" | head -1 | awk '{print $2}')
  cat > "$OMP_DIR/${agent_name}.yaml" << EOF
# oh-my-pi agent definition
# Source: ../../.claude/agents/${agent_name}.md
name: ${name}
model: ${model}
permissionMode: ${permission}
source: ../../.claude/agents/${agent_name}.md
EOF
  echo "Synced: ${agent_name}"
done
echo "Done. Agents synced to .omp/agents/"
