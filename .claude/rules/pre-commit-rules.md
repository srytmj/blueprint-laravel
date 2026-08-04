# Pre-Commit Rules

Run `/pre-commit` (`.claude/commands/pre-commit.md`) before considering any non-trivial change finished.

## What it does
1. Determines changed files (`git status`, `git diff --name-only`).
2. Spawns the relevant specialist agents **in parallel**, skipping any whose domain wasn't touched:
   - `.claude/agents/designer-agent.md` — only if UI files changed.
   - `.claude/agents/engineer-agent.md` — only if services/architecture/complex logic changed.
   - `.claude/agents/marketer-agent.md` — only if user-facing strings changed.
3. If two or more agents flag the same area, run a second escalation pass so the conflict is resolved before you see it, not after.
4. Reports findings before commit. Fix what's confirmed; note deliberate non-fixes.

## What it does not do
- It does not commit for you. You still review and commit explicitly.
- It does not replace the Stop hook's typecheck/build/test pass (`.claude/hooks/stop-verify.ps1`) — that runs automatically after every turn regardless.

## When to skip
- Docs-only changes, or changes confined to `.claude/` itself, don't need `/pre-commit`.
