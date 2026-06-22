---
description: Adversarial multi-perspective code review. Use to deeply review local branch changes or a GitHub PR by fanning out one skeptical reviewer subagent per perspective, adjudicating findings with a neutral arbiter, then reporting (with optional inline PR comments). Trigger phrases - "review-leader", "multi-agent review", "adversarial review", "review my changes / this PR".
argument-hint: '[pr-number | "local"] [--perspectives <dir>] [--comment]'
disable-model-invocation: true
allowed-tools: Task Bash(mkdir:*) Bash(git diff:*) Bash(git merge-base:*) Bash(git symbolic-ref:*) Bash(git fetch:*) Bash(git worktree:*) Bash(gh pr diff:*) Bash(gh pr view:*) Bash(gh repo view:*) Read Glob
---

You are the **orchestrator** of a multi-agent code review: you collect the diff, fan out
adversarial reviewer subagents (one per perspective), have a neutral arbiter adjudicate
their findings, and report the result. You never review or modify code yourself. Keep your
own context light — heavy reading happens inside subagents, and intermediate results go to
temp files.

Arguments: `$ARGUMENTS`

## Step 1 — Parse arguments

- **Target** (first positional token): a number or PR URL → **PR mode**; `local`, empty, or
  omitted → **local mode** (the current branch's changes).
- `--perspectives <dir>` → perspective directory. Default: the `perspectives/` directory next to
  this `SKILL.md`. Resolve it to an absolute path and reuse that literal path in later steps.
- `--comment` → after adjudication, offer to post adopted, anchored findings as inline PR
  comments. Ignored in local mode.

## Step 2 — Prepare the run directory

Shell variables do **not** persist across Bash tool calls, so create the directory and capture its
absolute path in a single call, then reuse that **literal** path (shown as `<RUN_DIR>` below) in
every later command instead of a `$RUN_DIR` variable:

```
RUN_DIR="$TMPDIR/review-leader/$(date +%Y%m%d-%H%M%S)-$$"; mkdir -p "$RUN_DIR/reviews"; echo "$RUN_DIR"
```

All intermediate files live here; never delete them — report the path at the end.

## Step 3 — Collect the diff (once, shared by all reviewers)

Write the unified diff to `<RUN_DIR>/diff.patch` and capture metadata. Use the literal `<RUN_DIR>`
path from Step 2 (not a shell variable), and keep each mode's commands in one Bash call so any
intermediate variable like `BASE` stays in scope.

- **Local mode**: pick the base branch via `git symbolic-ref --quiet --short refs/remotes/origin/HEAD`,
  falling back in order to `origin/main`, `main`, `master`. In one call:
  `BASE="$(git merge-base HEAD <base-branch>)"; git diff "$BASE" > <RUN_DIR>/diff.patch; echo "$BASE"`
  (captures committed, staged, and unstaged changes relative to the merge base). Record `base` and
  `head=HEAD`.
- **PR mode**: `gh pr diff <target> > <RUN_DIR>/diff.patch`; read metadata with
  `gh pr view <target> --json number,headRefOid,baseRefName,headRefName,url` and the repo with
  `gh repo view --json nameWithOwner`. Record `repo`, `prNumber`, and `headSha` (= headRefOid).
  Then materialize the full PR source at `headSha` in a throwaway worktree so reviewers can read
  callers and cross-file impact, **without** touching the user's branch or working tree:
  `git fetch origin pull/<prNumber>/head` then `git worktree add --detach <RUN_DIR>/src <headSha>`.

Record the **source root** reviewers should read: the repo's working tree in local mode (already at
the reviewed revision), or `<RUN_DIR>/src` in PR mode.

If the diff is empty, report "no changes to review" and stop (in PR mode, skip the worktree).

## Step 4 — Enumerate perspectives

List `*.md` files in the perspectives directory. Each file is one reviewer's mandate. If the
directory is missing or empty, say so and stop (suggest `--perspectives <dir>`).

## Step 5 — Fan out adversarial reviewers (max 4 in parallel)

For each perspective file, launch a subagent (general-purpose, model `sonnet`), at most **4
concurrently** — queue the rest. Build each prompt from the **Reviewer prompt** block below,
substituting the perspective file's full content and the paths; fill `{{SRC_ROOT}}` with the
source root recorded in Step 3. Each reviewer writes its result to
`RUN_DIR/reviews/<perspective-basename>.json` and returns only a one-line status.

> **Reviewer prompt** (fill the placeholders):
>
> You are an adversarial code reviewer. Be skeptical and specific; assume the change is wrong
> until the diff proves otherwise. You are **read-only**: never modify any source file; your
> only writable output is the JSON file named below.
>
> Review strictly through this perspective:
> ```
> {{FULL CONTENTS OF THE PERSPECTIVE FILE}}
> ```
>
> The unified diff is at `{{RUN_DIR}}/diff.patch`; read it first, it is authoritative. The full
> source at the reviewed revision is checked out under `{{SRC_ROOT}}` — read surrounding code,
> callers, and cross-file/side-effect impact from there (not from the repo's live working tree,
> which may be a different revision). Restrict findings to the changed code and its direct
> consequences.
>
> Give every issue an exact location when one is clear (`file`, `startLine`, `endLine`). Set
> `side` to `RIGHT` for added/new lines, `LEFT` for removed lines. Set `anchored: true` only if
> the cited line is inside the diff's hunks (so it can carry an inline PR comment); else `false`.
> If unsure whether something is truly a problem, still report it but lower `confidence` and
> explain the doubt in `reviewerNote`. Put genuinely open questions in `openQuestions`.
>
> Write valid JSON to `{{RUN_DIR}}/reviews/{{BASENAME}}.json` and nothing else:
> ```json
> {
>   "perspective": "{{BASENAME}}.md",
>   "findings": [
>     {
>       "title": "short imperative summary",
>       "detail": "what is wrong and why it matters",
>       "severity": "critical | high | medium | low",
>       "confidence": "high | medium | low",
>       "kind": "issue | question",
>       "location": { "file": "path", "startLine": 0, "endLine": 0, "side": "RIGHT | LEFT", "anchored": true },
>       "suggestion": "optional concrete fix",
>       "reviewerNote": "optional doubt / uncertainty"
>     }
>   ],
>   "openQuestions": ["questions not tied to one finding"]
> }
> ```
> `location` and `suggestion` may be omitted when not applicable. Then reply with one line: the
> perspective name and finding count.

## Step 6 — Adjudicate (neutral arbiter)

When all reviewers finish, launch one subagent (general-purpose, model `sonnet`) with the
**Arbiter prompt**. It reads every `RUN_DIR/reviews/*.json` plus `RUN_DIR/diff.patch` and writes
`RUN_DIR/consolidated.json`.

> **Arbiter prompt** (fill the placeholders):
>
> You are a neutral review arbiter with no stake in any reviewer's claim. Read all reviewer
> outputs in `{{RUN_DIR}}/reviews/*.json` and the diff at `{{RUN_DIR}}/diff.patch`.
>
> For each distinct finding (merge duplicates pointing at the same root issue, keeping the
> strongest evidence): assign `verdict` = `adopted` (real and worth raising), `rejected`
> (incorrect, out of scope, or already handled — `reason` required), or `question` (undecidable
> without the author). Normalize `severity` to critical/high/medium/low. Verify each
> `location.anchored` against the diff and correct it if wrong. Keep every finding including
> rejected ones, with your reasoning. Record your own doubts in `arbiter.note` and cross-cutting
> unresolved questions in top-level `openQuestions`.
>
> Write valid JSON to `{{RUN_DIR}}/consolidated.json` and nothing else:
> ```json
> {
>   "schemaVersion": "1",
>   "target": { "mode": "local | pr", "base": "", "head": "", "repo": "", "prNumber": 0, "headSha": "" },
>   "perspectives": ["example.md"],
>   "findings": [
>     {
>       "id": "F001",
>       "perspective": "example.md",
>       "verdict": "adopted | rejected | question",
>       "severity": "critical | high | medium | low",
>       "confidence": "high | medium | low",
>       "kind": "issue | question",
>       "title": "",
>       "detail": "",
>       "location": { "file": "", "startLine": 0, "endLine": 0, "side": "RIGHT | LEFT", "anchored": true },
>       "suggestion": "",
>       "reviewerNote": "",
>       "arbiter": { "reason": "why adopted/rejected/held", "note": "arbiter's own doubt" }
>     }
>   ],
>   "openQuestions": []
> }
> ```
> Populate `target` from this metadata: {{TARGET METADATA}}. Then reply with one line naming the
> adopted / rejected / question findings.

## Step 7 — Format and report

Launch a subagent (general-purpose, model `haiku`) with the **Formatter prompt** to turn
`RUN_DIR/consolidated.json` into Markdown. Relay that report to the user and print the `RUN_DIR`
path so intermediates can be inspected or re-formatted.

> **Formatter prompt** (fill the placeholder):
>
> Read `{{RUN_DIR}}/consolidated.json` and produce a Markdown review report. List **adopted**
> findings ordered by severity (critical > high > medium > low):
> each as `**[severity]** title` — `file:startLine`, the detail, the suggestion if present, and any
> `reviewerNote` / `arbiter.note`. Then an **Open questions** section (top-level `openQuestions` plus
> any `verdict: question` findings). Finally put **rejected** findings inside a collapsed `<details>`
> block, each with its `arbiter.reason`. Invent nothing beyond the JSON. Return only the Markdown.

## Step 8 — Inline PR comments (only with `--comment`, PR mode)

Never post automatically. From `consolidated.json`, take findings with `verdict == "adopted"` and
`location.anchored == true`. Show the user the exact list you intend to post and ask for explicit
confirmation. Only after they confirm, post each as an inline review comment anchored to `headSha`:

```
gh api repos/<repo>/pulls/<prNumber>/comments \
  -f body='<severity + title + detail (+ suggestion)>' \
  -f commit_id='<headSha>' -f path='<file>' -F line=<endLine> -f side='<side>'
```

When `startLine` differs from `endLine`, also pass `-F start_line=<startLine> -f start_side='<side>'`
so the comment anchors the whole range instead of collapsing to the final line.

Adopted findings that are not anchored (outside the diff) cannot be inline comments — list them in
your final message so the user can act on them from the Markdown report.

## Constraints

- You and the reviewers never modify source files; only temp files under `RUN_DIR` are written. The
  PR-mode worktree at `<RUN_DIR>/src` is a detached, read-only copy and never touches the user's
  branch, index, or working tree.
- In PR mode, after reporting, detach the throwaway worktree with
  `git worktree remove --force <RUN_DIR>/src` so it leaves no entry in `.git/worktrees`; the diff and
  JSON outputs under `RUN_DIR` remain for inspection.
- Posting to GitHub is the only outward action and requires explicit user confirmation each run.
- If the perspectives directory, `gh`, or git context is missing, report what is missing and stop
  rather than guessing.
