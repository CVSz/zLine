#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

REGISTRY="${REGISTRY:-zlinebot-automos}"
TAG="${TAG:-latest}"
SKIP_PUSH="${SKIP_PUSH:-false}"
SKIP_APPLY="${SKIP_APPLY:-false}"
K8S_DIR="${K8S_DIR:-${REPO_ROOT}/k8s}"

usage() {
  cat <<USAGE
Usage:
  bash scripts/deploy-images.sh [options]

Options:
  --registry <name>   Container registry/image prefix (default: ${REGISTRY})
  --tag <tag>         Image tag (default: ${TAG})
  --skip-push         Build only; skip docker push.
  --skip-apply        Build/push only; skip kubectl apply.
  -h, --help          Show this help.

Environment alternatives:
  REGISTRY, TAG, SKIP_PUSH, SKIP_APPLY, K8S_DIR
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
    --skip-push)
      SKIP_PUSH="true"
      shift
      ;;
    --skip-apply)
      SKIP_APPLY="true"
      shift
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

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required" >&2
  exit 1
fi

if [[ "${SKIP_APPLY}" != "true" ]] && ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required unless --skip-apply is set" >&2
  exit 1
fi

echo "🚀 Building images (${REGISTRY}, tag=${TAG})"
bash "${SCRIPT_DIR}/build-images.sh" --registry "${REGISTRY}" --tag "${TAG}"

if [[ "${SKIP_PUSH}" != "true" ]]; then
  echo "📤 Pushing images"
  docker push "${REGISTRY}/api:${TAG}"
  docker push "${REGISTRY}/worker:${TAG}"
else
  echo "⏭️  Skipping push"
fi

if [[ "${SKIP_APPLY}" != "true" ]]; then
  echo "☸️  Applying Kubernetes manifests from ${K8S_DIR}"
  kubectl apply -f "${K8S_DIR}"
else
  echo "⏭️  Skipping kubectl apply"
fi

echo "✅ Deployment workflow completed"
