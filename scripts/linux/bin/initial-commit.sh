#!/usr/bin/env bash

if [[ -n "$1" ]]; then
  if git show-ref --verify --quiet "refs/heads/$1"; then
    echo "Error: branch '$1' already exists" >&2
    exit 1
  fi

  git switch -c "$1"
fi

git commit --allow-empty --only -m "initial commit"
