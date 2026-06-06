# System Prompt — Template & Rules

## Structure rules

- XML tags (`<role>`, `<task>`, `<context>`, `<constraints>`, `<output_format>`, `<examples>`)
- Claude was trained on this pattern — XML produces more structured outputs than plain paragraphs
- Place `<context>` and `<examples>` **before** `<constraints>` / instructions
- Role: one sentence — job title + domain + key constraint
- Always include an uncertainty fallback in `<constraints>`
- Prefill `assistant:` turn to lock output structure (API only)

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
- [Hard limit 1]
- [Hard limit 2]
- If uncertain about [X]: [fallback — ask / skip / use default]
- Never: [absolute prohibition]
</constraints>

<output_format>
Format: [JSON / markdown / plain text]
Length: [word/token target or range]
Tone: [formal / conversational / technical]
Required sections: [list if applicable]
</output_format>

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

## Prefill pattern (API `assistant:` turn)

Locks output structure before Claude generates:

```
# For JSON:
assistant: {"

# For markdown with required header:
assistant: # Summary
```

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
