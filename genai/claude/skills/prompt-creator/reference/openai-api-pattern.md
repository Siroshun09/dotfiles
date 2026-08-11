# OpenAI API System / Developer Instruction — Template & Rules

For programmatic OpenAI use, where you control request parameters as well as prompt text. For ChatGPT's saved Custom
GPTs (prompt text only), use
[custom-gpt-pattern.md](custom-gpt-pattern.md).

## Request parameters

Verify the exact SDK binding and current model IDs against the OpenAI docs before shipping — parameter nesting differs
between the Responses API and Chat Completions, and the model line moves quickly.

| Parameter          | Guidance                                                                                                                                      |
|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| `reasoning.effort` | `none` / `low` / `medium` / `high` / `xhigh` / `max`. Default `medium`. Controls how hard the model thinks **and how eagerly it calls tools** |
| `text.verbosity`   | `low` / `medium` / `high` — length of the final answer, not of the thinking                                                                   |
| Structured outputs | `json_schema` with `strict: true` for a guaranteed response shape                                                                             |
| Prompt caching     | `prompt_cache_options.ttl` (replaces the older `prompt_cache_retention`)                                                                      |

Current model line at time of writing: `gpt-5.6-sol` (flagship), `gpt-5.6-terra`
(balanced cost/performance), `gpt-5.6-luna` (efficient, high-volume). The bare
`gpt-5.6` alias resolves to `gpt-5.6-sol`. Confirm the current ID rather than reusing one from an older prompt.

**Tuning `reasoning.effort`:** keep the setting the previous model used, then test **that setting and one level
lower** — 5.6 often holds or improves quality at fewer tokens. Reserve `max` (new in 5.6) for quality-first workloads.
Effort is also the lever for agentic scope: lowering it reduces exploration depth and tool-calling eagerness, improving
latency without a prompt rewrite.

**Verbosity has two levers.** `text.verbosity` sets the global default; the prompt overrides it per context. Use the
parameter for the baseline, prose for the exception.

> **There is no GPT-5.6 cookbook prompting guide.** The per-version cookbook series
> stops at GPT-5.2; 5.6-specific guidance lives in the API docs' *Model guidance* page.
> Read the 5.2 guide for general reasoning-model technique, and the Model guidance page
> for anything version-specific.

## Structure rules

- **Goal + constraints + output contract, not a step script.** Reasoning models work best given a clear goal, strong
  constraints, and an explicit output contract — without prescribing every intermediate step.
- **Delete "think step by step" and `<scratchpad>` scaffolding.** Reasoning happens internally; `reasoning.effort` is
  the control surface. Prescriptive step-by-step framing now works against the model.
- **Lean prompts win, measurably.** OpenAI's internal testing put leaner system prompts at roughly **10–15% higher eval
  scores with 41–66% fewer total tokens**. Concretely:
  state each instruction **once** (including approval-related language), drop repeated instructions and redundant
  examples, and cut generic tool descriptions down to concise and precise ones.
- **Re-test blanket brevity instructions.** 5.6 is more concise by default than 5.5, so a "Be concise" / "Keep it short"
  carried over from an older model may now be dead weight. Set `text.verbosity` and check whether the prose rule still
  earns its place.
- **Objective constraints only** — "3 bullets", not "keep it short".
- **Markdown or XML both work.** Pick one and stay consistent; contradictory or duplicated instructions cost more here
  than in a non-reasoning model.

## Full template

```markdown
# Role
[Job title + domain + the one constraint that matters most.]

# Task
[What to do, and what success looks like — specific and checkable.]

# Context
[Domain knowledge, audience, prior decisions, reference material.]

# Output contract
- Format: [schema / sections / structure]
- Length: [objective constraint, if the verbosity parameter is not enough]
- Tone: [only if it must deviate from the default]

# Boundaries
- If uncertain about [X]: [ask / state the assumption / use a default]
- [Prohibition, only for a failure that actually occurs — with its reason]
```

## Multi-turn reasoning continuity

Reasoning items must survive between turns or the model re-derives work you already paid for:

- **Stateful:** pass `previous_response_id` and let the API carry reasoning forward.
- **Stateless (`store: false`):** preserve **every** output item — including encrypted reasoning and assistant items —
  and replay the full history on the next request.
- **Tool loops:** pass back any reasoning items returned alongside the last function call, not just the message text.

Persisted-reasoning defaults changed with 5.6: **5.6 models default to `all_turns`**, earlier models to `current_turn`.
If a prompt was tuned against `current_turn`
behavior, re-baseline rather than assuming the carried-over reasoning is free.

## Tool design

Tool descriptions are part of the prompt and follow the same lean rule: concise and precise, no generic boilerplate.
**Programmatic Tool Calling (PTC)** lets the model write JavaScript to call eligible tools, pass results between them,
and process intermediate output — use it for bounded workflows with several sequential operations. Prefer direct,
non-PTC calls when one call is sufficient, or when results need approval.

## Structured output

Prefer a `json_schema` response format with `strict: true` over prose instructions telling the model to emit JSON.
Describe the *task* in the prompt and let the schema carry the shape — restating the schema in prose is the kind of
duplication that degrades reasoning-model performance.
