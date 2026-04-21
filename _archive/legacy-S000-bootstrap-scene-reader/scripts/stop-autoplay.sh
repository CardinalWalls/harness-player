#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SESSION_FILE="$ROOT/tmp/autoplay/current/tmux-session.txt"

if [[ ! -f "$SESSION_FILE" ]]; then
  echo "no autoplay session file"
  exit 0
fi

SESSION_NAME="$(tr -d '\r\n' <"$SESSION_FILE")"

if [[ -z "$SESSION_NAME" ]]; then
  echo "empty autoplay session name"
  exit 0
fi

tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true
echo "$SESSION_NAME"
