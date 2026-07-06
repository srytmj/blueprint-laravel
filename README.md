# Project Blueprint

A starter template for Laravel 11 projects with structured AI-assisted workflows via Claude Code.

Includes deploy automation, PM/DEV/QA agent sessions, and documentation templates.

---

## Folder Structure

```
project/
├── code/                        # Laravel 11 source code
├── scripts/
│   ├── update.sh                # Force pull latest from GitHub
│   └── deploy.sh                # Full deploy wizard (DB, S3, Cloudflare)
├── docs/
│   ├── SRS.md                   # System Requirements Specification
│   ├── PRD.md                   # Product Requirements Document
│   ├── ARCHITECTURE.md          # Infra and app architecture notes
│   └── tickets/
│       ├── TASK-TEMPLATE.md     # Ticket template
│       ├── TASK-001.md          # Example ticket
│       └── bugs/
│           └── BUG-TEMPLATE.md  # Bug ticket template
├── logs/                        # Auto-generated script logs
├── .claude/
│   ├── CLAUDE.md                # Global context for Claude Code
│   └── agents/
│       ├── PM.md                # PM session prompt
│       ├── DEV.md               # DEV session prompt
│       └── QA.md                # QA session prompt
├── setup.sh                     # First time project init
├── sync.sh                      # Sync stack from SRS into CLAUDE.md
├── Makefile                     # Shortcuts
└── .gitignore
```

---

## Quick Start

### 1. Copy the blueprint

```bash
cp -r blueprint/ my-project/
cd my-project/
rm -rf .git
git init
```

### 2. Run setup

```bash
bash setup.sh
# or
make setup
```

This sets your project name in CLAUDE.md and optionally installs Laravel 11 in code/.

---

## Workflow

### First time on a new project

```
bash setup.sh
  -> sets project name
  -> optional: installs Laravel in code/
```

Open PM session, write SRS and PRD in docs/.

```
bash sync.sh
  -> reads ## Stack from docs/SRS.md
  -> auto-fills CLAUDE.md
```

Open DEV session, pick up tickets and build.

Open QA session, review and generate bug prompts if needed.

---

### Subsequent deploys (on EC2)

```bash
# Pull latest code
bash scripts/update.sh
# or
make update

# Re-deploy (config remembered from last run)
sudo bash scripts/deploy.sh
# or
make deploy
```

---

## Claude Code Sessions

Each session has a different role with different permissions.
Use the corresponding file as the system prompt when opening Claude Code.

| Session | Prompt File | Can Edit Code | Can Create Tickets | Can Review Code |
|---------|-------------|---------------|--------------------|-----------------|
| PM | .claude/agents/PM.md | No | Yes | No |
| DEV | .claude/agents/DEV.md | Yes | No | No |
| QA | .claude/agents/QA.md | No | Bugs only | Yes |

### How to open a session in Claude Code

1. Open Claude Code in the project root.
2. Start a new conversation.
3. Paste the contents of the relevant agent file as the first message (system prompt).
4. Start working.

### Session keywords

| Keyword | Meaning |
|---------|---------|
| "gimana?" | Discuss only, do not create or edit anything yet |
| "lanjut" or "gas" | Proceed and execute |

---

## Ticket Flow

```
PM creates TASK-XXX.md (Status: Open)
  -> DEV picks up, fills DEV Response, codes (Status: In Progress)
  -> DEV marks done (Status: In Review)
  -> QA fills QA Response, checks (Status: Done or creates BUG-XXX)
  -> If bug: QA generates DEV prompt, DEV fixes (Status: Open again)
```

Ticket files live in docs/tickets/.
Bug files live in docs/tickets/bugs/.

---

## Scripts Reference

### setup.sh

Run once after cloning.

```bash
bash setup.sh
```

- Sets project name in CLAUDE.md.
- Optionally installs Laravel 11 in code/.

### sync.sh

Run after PM updates SRS or PRD.

```bash
bash sync.sh
```

- Reads ## Stack section from docs/SRS.md.
- Writes stack info into CLAUDE.md between sync markers.
- Logs to logs/sync.log.

### scripts/update.sh

Run on EC2 to pull latest code from GitHub.

```bash
bash scripts/update.sh
```

- Force overwrites local changes.
- Saves config to .update.conf (gitignored).

### scripts/deploy.sh

Full interactive deploy wizard. Run as root on EC2.

```bash
sudo bash scripts/deploy.sh
```

Covers:
- App type selection (Laravel, Node, custom)
- Systemd service generation
- Database setup with connection test
- S3/R2/Azure storage setup with connection test
- Cloudflare Tunnel setup
- Health check after deploy
- All config saved to .deploy.conf (gitignored)

---

## SRS Stack Format

sync.sh reads the ## Stack section from docs/SRS.md.
Keep this format consistent.

```md
## Stack

- Backend: Laravel 11, PostgreSQL
- Frontend: React + Vite
- Database: PostgreSQL 16
- Infra: EC2, RDS, Cloudflare R2, Cloudflare Tunnel
```

---

## Requirements

| Tool | Required For |
|------|-------------|
| git | update.sh |
| composer | setup.sh (Laravel install) |
| systemd | deploy.sh (service management) |
| mysql or psql client | deploy.sh (DB connection test) |
| aws cli | deploy.sh (S3/R2 connection test) |
| cloudflared | deploy.sh (auto-installed if missing) |
| curl | deploy.sh (health check) |
| perl | sync.sh (CLAUDE.md replacement) |
