# Architecture

Project: [Project Name]
Last Updated: [Date]

---

## Infrastructure Diagram

```
[User] -> [Cloudflare Tunnel] -> [EC2: Nginx + php-fpm]
                                        |
                              [RDS: PostgreSQL]
                                        |
                              [Cloudflare R2 / S3]
```

---

## Services

| Service | Role |
|---------|------|
| EC2 | App server |
| RDS | Database |
| Cloudflare Tunnel | Public HTTPS access |
| R2 / S3 | File storage |

---

## App Structure (Laravel)

```
code/
├── app/
│   ├── Http/Controllers/
│   ├── Models/
│   └── Services/        # business logic goes here
├── routes/
├── database/
│   ├── migrations/
│   ├── seeders/
│   └── factories/
└── ...
```

---

## Key Decisions

- [e.g. Using Sanctum for API auth because stateless SPA]
- [e.g. Queue via database driver, upgrade to Redis if needed]

---

## Environment Variables

Key env vars and where they come from.

| Key | Source |
|-----|--------|
| DB_HOST | RDS endpoint |
| AWS_BUCKET | R2 bucket name |
| CF_TUNNEL_URL | Cloudflare dashboard |
