#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ACTION="${1:-up}"
shift || true

ensure_env() {
  if [[ ! -f "${ROOT_DIR}/.env" ]]; then
    cat >&2 <<MSG
Missing ${ROOT_DIR}/.env.
Run one of the installers first, for example:
  bash ubuntu_stack_installer.sh --domain your-domain.example
MSG
    exit 1
  fi
}

case "${ACTION}" in
  up)
    ensure_env
    docker compose -f "${ROOT_DIR}/docker-compose.yml" up -d --build "$@"
    ;;
  down)
    docker compose -f "${ROOT_DIR}/docker-compose.yml" down "$@"
    ;;
  restart)
    ensure_env
    docker compose -f "${ROOT_DIR}/docker-compose.yml" down
    docker compose -f "${ROOT_DIR}/docker-compose.yml" up -d --build "$@"
    ;;
  logs)
    docker compose -f "${ROOT_DIR}/docker-compose.yml" logs -f --tail=200 "$@"
    ;;
  ps)
    docker compose -f "${ROOT_DIR}/docker-compose.yml" ps "$@"
    ;;
  *)
    cat >&2 <<USAGE
Usage: bash scripts/run-stack.sh [up|down|restart|logs|ps] [compose args...]
USAGE
    exit 1
    ;;
esac
