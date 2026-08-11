# Prompt Engineering Principles

Universal rules that apply to every prompt type.

## Core rules

| Principle   | Rule                                                                                               |
|-------------|----------------------------------------------------------------------------------------------------|
| Order       | Stable content first, volatile content last (also what prompt caching needs)                       |
| Role        | 1 sentence: title + domain + key constraint                                                        |
| Uncertainty | Add a fallback where a wrong guess changes the output — not everywhere                             |
| Output spec | Specify format + length + tone + required sections when they are load-bearing                      |
| Examples    | Only for format-sensitive output. See "Examples cut both ways" below.                              |
| Volume      | Say it exactly once, at normal volume. See "Pressure language" below.                              |
| Minimal     | If removing a sentence wouldn't change the output, cut it — but see "What not to cut"              |
| Claude      | Literal — say exactly what you want; nothing is implied                                            |
| Structure   | XML for Claude API; Markdown for Claude Code. Gemini favors neither — pick one and stay consistent |

## Pressure language

Current models follow the system prompt closely. Emphasis written to overcome an older model's reluctance now causes
over-triggering and rigid behavior, and an anxious prompt produces a hedging model. This cuts both ways — leftover
hedges are also read literally.

| Instead of                                      | Write                                               |
|-------------------------------------------------|-----------------------------------------------------|
| `CRITICAL: You MUST use this tool when...`      | `Use this tool when...`                             |
| `If in doubt, use [tool]` / `Default to [tool]` | *(delete, or)* `Use [tool] when it would improve X` |
| `Be thorough. Do not stop early.`               | *(delete — models are proactive by default)*        |
| `Try to include a summary if possible`          | `Include a summary.`                                |
| `Don't be too verbose`                          | `Keep responses to the length the question needs.`  |

When several instructions are each marked critical, the markers stop carrying information. Emphasis is a scoped fix for
one demonstrably underweighted instruction, not a default register.

## Do not instruct self-verification

Current models verify their own work unprompted. "Double-check your answer",
"re-verify before responding", and separate verification steps now cause **over**-verification with no capability gain.
Delete them rather than rewriting them.

## Behaviors worth constraining explicitly

Add these only when the symptom is real for the deliverable:

- **Verbosity** — default responses run long. `effort` does not reliably shorten visible output; a one-line conciseness
  instruction does.
- **Scope** — deliver the scope asked for; don't quietly narrow, widen, or transform it.
- **Delegation** — subagent-capable harnesses over-delegate by default; cap the spawn count.

## What "minimal context" means

Ask for each piece of context: "Would removing this change what the AI outputs?"

- Yes → keep it
- No → cut it

Padding with loosely related content adds tokens without adding signal.

## What not to cut

Short is not the goal — the harm comes from specific outdated instructions, not from volume. Never justify a deletion by
length alone. These stay:

- **Context the model cannot know**: audience, product, environment, quality bar
- **The reasons behind constraints** — a rule without its "because" fails unpredictably
- **Tool contracts**: parameter semantics, limits, failure modes, what is *not* returned
- **Prohibitions against failures that actually occur** in this task, on this model
- **Fragile procedures**: exact commands where only one sequence is safe

A prompt that is too short produces generic output, because the model fills the gaps with safe defaults.

## Examples cut both ways

Examples are the strongest signal in a prompt: the model matches their length, tone, and structure. That makes them the
right tool for a genuinely format-sensitive output, and a liability everywhere else — an example freezes whatever
behavior it encodes, including behavior tuned for an older model.

Include examples when: the output shape is strict and hard to describe in prose. Skip them when: you are illustrating
judgment the model already has.

If you do include them:

- Cover the typical case, plus one edge case or different category
- Show the exact tone, format, and length expected
- Keep them diverse (not three near-identical inputs), and label them illustrative

## Prompts are per-model artifacts

An instruction that is load-bearing on one model generation is dead weight on the next. Establish which model the prompt
targets before writing it, and re-audit at every model release rather than accumulating the union of every generation's
workarounds.

## Uncertainty handling patterns

```
If uncertain about [X]: ask a clarifying question before proceeding
If uncertain about [X]: use [default value] and note the assumption
If uncertain about [X]: skip [section] and explain why
If the request is outside [scope]: politely decline and suggest [redirect]
```
