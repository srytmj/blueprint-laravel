# Project Blueprint

Starter template untuk Laravel 11 dengan AI-assisted workflow via Claude Code.

Include deploy automation, structured PM/DEV/QA agent sessions, dan documentation templates.

---

## Folder Structure

```
project/
├── code/                        # Laravel 11 source code
├── scripts/
│   ├── update.sh                # Force pull latest dari GitHub
│   └── deploy.sh                # Deploy wizard (DB, S3, Cloudflare)
├── docs/
│   ├── SRS.md                   # System Requirements Specification
│   ├── PRD.md                   # Product Requirements Document
│   ├── ARCHITECTURE.md          # Infra and app architecture notes
│   └── tickets/
│       ├── TASK-TEMPLATE.md
│       └── bugs/
│           └── BUG-TEMPLATE.md
├── logs/                        # Auto-generated script logs
├── .claude/
│   ├── CLAUDE.md                # Global context untuk Claude Code
│   └── agents/
│       ├── PM.md                # PM session prompt
│       ├── DEV.md               # DEV session prompt
│       └── QA.md                # QA session prompt
├── SESSION-PROMPTS.md           # Copy-paste prompts per session
├── setup.sh                     # First time init
├── sync.sh                      # Sync stack dari SRS ke CLAUDE.md
├── Makefile
└── .gitignore
```

---

## Quick Start

```bash
cp -r project/ my-app/
cd my-app/
rm -rf .git && git init
bash setup.sh
```

`setup.sh` mengisi nama project di CLAUDE.md dan opsional install Laravel 11 di code/.

---

## Workflow

### Setup awal

```bash
bash setup.sh
```

Buka PM session, tulis SRS dan PRD di docs/.

```bash
bash sync.sh
```

Sync stack dari docs/SRS.md ke .claude/CLAUDE.md. Jalankan ulang setiap kali SRS diupdate.

Buka DEV session, ambil ticket dan build.

Buka QA session, review dan generate bug prompt kalau ada issue.

### Deploy ke EC2

```bash
bash scripts/update.sh      # pull latest, force overwrite
sudo bash scripts/deploy.sh # deploy wizard
```

Atau pakai Makefile:

```bash
make update
make deploy
```

---

## Claude Code Sessions

Buka file agent yang sesuai sebagai opening prompt di Claude Code.
File lengkap ada di SESSION-PROMPTS.md, tinggal copy paste.

| Session | Prompt File | Edit Code | Buat Ticket | Review Code |
|---------|-------------|-----------|-------------|-------------|
| PM | .claude/agents/PM.md | Tidak | Ya | Tidak |
| DEV | .claude/agents/DEV.md | Ya | Tidak | Tidak |
| QA | .claude/agents/QA.md | Tidak | Bug only | Ya |

---

## Session Keywords

| Keyword | Mode | Meaning |
|---------|------|---------|
| gimana? | Discuss | Open discussion, no action |
| wdyt? | Discuss | Minta opini atau rekomendasi |
| worth it? | Discuss | Evaluasi trade-off |
| review | Discuss | Feedback apa yang sudah ada |
| elaborate | Clarify | Jelasin lebih detail |
| tldr | Clarify | Ringkas singkat |
| gas / lanjut | Execute | Proceed sekarang |
| do it | Execute | Sama dengan gas |
| ship it | Execute | Final, no more changes |
| skip | Control | Lewati bagian ini |
| hold | Control | Stop, tunggu instruksi |
| undo | Control | Revert perubahan terakhir |

---

## Ticket Flow

```
PM buat TASK-XXX.md (Status: Open)
  -> DEV isi DEV Response, coding (Status: In Progress)
  -> DEV selesai (Status: In Review)
  -> QA isi QA Response, cek (Status: Done / buat BUG-XXX)
  -> Kalau bug: QA generate DEV prompt, DEV fix (Status: Open)
```

Ticket: docs/tickets/TASK-XXX.md
Bug: docs/tickets/bugs/BUG-XXX.md

---

## sync.sh: Format Stack di SRS.md

sync.sh membaca section `## Stack` dari docs/SRS.md. Format harus konsisten:

```md
## Stack

- Backend: Laravel 11, PostgreSQL
- Frontend: React + Vite
- Database: PostgreSQL 16
- Infra: EC2, RDS, Cloudflare R2, Cloudflare Tunnel
```

---

## Scripts Reference

| Script | Command | Fungsi |
|--------|---------|--------|
| setup.sh | `bash setup.sh` | Init project, set nama, opsional install Laravel |
| sync.sh | `bash sync.sh` | Sync stack SRS ke CLAUDE.md |
| scripts/update.sh | `bash scripts/update.sh` | Pull latest dari GitHub, force overwrite |
| scripts/deploy.sh | `sudo bash scripts/deploy.sh` | Full deploy wizard di EC2 |

---

## Requirements

| Tool | Dibutuhkan Untuk |
|------|-----------------|
| git | update.sh |
| composer | setup.sh (Laravel install) |
| systemd | deploy.sh (service management) |
| mysql atau psql | deploy.sh (DB connection test) |
| aws cli | deploy.sh (S3/R2 test) |
| cloudflared | deploy.sh (auto-install jika belum ada) |
| curl | deploy.sh (health check) |
| perl | sync.sh (CLAUDE.md replacement) |
