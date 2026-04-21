#!/usr/bin/env bash
set -euo pipefail

PROXY_SESSION="${CDDA_MCP_PROXY_SESSION:-cdda-mcp-proxy}"
GAME_SESSION="${CDDA_SESSION_NAME:-hermes-cdda}"

if tmux has-session -t "$PROXY_SESSION" 2>/dev/null; then
  tmux kill-session -t "$PROXY_SESSION"
  echo "stopped proxy session: $PROXY_SESSION"
else
  echo "proxy session already absent: $PROXY_SESSION"
fi

if tmux has-session -t "$GAME_SESSION" 2>/dev/null; then
  tmux kill-session -t "$GAME_SESSION"
  echo "stopped game session: $GAME_SESSION"
else
  echo "game session already absent: $GAME_SESSION"
fi
