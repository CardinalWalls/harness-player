#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROXY_SESSION="${CDDA_MCP_PROXY_SESSION:-cdda-mcp-proxy}"
GAME_SESSION="${CDDA_SESSION_NAME:-hermes-cdda}"
HOST="${CDDA_MCP_HOST:-127.0.0.1}"
PORT="${CDDA_MCP_PORT:-8766}"
URL="${CDDA_MCP_URL:-http://$HOST:$PORT/mcp}"
LOG_FILE="${CDDA_MCP_PROXY_LOG:-$ROOT/tmp/runtime/mcp-proxy.log}"
PREP_FILE="$ROOT/tmp/runtime/mcp-prepare.json"

mkdir -p "$(dirname "$LOG_FILE")"

call_mcp() {
  python3 "$ROOT/scripts/mcp_http_call.py" --url "$URL" "$@"
}

wait_ready() {
  local attempt
  for attempt in $(seq 1 30); do
    if call_mcp initialize --params '{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"persistent-mcp-bootstrap","version":"0.1.0"}}' >/dev/null 2>&1 \
      && call_mcp tools/list >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

"$ROOT/scripts/preflight.sh"
CDDA_INSTALL_DIR="$ROOT/tmp/runtime/cdda-terminal" "$ROOT/scripts/install-cdda-terminal.sh"

if tmux has-session -t "$PROXY_SESSION" 2>/dev/null; then
  if ! wait_ready; then
    tmux kill-session -t "$PROXY_SESSION"
  fi
fi

if ! tmux has-session -t "$PROXY_SESSION" 2>/dev/null; then
  tmux new-session -d -s "$PROXY_SESSION" \
    "cd '$ROOT' && exec env CDDA_ROOT='$ROOT' CDDA_INSTALL_DIR='$ROOT/tmp/runtime/cdda-terminal' CDDA_HOME_DIR='$ROOT/tmp/runtime/home-hermes' CDDA_SESSION_NAME='$GAME_SESSION' CDDA_FIXED_SESSION_NAME='1' CDDA_EVENT_LOG='$ROOT/tmp/runtime/hermes-events.jsonl' CDDA_DEBUG_LOG='$ROOT/tmp/runtime/hermes-mcp-debug.log' CDDA_MCP_HOST='$HOST' CDDA_MCP_PORT='$PORT' ./scripts/start-cdda-mcp-proxy.sh >> '$LOG_FILE' 2>&1"
fi

if ! wait_ready; then
  echo "persistent MCP failed to become ready; recent proxy output:" >&2
  tmux capture-pane -pt "$PROXY_SESSION" | tail -n 80 >&2 || true
  exit 1
fi

rm -f "$PREP_FILE"
prepared=0
for _ in 1 2 3; do
  call_mcp tools/call --params "{\"name\":\"reach_playable\",\"arguments\":{\"session_name\":\"$GAME_SESSION\",\"restart\":false,\"startup_wait_ms\":5000,\"wait_ms\":1000,\"max_steps\":12}}" >"$PREP_FILE"
  if python3 - "$PREP_FILE" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as handle:
    payload = json.load(handle)
sys.exit(0 if payload.get("structuredContent", {}).get("reached_playable") else 1)
PY
  then
    prepared=1
    break
  fi
  sleep 2
done

if [[ "$prepared" -ne 1 ]]; then
  echo "persistent MCP is up but the shared game session is not yet playable" >&2
  cat "$PREP_FILE" >&2
  exit 1
fi

echo "persistent MCP ready"
echo "endpoint: $URL"
echo "proxy session: $PROXY_SESSION"
echo "game session: $GAME_SESSION"
echo "status command: $ROOT/scripts/mcp-status.sh"
