# Project: {PROJECT_NAME}
Initialized: {SETUP_DATE}

<!-- STACK_START -->
## Stack
- Backend: [TBD - run bash sync.sh after writing docs/SRS.md]
- Frontend: [TBD]
- Database: [TBD]
- Infra: [TBD]
<!-- STACK_END -->

---

## Routing (read on demand, not up front)

- When writing code → Read `.claude/rules/coding-rules.md`
- When building UI → Read `.claude/rules/ui-rules.md`
- Before committing → Read `.claude/rules/pre-commit-rules.md`, run `/pre-commit`
- After completing a task → Read `.claude/rules/decision-log-rules.md`
- When investigating a bug → Read `.claude/agents/investigator-agent.md` (read-only root cause pass, before any fix)
- When adding a new module/service → Read `.claude/skills/new-module.md`
- When wiring an external integration → Read `.claude/skills/add-integration.md`
- When writing user-facing copy → Read the relevant `.claude/writing-styles/*.md`
- When starting a session → Read `SCRATCHPAD.md` and the last 5 entries of `DECISION-LOG.md`
- Every 1-2 weeks, or when asked → Run `/retrospective`

---

## Always-On Rules

1. Code lives in `code/` only. Docs live in `docs/` only.
2. Use Plan Mode by default for any non-trivial change (`.claude/commands/plan-feature.md`). One plan = one scope = one commit.
3. Never read or write secret/credential files (`.env*`, keys, certs) — this is also enforced by a hook.
4. After finishing a task, append an entry to `DECISION-LOG.md` (see decision-log-rules.md), and if it closed an open item in `SCRATCHPAD.md`, move it to `ARCHIVE.md` immediately — don't batch this later.
5. `SCRATCHPAD.md` is for open work only (active tasks, blockers). Durable facts and preferences belong in Claude's memory, not here.
6. Never modify `.claude/hooks/` or `.claude/settings.local.json` unless explicitly asked.
