#!/usr/bin/env bash

if [[ -n "${ZLINE_INSTALLER_COMMON_LOADED:-}" ]]; then
  return 0
fi
ZLINE_INSTALLER_COMMON_LOADED=1

INSTALLER_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_DIR="$(cd "${INSTALLER_LIB_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${INSTALLER_DIR}/.." && pwd)"
APP_NAME="${APP_NAME:-zLineBot-automos}"

log() {
  echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $*"
}

die() {
  echo "Error: $*" >&2
  exit 1
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    die "Please run as root (sudo)."
  fi
}

require_cmds() {
  local missing=()
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
  if (( ${#missing[@]} > 0 )); then
    die "Missing required commands: ${missing[*]}"
  fi
}

ensure_parent_dir() {
  mkdir -p "$(dirname "$1")"
}

sanitize_domain() {
  local domain="$1"
  if [[ -z "$domain" ]]; then
    die "Domain is required."
  fi
  printf '%s' "$domain"
}

is_public_domain() {
  local domain="$1"
  [[ "$domain" != "localhost" && "$domain" != *.local ]]
}

write_file() {
  local path="$1"
  shift
  ensure_parent_dir "$path"
  cat > "$path" <<EOF_FILE
$*
EOF_FILE
}
