# Claude Skill (SKILL.md) — Template & Rules

## Frontmatter fields

| Field                      | Required    | Notes                                                                            |
|----------------------------|-------------|----------------------------------------------------------------------------------|
| `name`                     | No          | Display name. Defaults to the directory name.                                    |
| `description`              | Recommended | Trigger phrases first. ≤1,536 chars combined with `when_to_use`.                 |
| `when_to_use`              | No          | Extra trigger phrases / example requests. Appended to `description`.             |
| `argument-hint`            | No          | Shown in autocomplete. e.g. `[filename] [format]`                                |
| `disable-model-invocation` | No          | `true` for side-effect tasks (deploy, commit, send)                              |
| `context`                  | No          | `fork` to run in isolated subagent                                               |
| `agent`                    | No          | `Explore` / `Plan` / `general-purpose` (requires `context: fork`)                |
| `background`               | No          | `context: fork` only. `false` waits for the result in this turn. Default `true`. |
| `allowed-tools`            | No          | Pre-approve tools without per-use prompts. Grant clears next message.            |
| `model`                    | No          | Model while active. Same values as `/model`, or `inherit`.                       |
| `effort`                   | No          | `low` / `medium` / `high` / `xhigh` / `max` (depends on model)                   |

## Body rules

- State WHAT to do; omit WHY/HOW narration
- Keep under 500 lines (content stays in context all session = recurring cost)
- Use `` !`cmd` `` at line start for live data injection (runs before Claude sees content)
- Use `$ARGUMENTS` or `$0`, `$1` for user-provided input
- Reference supporting files rather than inlining large content

## Standard template

```yaml
---
description: [ Primary use case first. Trigger keywords. When to auto-invoke. ]
argument-hint: [ arg1 ] [ arg2 ]
---

## Context
  !`[ shell command for live data — remove section if unused ]`

  ## Instructions
  [ Direct, imperative. Number steps if order matters. ]

  ## Output format
  [ Exact format, length, structure ]
```

## Side-effect task (manual-only)

```yaml
---
description: [ What this does. When a user would invoke it manually. ]
disable-model-invocation: true
allowed-tools: Bash(git *) Bash(npm *)
---

## Instructions
[ Steps ]
```

## Isolated research (forked subagent)

```yaml
---
description: [ Research task description ]
context: fork
agent: Explore
---

Research $ARGUMENTS:
  1. [Step]
  2. [Step]

  Report findings with specific file references.
```
