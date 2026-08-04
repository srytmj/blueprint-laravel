# Coding Rules

Stack-agnostic. Applies to any language/framework used in `code/`.

## Scope discipline
- Implement exactly what the current plan/ticket asks. No drive-by refactors, no speculative abstractions.
- Three similar lines beat a premature helper. Don't design for hypothetical future requirements.
- Don't add error handling, validation, or fallbacks for scenarios that can't happen. Validate only at real boundaries (user input, external APIs).

## Style
- Match the existing conventions of the file/module you're editing over your own preference.
- No comments explaining *what* the code does — names should do that. A comment is only justified when it captures a non-obvious *why* (a workaround, a hidden constraint, a subtle invariant).
- No commented-out code, no `// removed` markers, no backwards-compat shims for code you're allowed to delete outright.

## Verification
- Before calling a task done, run whatever this project's typecheck/build/test commands are (see `.claude/hooks/stop-verify.ps1` — it auto-detects and runs them on Stop).
- If verification can't run (no test suite yet, no build step), say so explicitly rather than claiming it passed.

## Security
- Never hardcode secrets, tokens, or credentials in code or docs.
- Treat all external input as untrusted; validate and sanitize at the boundary.
