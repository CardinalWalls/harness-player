#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export CDDA_ROOT="${CDDA_ROOT:-$ROOT}"
export CDDA_MCP_URL="${CDDA_MCP_URL:-http://127.0.0.1:8766/mcp}"
export CDDA_SESSION_NAME="${CDDA_SESSION_NAME:-hermes-cdda}"
export CLONE_HERMES_SESSION_NAME="${CLONE_HERMES_SESSION_NAME:-clone_hermes}"
export CLONE_HERMES_COMMAND="${CLONE_HERMES_COMMAND:-hermes}"
export CLONE_HERMES_WIDTH="${CLONE_HERMES_WIDTH:-140}"
export CLONE_HERMES_HEIGHT="${CLONE_HERMES_HEIGHT:-50}"
export CLONE_HERMES_SKILL_PATH="${CLONE_HERMES_SKILL_PATH:-$HOME/.hermes/skills/gaming/cdda-agent/SKILL.md}"
export CLONE_HERMES_STATE_DIR="${CLONE_HERMES_STATE_DIR:-$ROOT/tmp/clone-hermes}"
export CLONE_HERMES_EVENT_LOG="${CLONE_HERMES_EVENT_LOG:-$ROOT/tmp/clone-hermes/events.jsonl}"
export CLONE_HERMES_DEBUG_LOG="${CLONE_HERMES_DEBUG_LOG:-$ROOT/tmp/clone-hermes/mcp-debug.log}"
export CLONE_HERMES_MCP_HOST="${CLONE_HERMES_MCP_HOST:-127.0.0.1}"
export CLONE_HERMES_MCP_PORT="${CLONE_HERMES_MCP_PORT:-8767}"

exec npx -y mcp-proxy \
  --host "$CLONE_HERMES_MCP_HOST" \
  --port "$CLONE_HERMES_MCP_PORT" \
  --server stream \
  --stateless \
  --shell \
  -- ./scripts/start-clone-hermes-mcp.sh
