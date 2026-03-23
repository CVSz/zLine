#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec bash "${SCRIPT_DIR}/installer/install.sh" --mode system --app-dir /opt/zLineBot-automos "$@"
