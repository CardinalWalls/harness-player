#!/usr/bin/env bash
set -euo pipefail

PROXY_SESSION="${CLONE_HERMES_MCP_PROXY_SESSION:-clone-hermes-mcp-proxy}"

if tmux has-session -t "$PROXY_SESSION" 2>/dev/null; then
  tmux kill-session -t "$PROXY_SESSION"
  echo "stopped proxy session: $PROXY_SESSION"
else
  echo "proxy session already absent: $PROXY_SESSION"
fi
