#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROXY_SESSION="${CDDA_MCP_PROXY_SESSION:-cdda-mcp-proxy}"
GAME_SESSION="${CDDA_SESSION_NAME:-hermes-cdda}"
HOST="${CDDA_MCP_HOST:-127.0.0.1}"
PORT="${CDDA_MCP_PORT:-8766}"
URL="${CDDA_MCP_URL:-http://$HOST:$PORT/mcp}"

if tmux has-session -t "$PROXY_SESSION" 2>/dev/null; then
  echo "proxy session: $PROXY_SESSION (running)"
else
  echo "proxy session: $PROXY_SESSION (stopped)"
fi

if ! python3 "$ROOT/scripts/mcp_http_call.py" --url "$URL" initialize --params '{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"persistent-mcp-status","version":"0.1.0"}}' >/dev/null 2>&1; then
  echo "endpoint: $URL (unreachable)"
  exit 1
fi

echo "endpoint: $URL (ready)"
python3 "$ROOT/scripts/mcp_http_call.py" --url "$URL" tools/call --params "{\"name\":\"session_status\",\"arguments\":{\"session_name\":\"$GAME_SESSION\"}}"
