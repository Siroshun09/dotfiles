# Gemini API System Instruction — Template & Rules

For programmatic Gemini use, where you control request parameters as well as prompt text. For the Gemini app's saved
Gems (prompt text only), use
[gem-pattern.md](gem-pattern.md).

## Request parameters

Verify the exact SDK binding against the current Gemini API docs before shipping — this table covers intent, not syntax.

| Parameter            | Guidance                                                                                            |
|----------------------|-----------------------------------------------------------------------------------------------------|
| `system_instruction` | Where role, persona, standing context, and format rules belong                                      |
| `thinking_level`     | `minimal` / `low` / `medium` / `high`. Default is `high` on most models                             |
| `temperature`        | **Leave at the default `1.0`.** Lowering it risks looping and degraded performance on complex tasks |

**Delete legacy scaffolding.** "Think step by step", `<scratchpad>` blocks, and other chain-of-thought tricks written
for Gemini 2.5 are counterproductive on Gemini 3 — the model over-analyzes them. Control reasoning depth with
`thinking_level`, and let the prompt state the goal.

**Delete low-temperature determinism settings.** If a prompt used `temperature: 0` for predictable output, the
replacement is a tighter, more objective prompt plus
`thinking_level`, not a sampling parameter.

Model IDs move quickly (`gemini-3.1-pro-preview`, `gemini-3-flash-preview`,
`gemini-3.1-flash-lite`, …). Confirm the current ID rather than reusing one from an older prompt.

## Structure rules

- **Be direct and concise.** Gemini 3 responds best to clear, short instructions and over-analyzes elaborate prompt
  engineering.
- **Gemini 3 is terse by default.** A conversational or detailed voice must be requested explicitly.
- **Objective constraints only** — "3 sentences or less", not "brief".
- **Instruction placement:** with a large data payload (a document, a codebase, a transcript), put the instruction or
  question *after* the data, and open it with
  "Based on the preceding information, ...". Short prompts can lead with the ask.
- Markdown or XML both work; the docs favor neither. Pick one and stay consistent.

## Full template

```markdown
## Persona
[Job title + domain + the one constraint that matters most.]

## Task
[What to do, and what success looks like — specific and checkable.]

## Context
[Domain knowledge, audience, prior decisions, reference material.]

## Format
Length: [objective — e.g. "3 sentences or less", "under 200 words"]
Structure: [required sections / schema / table columns]
Tone: [explicit — the default is terse and direct]

## Boundaries
- If uncertain about [X]: [ask / state the assumption / use a default]
- [Prohibition, only for a failure that actually occurs — with its reason]
```

## Grounding (retrieval / document QA)

Google publishes a strict-grounding instruction for this case — use it verbatim when the model must not supplement the
supplied context:

```markdown
You are a strictly grounded assistant limited to the information provided in the
User Context. In your answers, rely only on the facts that are directly mentioned
in that context. You must not access or utilize your own knowledge or common sense
to answer.
```

## Time awareness

For time-sensitive queries and tool-calling agents:

```markdown
Your knowledge cutoff date is [cutoff]. For time-sensitive user queries that require
up-to-date information, you MUST follow the provided current time (date and year)
when formulating search queries in tool calls. Remember it is [year] this year.
```
