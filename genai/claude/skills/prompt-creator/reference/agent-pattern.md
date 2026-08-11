# Claude Code Subagent (.claude/agents/*.md) — Template & Rules

A subagent is a markdown file the main agent **delegates to**. The frontmatter controls discovery and tooling; the body
**is** the subagent's system prompt.

Location: `.claude/agents/<name>.md` (project) or `~/.claude/agents/<name>.md` (user).

## Frontmatter fields

| Field             | Required | Notes                                                                                                    |
|-------------------|----------|----------------------------------------------------------------------------------------------------------|
| `name`            | Yes      | Unique identifier. Lowercase letters and hyphens only.                                                   |
| `description`     | Yes      | When to delegate. Drives auto-invocation — write it like a trigger.                                      |
| `tools`           | No       | Comma-separated allowlist. Omit to inherit all tools.                                                    |
| `disallowedTools` | No       | Deny-list applied on top of the inherited or specified `tools`.                                          |
| `model`           | No       | `sonnet` / `opus` / `haiku` / `fable`, a full ID (`claude-opus-5`), or `inherit`. Defaults to `inherit`. |
| `effort`          | No       | `low` / `medium` / `high` / `xhigh` / `max`. Defaults to the session's.                                  |
| `permissionMode`  | No       | Overrides how the subagent handles permission prompts.                                                   |

> Background subagents (the default) run with a reduced built-in tool set. If the agent
> needs a tool outside `Read` / `Grep` / `Glob` / `Bash` / `Edit` / `Write` / `WebFetch` /
> `WebSearch`, verify it survives that filter before relying on it.

## Body rules

- The body is a **system prompt for a fresh agent** — it starts with no conversation context. State the role, scope, and
  method from scratch.
- Write `description` for delegation: lead with trigger conditions ("Use when…",
  "MUST BE USED for…"). Add "use proactively" to encourage auto-delegation.
  `description` is **routing** text and is the one place calibrated urgency belongs — the pressure-language rule in
  principles.md applies to the body, not here.
- Scope `tools` to the minimum the job needs — read-only agents should not get
  `Edit`/`Write`/`Bash`. Narrower tools = safer, faster delegation.
- Define what the subagent **returns** to the main agent — it only relays its final message, so specify the report
  format explicitly.
- Single responsibility: one focused agent beats one that does everything.

## Full template

```markdown
---
name: [ kebab-case-name ]
description: [ Use when <trigger>. What it does. "use proactively" if auto-delegated. ]
tools: Read, Grep, Glob
model: sonnet
---

You are a [role] specializing in [domain].

## When invoked

[ What the main agent delegated. The first thing to do. ]

## Method

1. [ Step ]
2. [ Step ]

## Constraints

- [ Hard limit — state the reason ]
- If uncertain about [X]: [ fallback ]
- [ Prohibition, only for a failure that actually occurs — with its reason ]

## Report format

Return to the caller:

- [ Field / section the main agent needs — be specific; only the final message is relayed ]
```

## Read-only research agent (minimal)

```markdown
---
name: [ name ]
description: Use proactively to [research task]. Read-only.
tools: Read, Grep, Glob
---

You are a [domain] research agent. Investigate [scope] and report findings.

Report: specific file references (path:line) and a one-paragraph conclusion. Do not modify files.
```
