# Claude Code Subagent (.claude/agents/*.md) — Template & Rules

A subagent is a markdown file the main agent **delegates to**. The frontmatter
controls discovery and tooling; the body **is** the subagent's system prompt.

Location: `.claude/agents/<name>.md` (project) or `~/.claude/agents/<name>.md` (user).

## Frontmatter fields

| Field         | Required | Notes                                                                  |
|---------------|----------|------------------------------------------------------------------------|
| `name`        | Yes      | Unique identifier. Lowercase letters and hyphens only.                 |
| `description` | Yes      | When to delegate. Drives auto-invocation — write it like a trigger.    |
| `tools`       | No       | Comma-separated allowlist. Omit to inherit all tools.                  |
| `model`       | No       | `sonnet` / `opus` / `haiku` / `inherit`. Omit for the default.         |

## Body rules

- The body is a **system prompt for a fresh agent** — it starts with no
  conversation context. State the role, scope, and method from scratch.
- Write `description` for delegation: lead with trigger conditions ("Use when…",
  "MUST BE USED for…"). Add "use proactively" to encourage auto-delegation.
- Scope `tools` to the minimum the job needs — read-only agents should not get
  `Edit`/`Write`/`Bash`. Narrower tools = safer, faster delegation.
- Define what the subagent **returns** to the main agent — it only relays its
  final message, so specify the report format explicitly.
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
- [ Hard limit ]
- If uncertain about [X]: [ fallback ]
- Never: [ absolute prohibition ]

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

Report: specific file references (path:line) and a one-paragraph conclusion.
Do not modify files.
```
