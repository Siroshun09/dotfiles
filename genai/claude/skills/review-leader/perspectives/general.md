# General review (placeholder)

> Placeholder perspective so the skill is runnable end to end. Replace with the real
> perspective set (one file per axis). Each file is one reviewer's mandate.

Review the change for:

- **Correctness** — logic errors, wrong conditions, off-by-one, unhandled errors, broken
  edge cases, incorrect API/contract usage.
- **Reuse & simplification** — duplication, reinventing existing helpers, dead code, needless
  complexity that a simpler form would replace.
- **Efficiency** — obvious wasted work, N+1 patterns, redundant allocations or I/O in hot paths.

Flag only issues caused or exposed by this change. Cite the exact file and line. When a fix is
clear, give a concrete suggestion.