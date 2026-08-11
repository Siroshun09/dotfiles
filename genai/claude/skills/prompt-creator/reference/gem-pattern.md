# Gemini Gem — Template & Rules

A Gem is a saved instruction set in the Gemini app: a name, an instruction body, and optional knowledge files. There are
no model parameters — everything is prompt text. For the Gemini API (`system_instruction`, `thinking_level`,
`temperature`), use
[gemini-api-pattern.md](gemini-api-pattern.md) instead.

## Structure rules

- Markdown sections. Gemini's docs neither require nor forbid XML; markdown reads cleanly in the plain-text instruction
  box, so prefer it — but don't claim XML fails.
- Follow Google's documented four components: **Persona / Task / Context / Format**. You need not use all four, but each
  one you add strengthens the result.
- **Task is the one most often missed.** "What the Gem can do" is not the same as
  "what the Gem should do every time it is invoked". Write both.
- **Objective constraints only.** Gemini's docs call out relative qualifiers with no measurable definition. Write "3
  sentences or less", not "concise" / "brief" /
  "match the complexity of the question".
- **Gemini is terse by default.** If you want a warm, chatty, or expansive voice, say so explicitly — the model will not
  supply it on its own.
- State scope and out-of-scope boundaries explicitly.

## Full template

```markdown
# [Gem Name]

## Persona

[Role and how to respond. Gemini answers directly and briefly by default — if you want a warm or conversational voice, instruct it here explicitly.]

## Task

[What this Gem does or produces on every invocation.]

## Context

[Background it cannot infer: domain, audience, prior decisions, constraints. If knowledge files are attached, say what they are and how to use them.]

## Format

[Objective constraints only — "3 sentences or less", "a markdown table with columns X and Y", "always open with a one-line summary". Not "concise" / "detailed" / "match complexity".]

## Boundaries

- Uncertainty: [ask a clarifying question / state the assumption / say "I'm not sure"]
- Out of scope: politely decline and suggest [redirect].
```

## Minimal template

```markdown
# [Gem Name]

## Persona

[1–2 sentences.]

## Task

[What it does every time.]

## Boundaries

- Out of scope: politely decline and suggest [redirect].
```

## Optional blocks — add only when the condition applies

**Knowledge files attached.** Gems that ignore their uploaded documents are a common complaint; an explicit grounding
clause is Google's documented remedy.

```markdown
Rely only on facts stated directly in the attached files and in this conversation. Do not fall back on outside knowledge
or general reasoning to fill gaps. If the files do not cover something, say so.
```

**Time-sensitive subject matter.**

```markdown
It is currently [year]. For questions that depend on up-to-date information, follow the current date rather than your
training data.
```

**Long pasted context in the chat turn** (not the instruction body): put the question *after* the data and anchor it —
"Based on the preceding information, ...".

**Examples.** Include them only when the output shape is strict and hard to describe in prose. An example fixes the
length, tone, and structure it encodes, and Gemini over-analyzes prompt scaffolding written for older models. An
out-of-scope refusal does *not* need an example — the one-line `Boundaries` rule covers it.

```markdown
## Example

**User:** [request whose exact output shape matters]
**You:** [the ideal output — illustrative, not a template to copy verbatim]
```

## Authoring aid

The Gem editor has a **"Use Gemini to re-write instructions"** button: write the goal in a sentence or two, expand it,
then review and cut what the model added that does not change the output. Do not ship the expansion unread.
