# Prompt Engineering Principles

Universal rules that apply to every prompt type.

## Core rules

| Principle   | Rule                                                       |
|-------------|------------------------------------------------------------|
| Order       | Context and examples **before** instructions               |
| Role        | 1 sentence: title + domain + key constraint                |
| Uncertainty | Always include explicit fallback ("if unsure, do X")       |
| Output spec | Always specify: format + length + tone + required sections |
| Examples    | 3–5 diverse examples. Highest ROI for output consistency.  |
| Minimal     | If removing a sentence wouldn't change the output, cut it  |
| Claude 4.x  | Literal — say exactly what you want; nothing is implied    |
| Structure   | XML for Claude API, Markdown for Gemini                    |

## What "minimal context" means

Ask for each piece of context: "Would removing this change what the AI outputs?"

- Yes → keep it
- No → cut it

Padding with loosely related content adds tokens without adding signal.

## Example quality checklist

Good examples:

- Cover the typical case
- Cover at least one edge case or different category
- Show the exact tone, format, and length expected
- Are diverse (not three near-identical inputs)

## Uncertainty handling patterns

```
If uncertain about [X]: ask a clarifying question before proceeding
If uncertain about [X]: use [default value] and note the assumption
If uncertain about [X]: skip [section] and explain why
If the request is outside [scope]: politely decline and suggest [redirect]
```
