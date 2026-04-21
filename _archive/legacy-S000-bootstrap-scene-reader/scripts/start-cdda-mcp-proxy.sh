#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export CDDA_ROOT="${CDDA_ROOT:-$ROOT}"
export CDDA_INSTALL_DIR="${CDDA_INSTALL_DIR:-$ROOT/tmp/runtime/cdda-terminal}"
export CDDA_HOME_DIR="${CDDA_HOME_DIR:-$ROOT/tmp/runtime/home-hermes}"
export CDDA_SESSION_NAME="${CDDA_SESSION_NAME:-hermes-cdda}"
export CDDA_FIXED_SESSION_NAME="${CDDA_FIXED_SESSION_NAME:-1}"
export CDDA_EVENT_LOG="${CDDA_EVENT_LOG:-$ROOT/tmp/runtime/hermes-events.jsonl}"
export CDDA_DEBUG_LOG="${CDDA_DEBUG_LOG:-$ROOT/tmp/runtime/hermes-mcp-debug.log}"
export CDDA_MCP_HOST="${CDDA_MCP_HOST:-127.0.0.1}"
export CDDA_MCP_PORT="${CDDA_MCP_PORT:-8766}"

exec npx -y mcp-proxy \
  --host "$CDDA_MCP_HOST" \
  --port "$CDDA_MCP_PORT" \
  --server stream \
  --stateless \
  --shell \
  -- ./scripts/start-cdda-mcp.sh
