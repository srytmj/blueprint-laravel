# Skill: Add a new module/service

Generic recipe for adding a self-contained unit of functionality to `code/`, regardless of stack.

1. Check `docs/SRS.md` / `docs/PRD.md` for the requirement this module serves. If it's not documented and it's non-trivial, that's a sign to update those docs first.
2. Look for an existing module of the same kind in `code/` and follow its structure/naming/error-handling conventions instead of inventing a new pattern.
3. Keep the module boundary narrow: one responsibility, a clear public interface, internals not reached into from outside.
4. Add tests alongside the module using this project's existing test conventions (find an existing test file first, match its style).
5. Wire it into the rest of the app only where actually needed — don't pre-wire hooks for future callers that don't exist yet.
6. Run `.claude/rules/coding-rules.md` verification step before considering it done.
7. Log the task in `DECISION-LOG.md` per `.claude/rules/decision-log-rules.md`.
