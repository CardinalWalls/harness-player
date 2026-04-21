#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROXY_SESSION="${CLONE_HERMES_MCP_PROXY_SESSION:-clone-hermes-mcp-proxy}"
GAME_SESSION="${CDDA_SESSION_NAME:-hermes-cdda}"
CDDA_URL="${CDDA_MCP_URL:-http://127.0.0.1:8766/mcp}"
CLONE_SESSION="${CLONE_HERMES_SESSION_NAME:-clone_hermes}"
HOST="${CLONE_HERMES_MCP_HOST:-127.0.0.1}"
PORT="${CLONE_HERMES_MCP_PORT:-8767}"
URL="${CLONE_HERMES_MCP_URL:-http://$HOST:$PORT/mcp}"
LOG_FILE="${CLONE_HERMES_MCP_PROXY_LOG:-$ROOT/tmp/clone-hermes/proxy.log}"

mkdir -p "$(dirname "$LOG_FILE")"

call_mcp() {
  python3 "$ROOT/scripts/mcp_http_call.py" --url "$URL" "$@"
}

wait_ready() {
  local attempt
  for attempt in $(seq 1 30); do
    if call_mcp initialize --params '{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"clone-hermes-bootstrap","version":"0.1.0"}}' >/dev/null 2>&1 \
      && call_mcp tools/list >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

"$ROOT/scripts/preflight.sh"

if ! command -v hermes >/dev/null 2>&1; then
  echo "preflight failed: missing command: hermes" >&2
  exit 1
fi

if tmux has-session -t "$PROXY_SESSION" 2>/dev/null; then
  if ! wait_ready; then
    tmux kill-session -t "$PROXY_SESSION"
  fi
fi

if ! tmux has-session -t "$PROXY_SESSION" 2>/dev/null; then
  tmux new-session -d -s "$PROXY_SESSION" \
    "cd '$ROOT' && exec env CDDA_ROOT='$ROOT' CDDA_MCP_URL='$CDDA_URL' CDDA_SESSION_NAME='$GAME_SESSION' CLONE_HERMES_SESSION_NAME='$CLONE_SESSION' CLONE_HERMES_MCP_HOST='$HOST' CLONE_HERMES_MCP_PORT='$PORT' ./scripts/start-clone-hermes-mcp-proxy.sh >> '$LOG_FILE' 2>&1"
fi

if ! wait_ready; then
  echo "clone-hermes MCP failed to become ready; recent proxy output:" >&2
  tmux capture-pane -pt "$PROXY_SESSION" | tail -n 80 >&2 || true
  exit 1
fi

echo "clone-hermes MCP ready"
echo "endpoint: $URL"
echo "proxy session: $PROXY_SESSION"
echo "clone session: $CLONE_SESSION"
echo "game session: $GAME_SESSION"
echo "status command: $ROOT/scripts/clone-hermes-mcp-status.sh"
