# System Prompt — Template & Rules

## Structure rules

- XML tags (`<role>`, `<task>`, `<context>`, `<constraints>`, `<output_format>`, `<examples>`)
- Claude was trained on this pattern — XML produces more structured outputs than plain paragraphs
- Place `<context>` and `<examples>` **before** `<constraints>` / instructions
- Role: one sentence — job title + domain + key constraint
- Add an uncertainty fallback only where a wrong guess would change the output
- Lock output structure with `output_config.format` (structured outputs), **not** an assistant prefill

## Full template

```xml

<role>
    [Job title] specializing in [domain]. [Key constraint in one clause.]
</role>

<task>
[What to do. Success looks like: specific, measurable outcome.]
</task>

<context>
[Background, reference material, domain knowledge.]
</context>

<constraints>
- [Hard limit 1 — state the reason]
- [Hard limit 2 — state the reason]
- If uncertain about [X]: [fallback — ask / skip / use default]
- [Prohibition, only for a failure that actually occurs — with its reason]
</constraints>

        <!-- Add if the deliverable tends to run long or drift in scope: -->
        <!-- - Keep responses to the length the question needs; skip non-essential context. -->
        <!-- - Deliver the scope asked for. Don't quietly narrow, widen, or transform it. -->
        <!-- Do NOT add "double-check your work" / "verify before responding" — current
             models self-verify, and the instruction causes over-verification. -->

<output_format>
Format: [JSON / markdown / plain text]
Length: [word/token target or range]
Tone: [formal / conversational / technical]
Required sections: [list if applicable]
</output_format>

        <!-- Include <examples> only when the output shape is genuinely format-sensitive.
             The model matches an example's length, tone, and structure, so examples
             freeze whatever behavior they encode. -->
<examples>
<example>
    <input>[Sample input]</input>
    <output>[Ideal output — show exact style and structure]</output>
</example>
<example>
    <input>[Edge case or different category]</input>
    <output>[How to handle it]</output>
</example>
</examples>
```

## Locking output structure

**Assistant prefill is removed.** A trailing `assistant:` turn returns a 400 on Opus 4.6+, Sonnet 4.6+, Opus 5, Sonnet
5, and Fable 5. Use one of these instead:

| Goal                         | Replacement                                                     |
|------------------------------|-----------------------------------------------------------------|
| JSON / schema-shaped output  | `output_config: {format: {type: "json_schema", schema: {...}}}` |
| A fixed classification label | Tool with an `enum` field, or structured outputs                |
| No preamble                  | `<constraints>`: "Respond directly. No 'Here is...' opener."    |

```python
client.messages.create(
    model="claude-opus-5",
    max_tokens=16000,
    system=SYSTEM_PROMPT,
    output_config={"format": {"type": "json_schema", "schema": SCHEMA}},
    messages=[...],
)
```

Note: structured outputs are incompatible with citations (400).

## Minimal template (when examples are not needed)

```xml

<role>[Title] specializing in [domain]. [Key constraint.]</role>
<task>[What to do and what success looks like.]</task>
<constraints>
- [Limit]
- If uncertain: [fallback]
</constraints>
<output_format>[Format, length, tone]</output_format>
```
