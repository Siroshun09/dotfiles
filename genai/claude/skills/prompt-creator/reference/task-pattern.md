# Claude Code Task Prompt — Template & Rules

A task prompt is a **one-shot work request** pasted into a live Claude Code
session. It runs once, in the current session, and may rely on the conversation
and repo state already in context — it is not a reusable, auto-invoked
definition.

Claude Code is an autonomous agent with tools (Read, Edit, Bash, Grep, Glob,
etc.). A good task prompt tells it **what done looks like** and **how to verify**,
then lets it choose the steps.

## Investigate first

A task prompt is only as good as its grounding in the actual repo. Before
drafting, use Read/Grep/Glob to fill these from reality, not assumption:

- **Scope** — the real files/modules the task touches (don't guess paths).
- **Verify** — the project's test / build / lint commands (package.json scripts,
  Makefile, CI config, etc.).
- **Context** — existing patterns and conventions the work must follow (libraries
  already in use, structure, naming).

Then ask the user only for intent that investigation cannot reveal: completion
priorities, hard scope boundaries, and any genuinely ambiguous requirement.

## Structure rules

- Lead with the **goal** (the outcome), not a step list. Let the agent plan.
- **Scope explicitly**: name the target files/area, and state what NOT to touch.
- Give **verification**: the test/build/run command that proves it works.
- Define **done**: a concrete completion condition, not "improve X".
- Claude 4.x is literal — state constraints outright; nothing is implied.
- Add steps only when order is load-bearing; otherwise omit and trust the agent.
- Markdown headings, not XML — this is a chat message, not an API system prompt.

## Common pitfalls

- Vague goal ("clean up the code") → no completion signal. Bound it.
- No verification → the agent can't self-check; it guesses and reports done.
- Over-specified steps → the agent follows a bad plan instead of a better one.
- Silent scope → the agent edits unrelated files. State boundaries.

## Full template

```markdown
## Goal
[ The outcome. "Done" = a specific, observable state. ]

## Scope
- Target: [ files / module / area ]
- Out of scope: [ what to leave untouched ]

## Context
[ Background the agent can't infer: constraints, prior decisions, the why.
  Skip anything already visible in the repo or this conversation. ]

## Verify
[ Command(s) that prove success: tests, build, lint, run. ]

## Done when
- [ Concrete condition 1 ]
- [ Concrete condition 2 ]
```

## Minimal template (small, well-scoped task)

```markdown
[ One-sentence goal naming the target file/area. ]
Verify with `[ command ]`. Don't touch [ boundary ].
```

## Example

```markdown
## Goal

`POST /users` returns 400 with a field-level error when `email` is malformed,
instead of the current 500.

## Scope

- Target: src/handlers/users.ts, src/validation/
- Out of scope: the DB layer and other endpoints

## Context

We use zod for request validation elsewhere — follow that pattern, don't add a
new validation library.

## Verify

`npm test -- users` — add a failing case for a bad email first.

## Done when

- New test covers the malformed-email case and passes
- Existing user tests still pass
```