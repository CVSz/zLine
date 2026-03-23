#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_APP_DIR="${PWD}/zlinebot-automos-stack"
exec bash "${SCRIPT_DIR}/installer/install.sh" --mode project --app-dir "${DEFAULT_APP_DIR}" "$@"
