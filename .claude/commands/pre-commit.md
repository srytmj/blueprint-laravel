---
description: Run specialist reviewers in parallel before committing
---

Run the pre-commit review described in `.claude/rules/pre-commit-rules.md`:

1. Get the set of changed files (`git status`, `git diff --name-only`).
2. Decide which specialist agents apply based on those files:
   - UI files touched → spawn `.claude/agents/designer-agent.md`
   - Services/architecture/logic touched → spawn `.claude/agents/engineer-agent.md`
   - User-facing strings touched → spawn `.claude/agents/marketer-agent.md`
   - Skip any agent whose domain wasn't touched — don't run it "just in case".
3. Spawn the applicable agents in parallel (single batch, not sequential).
4. If two agents raise overlapping or conflicting findings, run one escalation pass reconciling them before reporting.
5. Present a single consolidated findings list, most severe first. For each: file, the issue, why it matters.
6. Apply fixes for confirmed issues. For anything deliberately left as-is, say why (this becomes the Trade-offs line in the DECISION-LOG entry).
7. Do not commit automatically — stop after reporting/fixing and let the user review.
