# Skill: Add an external integration

Generic recipe for wiring up a third-party API/service, regardless of stack.

1. Confirm the integration is actually required by `docs/SRS.md` / `docs/PRD.md` (non-functional requirements especially — rate limits, auth method, data residency).
2. Never hardcode credentials. Use this project's existing config/env pattern (check `code/` for how other integrations read secrets); if there isn't one yet, that's a decision to flag to the user, not to invent silently.
3. Isolate the integration behind a thin wrapper/client in its own file(s) — callers shouldn't need to know the third-party SDK's shape.
4. Handle the failure modes that are real for this integration: timeouts, rate limits, auth expiry. Don't add generic defensive handling for failure modes that can't occur.
5. Document the new env vars / setup steps in `docs/ARCHITECTURE.md` under Environment Variables.
6. Add the deny-list check: if this integration introduces a new secret-file pattern (e.g. a downloaded service-account JSON), consider whether `.claude/hooks/write-guard.ps1`'s deny-list needs updating — flag it, don't silently edit the hook.
7. Log the task in `DECISION-LOG.md`.
