#!/usr/bin/env bash

cd ~ || exit 1

case "$1" in
  claude)
    ln -sfn dotfiles/genai/custom-prompt.md .claude/CLAUDE.md
    ;;
  codex)
    ln -sfn dotfiles/genai/custom-prompt.md .codex/AGENTS.md
    ;;
  *)
    echo "Usage: $0 {claude|codex}" >&2
    exit 1
    ;;
esac
