#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$ROOT_DIR/.omx/logs"
TIMESTAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"
LOG_PATH="$LOG_DIR/omx-transport-debug-$TIMESTAMP.log"

mkdir -p "$LOG_DIR"

cat <<EOF
Writing OMX transport debug log to:
  $LOG_PATH

Recommended usage:
  run this from an external terminal, not from the active Codex Desktop thread
EOF

(
  cd "$ROOT_DIR"
  OMX_MCP_TRANSPORT_DEBUG=1 \
    bash ./scripts/omx-takeover.sh --restart --auto --transport-debug
) 2>&1 | tee "$LOG_PATH"
