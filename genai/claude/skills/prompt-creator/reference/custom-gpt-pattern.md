# ChatGPT Custom GPT — Template & Rules

A Custom GPT is a saved configuration in ChatGPT: Name, Description, Instructions, Conversation starters, optional
Knowledge files, built-in Capabilities, and Actions. There are no model parameters — everything is prompt text. For the
OpenAI API (`reasoning.effort`, `text.verbosity`, structured outputs), use
[openai-api-pattern.md](openai-api-pattern.md) instead.

## Configure fields

| Field                 | Notes                                                                                |
|-----------------------|--------------------------------------------------------------------------------------|
| Name                  | Clear and descriptive — it is the first trigger a user reads                         |
| Description           | What it does **and when to use it**. Drives discovery, not behavior                  |
| Instructions          | The actual prompt: role, workflow, tone, boundaries                                  |
| Conversation starters | Optional example prompts shown on open. Use them to steer first use                  |
| Knowledge             | Reference material to draw from: docs, guides, handbooks                             |
| Capabilities          | Web search / canvas / image gen / code interpreter — enable only what the task needs |
| Actions               | External API calls. Add last, after instructions are already solid                   |

## Structure rules

- **Write it like onboarding a new teammate**: clear role, the must-do rules, and the handful of examples that pin down
  what "good" looks like.
- **Multi-step workflows get explicit step structure**, with clear delimiters between sections. Use headings and lists
  so priorities and order are visually distinct.
- **Prefer positive, concrete instructions** ("Do X") over long prohibition lists ("Don't do Y"). Keep a prohibition
  only when the failure actually occurs, and say why.
- **Include short accept/reject examples when the GPT applies a specific definition or classification** — this is the
  case where examples earn their cost. Skip them when you are illustrating judgment the model already has.
- **Objective constraints over relative ones** — "3 bullets", not "keep it short".
- Instructions are the cheap lever: **tighten instructions and add examples before adding Actions or Capabilities.**
  More tools rarely fix a behavior problem.

## Full template

```markdown
# Role

[Who this GPT is and what it specializes in. One or two sentences.]

# Task

[What it does on every invocation, and what "done" looks like.]

# Context

[Background it cannot infer: domain, audience, prior decisions, constraints. If Knowledge files are attached, say what they are and when to consult them.]

# Workflow

1. [Step — only if order is load-bearing]
2. [Step]

# Output

- Format: [structure / sections / schema]
- Length: [objective — "3 bullets", "under 200 words"]
- Tone: [explicit]

# Boundaries

- If the request is ambiguous: ask one clarifying question before answering.
- Out of scope: politely decline and suggest [redirect].
```

## Minimal template

```markdown
# Role

[1–2 sentences.]

# Task

[What it does every time.]

# Output

- Format: [structure]
- Length: [objective constraint]

# Boundaries

- Out of scope: politely decline and suggest [redirect].
```

## Optional blocks — add only when the condition applies

**Knowledge files attached.** Ground the GPT so it does not silently answer from general knowledge when the uploaded
material should govern:

```markdown
Answer from the attached knowledge files first. If they do not cover the question, say so explicitly before offering
general guidance, and label which part came from outside the files.
```

**Classification / definition tasks** — the case where examples pay for themselves:

```markdown
# Examples

Acceptable: [example that meets the definition] — [why]
Not acceptable: [near-miss] — [why it fails]
```

## Before shipping

Use the built-in **Preview** with real prompts, not invented ones: check tone, accuracy, and whether the boundaries
hold. Drafting a first version with ChatGPT itself is fine — but review and cut what it added that does not change the
output.
