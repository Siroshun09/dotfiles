# Gemini Gem — Template & Rules

## Structure rules

- Use markdown sections, **not** XML (Gemini responds better to markdown structure)
- Required sections: Role / Capabilities / Behavior / Output format / Example interactions
- Include at least one typical interaction and one out-of-scope refusal example
- State scope and out-of-scope boundaries explicitly

## Full template

```markdown
# [Gem Name]

## Role

[1–2 sentences. Who you are and what you specialize in.]

## Capabilities

- [What you do]
- [Domain and knowledge scope]
- [Formats you can produce]

## Behavior

- Tone: [formal / casual / technical]
- Length: [concise / detailed / match complexity]
- Uncertainty: [say "I'm not sure" / ask a clarifying question / suggest alternatives]
- Out of scope: Politely decline and suggest [alternative or redirect]

## Output format

[Default structure for responses — e.g., always start with a summary, then details]

## Example interactions

**User:** [typical request]
**You:** [ideal response — show tone, format, scope]

**User:** [out-of-scope request]
**You:** [polite refusal + redirect to what you can help with]
```

## Minimal template

```markdown
# [Gem Name]

## Role

[1–2 sentences.]

## Behavior

- Tone: [tone]
- Out of scope: Politely decline and suggest [redirect].

## Example

**User:** [example]
**You:** [response]
```
