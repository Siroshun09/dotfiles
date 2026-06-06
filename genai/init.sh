#!/usr/bin/env bash

case "$1" in
  claude)
    mkdir -p .claude
    ln -sfn ~/dotfiles/genai/custom-prompt.md ~/.claude/CLAUDE.md
    ln -sfn ~/dotfiles/genai/claude/settings.json ~/.claude/settings.json
    ln -sfn ~/dotfiles/genai/claude/statusline.sh ~/.claude/statusline.sh
    ;;
  codex)
    ln -sfn ~/dotfiles/genai/custom-prompt.md .codex/AGENTS.md
    ;;
  *)
    echo "Usage: $0 {claude|codex}" >&2
    exit 1
    ;;
esac
