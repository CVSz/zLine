# ZEAZ Ultra Pack (Deploy-ready)

Self-contained full stack starter with:

- React + Tailwind landing, signup, login, CTA, and chat demo pages.
- FastAPI API (`/api/register`, `/api/login`, `/api/chat`).
- Worker + Kafka + Redis + Postgres.
- NGINX TLS reverse proxy for `/api/`, `/admin/`, `/user/`, `/devops/`.
- Docker Compose infra with healthchecks, memory/CPU limits, and internal/public networks.
- Backup + monitoring scripts.

## Structure

```text
zeaz-ultra-pack/
├─ .env.example
├─ gen-secrets.sh
├─ frontend/
├─ backend/
└─ infra/
```

## Quick Start (Local VM or Cloud VM)

1. Generate secrets and runtime environment.

```bash
cd zeaz-ultra-pack
./gen-secrets.sh localhost admin@example.com
```

2. Start stack.

```bash
cd infra
docker compose --env-file ../.env up -d --build
```

`nginx` generates a self-signed certificate automatically when `infra/certs/fullchain.pem` and `infra/certs/privkey.pem` are not provided.

## Optional: Use public TLS certs (Let's Encrypt)

- Put your valid certificate and key into:
  - `infra/certs/fullchain.pem`
  - `infra/certs/privkey.pem`
- Rebuild nginx:

```bash
cd infra
docker compose --env-file ../.env up -d --build nginx
```

## Endpoints

- `https://<host>/` (Landing page)
- `https://<host>/signup`
- `https://<host>/login`
- `https://<host>/api/health`
- `https://<host>/admin/`
- `https://<host>/user/`
- `https://<host>/devops/`

## Health Monitoring

```bash
cd infra
./monitor/health.sh localhost
```

## Backup (AES-256 encrypted)

```bash
cd infra
source ../.env
./backup/backup.sh /tmp/zeaz-backups
```

The script writes:

- Encrypted dump: `*.dump.enc`
- SHA-256 checksum: `*.dump.enc.sha256`
