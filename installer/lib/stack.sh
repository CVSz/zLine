#!/usr/bin/env bash

if [[ -n "${ZLINE_INSTALLER_STACK_LOADED:-}" ]]; then
  return 0
fi
ZLINE_INSTALLER_STACK_LOADED=1

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

stage_source_tree() {
  local source_dir="$1"
  local app_dir="$2"
  local source_real app_real relative_app

  mkdir -p "$app_dir"
  source_real="$(cd "$source_dir" && pwd)"
  app_real="$(cd "$app_dir" && pwd)"

  if [[ "$source_real" == "$app_real" ]]; then
    log "Using existing repository contents in ${app_dir}"
    return 0
  fi

  log "Syncing project files into ${app_dir}"
  relative_app="$(python - "$source_real" "$app_real" <<'PY'
import os
import sys

source = os.path.realpath(sys.argv[1])
target = os.path.realpath(sys.argv[2])

if target == source or not target.startswith(source + os.sep):
    print("")
else:
    print(os.path.relpath(target, source))
PY
)"

  tar \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='dist' \
    --exclude='coverage' \
    --exclude='__pycache__' \
    ${relative_app:+--exclude="./${relative_app}"} \
    -C "$source_dir" -cf - . | tar -C "$app_dir" -xf -
}

generate_stack_env() {
  local app_dir="$1"
  local domain="$2"
  local cert_email="$3"

  local db_pass redis_pass jwt_secret_current kafka_user kafka_pass admin_pass
  db_pass="$(openssl rand -hex 32)"
  redis_pass="$(openssl rand -hex 32)"
  jwt_secret_current="$(openssl rand -hex 48)"
  kafka_user="zlinebot_app"
  kafka_pass="$(openssl rand -hex 24)"
  admin_pass="$(openssl rand -base64 18)"

  cat > "${app_dir}/.env" <<ENV
DOMAIN=${domain}
DB_PASS=${db_pass}
REDIS_PASS=${redis_pass}
JWT_SECRET_CURRENT=${jwt_secret_current}
JWT_SECRET_PREVIOUS=
KAFKA_USER=${kafka_user}
KAFKA_PASS=${kafka_pass}
ADMIN_PASS=${admin_pass}
OPENAI_API_KEY=REPLACE
CERT_EMAIL=${cert_email:-admin@${domain}}
CLOUDFLARED_TUNNEL_ID=replace-with-your-tunnel-uuid
DATABASE_URL=postgresql://zlinebot:${db_pass}@db:5432/zlinebot_automos
REDIS_URL=redis://:${redis_pass}@redis:6379/0
KAFKA_BROKER=kafka:9092
KAFKA_SECURITY_PROTOCOL=SASL_PLAINTEXT
KAFKA_SASL_MECHANISM=PLAIN
KAFKA_USERNAME=${kafka_user}
KAFKA_PASSWORD=${kafka_pass}
ENV
  chmod 600 "${app_dir}/.env"

  cat > "${app_dir}/backend/api/api.env" <<ENV
DATABASE_URL=postgresql://zlinebot:${db_pass}@db:5432/zlinebot_automos
JWT_SECRET_CURRENT=${jwt_secret_current}
JWT_SECRET_PREVIOUS=
REDIS_URL=redis://:${redis_pass}@redis:6379/0
KAFKA_BROKER=kafka:9092
KAFKA_SECURITY_PROTOCOL=SASL_PLAINTEXT
KAFKA_SASL_MECHANISM=PLAIN
KAFKA_USERNAME=${kafka_user}
KAFKA_PASSWORD=${kafka_pass}
CORS_ORIGINS=https://${domain}
OPENAI_API_KEY=REPLACE
ENV

  cat > "${app_dir}/backend/worker/worker.env" <<ENV
DATABASE_URL=postgresql://zlinebot:${db_pass}@db:5432/zlinebot_automos
KAFKA_BROKER=kafka:9092
KAFKA_SECURITY_PROTOCOL=SASL_PLAINTEXT
KAFKA_SASL_MECHANISM=PLAIN
KAFKA_USERNAME=${kafka_user}
KAFKA_PASSWORD=${kafka_pass}
ENV

  log "Generated stack environment files"
}

configure_tls_assets() {
  local app_dir="$1"
  local domain="$2"
  local cert_email="$3"
  local cert_dir="${app_dir}/infra/certs"

  mkdir -p "$cert_dir"

  if [[ -n "$cert_email" ]] && is_public_domain "$domain"; then
    log "Attempting Let's Encrypt certificate for ${domain}"
    local occupying_containers
    occupying_containers="$(docker ps --filter publish=80 --format '{{.ID}}')"
    if [[ -n "$occupying_containers" ]]; then
      log "Stopping containers bound to port 80 for certbot challenge"
      docker stop ${occupying_containers} >/dev/null
    fi

    if certbot certonly --standalone --non-interactive --agree-tos -m "$cert_email" -d "$domain"; then
      cp "/etc/letsencrypt/live/${domain}/fullchain.pem" "${cert_dir}/fullchain.pem"
      cp "/etc/letsencrypt/live/${domain}/privkey.pem" "${cert_dir}/privkey.pem"
      chmod 600 "${cert_dir}/privkey.pem"
      log "Issued Let's Encrypt certificate for ${domain}"
      return 0
    fi

    log "Let's Encrypt failed, generating self-signed certificate instead"
  else
    log "Generating self-signed certificate for ${domain}"
  fi

  openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout "${cert_dir}/privkey.pem" \
    -out "${cert_dir}/fullchain.pem" \
    -days 365 \
    -subj "/CN=${domain}"
  chmod 600 "${cert_dir}/privkey.pem"
}

export_stack_archive() {
  local app_dir="$1"
  local archive_path="$2"

  mkdir -p "$(dirname "$archive_path")"
  tar -C "$app_dir" -czf "$archive_path" .
  log "Exported stack archive to ${archive_path}"
}

prepare_stack() {
  local source_dir="$1"
  local app_dir="$2"
  local domain="$3"
  local cert_email="$4"
  local export_zip="$5"
  local archive_path="$6"

  stage_source_tree "$source_dir" "$app_dir"
  generate_stack_env "$app_dir" "$domain" "$cert_email"
  configure_tls_assets "$app_dir" "$domain" "$cert_email"

  if [[ "$export_zip" == "true" ]]; then
    export_stack_archive "$app_dir" "$archive_path"
  fi
}
