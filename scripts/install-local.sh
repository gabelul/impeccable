#!/bin/bash
# Install impeccable skills from this fork globally to ~/.claude/skills/
# Run after making changes to source skills and rebuilding.
#
# Handles the case where existing skills are symlinks (from a plugin install)
# by removing them first, then copying the built directories in their place.
#
# Usage: ./scripts/install-local.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SOURCE="$ROOT_DIR/dist/claude-code/.claude/skills"
DEST="$HOME/.claude/skills"

if [ ! -d "$SOURCE" ]; then
  echo "Skills not built yet. Run 'bun run build' first."
  exit 1
fi

if [ ! -d "$DEST" ]; then
  echo "No global skills directory at $DEST — create it first or install impeccable normally."
  exit 1
fi

# For each skill in dist, remove the old one (symlink or dir) and copy fresh
INSTALLED=0
for skill_dir in "$SOURCE"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$DEST/$skill_name"

  # Remove existing symlink or directory
  if [ -L "$target" ]; then
    rm "$target"
  elif [ -d "$target" ]; then
    rm -rf "$target"
  fi

  # Use rsync to skip macOS extended attribute files (._*) from external volumes
  rsync -a --exclude='._*' "$skill_dir" "$target/"
  INSTALLED=$((INSTALLED + 1))
done

echo "Installed $INSTALLED impeccable skills to $DEST"
