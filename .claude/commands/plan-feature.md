---
description: Enter Plan-Mode-first workflow for a non-trivial change
---

Default workflow for anything non-trivial (new feature, multi-file change, architectural decision, unclear scope):

1. Enter Plan Mode. While in it, only read files and explore — no edits outside the plan file.
2. If root-causing a bug, run `.claude/agents/investigator-agent.md` first and fold its findings into the plan.
3. Write a plan that has one scope: what will change, which files, why this approach over alternatives, how it'll be verified.
4. Get explicit user approval on the plan before writing any code.
5. Implement exactly the approved scope. If you discover mid-implementation that the scope needs to grow, stop and re-plan rather than quietly expanding it.
6. One plan = one scope = one commit. Don't bundle unrelated changes into the same plan/commit.
7. On completion: run `/pre-commit` if code changed, then add the `DECISION-LOG.md` entry per `.claude/rules/decision-log-rules.md`.
