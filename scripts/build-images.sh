#!/usr/bin/env bash
set -euo pipefail

REGISTRY="${REGISTRY:-zlinebot-automos}"
TAG="${TAG:-latest}"

usage() {
  cat <<USAGE
Usage:
  bash scripts/build-images.sh [--registry <name>] [--tag <tag>]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --registry)
      REGISTRY="${2:-}"
      shift 2
      ;;
    --tag)
      TAG="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

[[ -n "${REGISTRY}" ]] || { echo "REGISTRY cannot be empty" >&2; exit 1; }
[[ -n "${TAG}" ]] || { echo "TAG cannot be empty" >&2; exit 1; }

docker build -f docker/api.Dockerfile -t "${REGISTRY}/api:${TAG}" .
docker build -f docker/worker.Dockerfile -t "${REGISTRY}/worker:${TAG}" .
