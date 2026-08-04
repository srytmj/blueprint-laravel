# Architecture

Project: [Project Name]
Last Updated: [Date]

---

## Infrastructure Diagram

```
[Client] -> [App server] -> [Data store]
                   |
             [File storage / external services]
```

Replace with your actual infra once decided.

---

## Services

| Service | Role |
|---------|------|
| [e.g. app server] | [what it does] |
| [e.g. database] | [what it does] |
| [e.g. CDN/proxy] | [what it does] |

---

## App Structure

```
code/
├── [source layout specific to your chosen stack]
└── ...
```

---

## Key Decisions

- [e.g. why this datastore, why this auth approach]
- [e.g. why this deployment target]

---

## Environment Variables

Key env vars and where they come from.

| Key | Source |
|-----|--------|
| [e.g. DB_HOST] | [e.g. hosting provider dashboard] |
