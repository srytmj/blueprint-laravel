# Project Context

Project: {PROJECT_NAME}
Initialized: {SETUP_DATE}

<!-- STACK_START -->
## Stack
- Backend: [TBD - run bash sync.sh after PM session]
- Frontend: [TBD]
- Database: [TBD]
- Infra: [TBD]
<!-- STACK_END -->

---

# Folder Structure

```
project/
├── code/          # Laravel source
├── scripts/       # update.sh, deploy.sh
├── docs/          # SRS, PRD, ARCHITECTURE, tickets
├── logs/          # script audit logs
└── .claude/       # agent prompts, this file
```

---

# Global Rules

1. Always read docs/SRS.md and docs/PRD.md before any task.
2. All features must have a ticket in docs/tickets/ before code is written.
3. Code lives in code/ only.
4. Docs live in docs/ only.
5. Never modify scripts/ unless explicitly asked.
6. Tickets use format TASK-XXX.md and BUG-XXX.md.
7. Each session has its own rules, defined in .claude/agents/.

---

# Sessions

Open the corresponding agent file as system prompt per session.

- PM session: .claude/agents/PM.md
- DEV session: .claude/agents/DEV.md
- QA session: .claude/agents/QA.md
