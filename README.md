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

## How to use this

### 1. Create your project from the blueprint

```bash
cp -r blueprint-laravel/ my-app/
cd my-app/
rm -rf .git && git init
bash setup.sh
```

`setup.sh` asks for a project name, fills it into `CLAUDE.md`, and creates `code/`. This is a one-time step.

### 2. Describe what you're building

Write `docs/SRS.md` (requirements) and `docs/PRD.md` (product/features) for your actual project — you don't have to do this alone, open Claude Code and ask it to help draft them:

```
Read docs/SRS.md and docs/PRD.md and help me fill these in for: [describe your project]
```

Then sync the stack into `CLAUDE.md`:

```bash
bash sync.sh
```

Re-run `sync.sh` any time the `## Stack` section of `SRS.md` changes.

### 3. Work task by task in Claude Code

Start Claude Code in the project root (`claude`). `CLAUDE.md` loads automatically — it's short by design, and just routes to the right rule file for whatever you're doing (see [Folder structure](#folder-structure) below).

Normal loop for one task:

1. **Describe the change.** For anything non-trivial (new feature, multi-file change, unclear scope), ask Claude to use Plan Mode, or just say `/plan-feature`. It explores read-only, writes a plan, and waits for your approval — nothing gets edited until you approve.
2. **Approve or adjust the plan.**
3. **Claude implements.** Every time it finishes a turn, the `Stop` hook (`stop-verify.ps1`) automatically runs typecheck/build/test on whatever's in `code/` and self-corrects on failure — you don't have to ask for this, it's enforced.
4. **Before committing, run `/pre-commit`.** It spawns the designer/engineer/marketer agents in parallel on the changed files (each auto-skips if its domain wasn't touched) and reports findings before you commit.
5. **Claude logs the task.** It appends a structured entry to `DECISION-LOG.md`, and if it closed something tracked in `SCRATCHPAD.md`, moves it to `ARCHIVE.md` in the same turn.
6. **You commit normally with git.**

### 4. Fixing a bug

Just describe the bug. `CLAUDE.md`'s routing table sends Claude to `.claude/agents/investigator-agent.md` first — a read-only root-cause pass — before it writes any fix. This is what stops symptom-patching.

### 5. Resuming a later session

Say:

```
Read SCRATCHPAD.md and the last 5 entries of DECISION-LOG.md, then continue.
```

Claude picks up exactly where it left off. No need to re-explain context — that's the whole point of logging as you go.

### 6. Every 1-2 weeks

Run `/retrospective`. Claude reads recent `DECISION-LOG.md` entries, looks for anything that repeated 3+ times, and proposes concrete edits to `.claude/rules/*.md` for your approval — this is what makes the rules get sharper over time instead of staying static.

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
