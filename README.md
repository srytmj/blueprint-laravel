# Claude Code Blueprint

Stack-agnostic starter template for working with Claude Code as a real collaborator instead of forgetful autocomplete. Rules are read on demand, hooks enforce instead of just notify, every task is logged, specialist agents review in parallel, and Plan Mode is the default for anything non-trivial.

Works for any language or framework. Nothing here assumes a particular backend, frontend, or infra.

---

## The five pillars

1. **CLAUDE.md is a router, not documentation.** Conditional triggers point to leaf files in `.claude/rules/`, `.claude/agents/`, `.claude/skills/` — Claude reads the ~300 tokens of the rule that matters, not the whole ruleset every turn.
2. **Hooks enforce, they don't just notify.** `Stop` runs verification and blocks with the error tail on failure; `PreToolUse` blocks writes to secret files; `UserPromptSubmit` injects git context automatically.
3. **DECISION-LOG.md + retrospectives.** Every task gets a structured entry with a mandatory `Rule Updated` field. Run `/retrospective` every 1-2 weeks to turn recurring patterns into permanent rules.
4. **Specialist reviewers run in parallel.** `/pre-commit` spawns designer/engineer/marketer agents concurrently, skips whichever domain wasn't touched, and escalates cross-domain findings before you see them.
5. **Plan Mode is the default.** Non-trivial changes go through `.claude/commands/plan-feature.md`: read-only exploration, a plan file, explicit approval, then implementation. One plan = one scope = one commit.

---

## Folder structure

```
project/
├── code/                        # your source code, any stack
├── docs/
│   ├── SRS.md                   # System Requirements Specification
│   ├── PRD.md                   # Product Requirements Document
│   └── ARCHITECTURE.md          # infra + app architecture notes
├── .claude/
│   ├── rules/                   # guardrails, loaded on demand via CLAUDE.md triggers
│   ├── agents/                  # specialist reviewers + investigator
│   ├── skills/                  # how-to recipes
│   ├── commands/                # /pre-commit, /retrospective, /plan-feature
│   ├── writing-styles/          # voice guides per context
│   ├── hooks/                   # PowerShell hook scripts
│   └── settings.local.json      # permissions + hook registration
├── CLAUDE.md                    # index only, points to everything above
├── DECISION-LOG.md              # every finished task, structured
├── SCRATCHPAD.md                # open work only — not a memory store
├── ARCHIVE.md                   # one-liner per finished task
├── logs/                        # sync.sh output
├── setup.sh                     # first-time init
└── sync.sh                      # sync docs/SRS.md Stack section into CLAUDE.md
```

---

## Quick start

```bash
cp -r project/ my-app/
cd my-app/
rm -rf .git && git init
bash setup.sh
```

`setup.sh` fills in the project name in `CLAUDE.md` and creates `code/`.

---

## Workflow

```bash
bash setup.sh
```

Write `docs/SRS.md` and `docs/PRD.md` for the project you're actually building.

```bash
bash sync.sh
```

Syncs the `## Stack` section from `docs/SRS.md` into `CLAUDE.md`. Re-run whenever the SRS stack changes.

From there, work task by task:

1. Non-trivial change? Use Plan Mode (`.claude/commands/plan-feature.md`) — read-only exploration, write a plan, get it approved, then implement.
2. Bug? Run the investigator agent first (`.claude/agents/investigator-agent.md`) for root cause before writing a fix.
3. Before committing: `/pre-commit` — parallel specialist review.
4. After finishing: append an entry to `DECISION-LOG.md`. If it closed something in `SCRATCHPAD.md`, move it to `ARCHIVE.md` immediately.
5. Every 1-2 weeks: `/retrospective` to turn recurring patterns into rule updates.

Start a new session by reading `SCRATCHPAD.md` plus the last 5 entries of `DECISION-LOG.md` — no re-onboarding needed.

---

## SCRATCHPAD vs. memory — don't conflate them

`SCRATCHPAD.md` holds **open work**: active tasks, blockers, pending verification. It is not a place to store durable facts.

**Durable facts** — your preferences, project decisions that are always true, lessons learned from corrections — belong in Claude's memory system, not in a file. If you find yourself reminding Claude of the same thing twice, that's a rule, a hook, or a memory entry waiting to be written, not a scratchpad note.

The moment a task in `SCRATCHPAD.md` closes, its one-line entry goes into `ARCHIVE.md` immediately — not swept in later as a batch cleanup. That's what keeps the active file legible instead of turning into a graveyard.

---

## Hooks

Three PowerShell hooks registered in `.claude/settings.local.json`:

| Hook | Event | What it does |
|------|-------|---------------|
| `write-guard.ps1` | PreToolUse (Write\|Edit) | Blocks writes to secret/credential files (`.env*`, keys, certs, credentials) |
| `stop-verify.ps1` | Stop | Auto-detects your stack in `code/` (package.json, composer.json, go.mod, Cargo.toml, etc.) and runs typecheck/build/test; blocks with the error tail on failure |
| `git-context-inject.ps1` | UserPromptSubmit | Prints branch + `git status -sb` into context automatically |

`stop-verify.ps1` degrades gracefully when `code/` has no recognized manifest yet — it just exits clean.

---

## Scripts reference

| Script | Command | Purpose |
|--------|---------|---------|
| setup.sh | `bash setup.sh` | Init project, set name, create `code/` |
| sync.sh | `bash sync.sh` | Sync Stack section from `docs/SRS.md` into `CLAUDE.md` |

## Requirements

| Tool | Needed for |
|------|-----------|
| git | git-context-inject hook, general workflow |
| pwsh (PowerShell 7+) | running the hooks |
| perl | sync.sh (CLAUDE.md replacement) |
