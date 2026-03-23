# zLineBot-automos Feature Inventory

## 1) Root Full-Stack Application

- React + Vite frontend in `frontend/`.
- FastAPI API service in `backend/api/`.
- Background worker in `backend/worker/`.
- Postgres bootstrap SQL in `backend/db/init.sql`.
- NGINX, TLS, backup, monitoring, and Cloudflared assets in `infra/`.
- Root `docker-compose.yml` as the primary stack entrypoint.

## 2) Preserved Supporting Source Modules

- `landing/`: original landing page React app.
- `backend-node/`: Express checkout and webhook demo backend.
- `api/`: auxiliary FastAPI + Stripe integration example.
- `ai-agent/`: automation/agent module.
- `billing/`: Stripe helper utilities.
- `worker/`: additional worker implementation.
- `docker/`: extra Dockerfiles.
- `k8s/`: Kubernetes manifests.
- `monitoring/`: Prometheus configuration.
- `security/`: shared middleware/security helpers.
- `viral-content/`: content templates.

## 3) Operational Tooling

- `installer/install.sh`: shared modular installer that prepares the full stack in system or project mode.
- `installer/lib/*.sh`: reusable shell modules for logging, runtime setup, env generation, TLS, and stack staging.
- `zeaz_ai_full_stack_installer.sh`: compatibility wrapper for system installs into `/opt/zLineBot-automos`.
- `ubuntu_stack_installer.sh`: compatibility wrapper for preparing a local project copy in `./zlinebot-automos-stack`.
- `start-zLineBot-automos.sh`: installs and manages the root Docker Compose stack as a systemd service.
- `infrastructure/scripts/check-iac-policy.sh`: validates root `k8s/*.yaml` manifests.
- `infrastructure/scripts/auto-fix-pipeline.sh`: applies safe formatting/permission remediation.
