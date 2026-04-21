#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export CDDA_ROOT="${CDDA_ROOT:-$ROOT}"
export CDDA_INSTALL_DIR="${CDDA_INSTALL_DIR:-$ROOT/tmp/runtime/cdda-terminal}"
export CDDA_HOME_DIR="${CDDA_HOME_DIR:-$ROOT/tmp/runtime/home}"
export CDDA_SESSION_NAME="${CDDA_SESSION_NAME:-cdda-curses}"
export CDDA_EVENT_LOG="${CDDA_EVENT_LOG:-$ROOT/tmp/runtime/events.jsonl}"
export CDDA_DEBUG_LOG="${CDDA_DEBUG_LOG:-$ROOT/tmp/runtime/mcp-debug.log}"
export PYTHONUNBUFFERED=1

mkdir -p "$(dirname "$CDDA_DEBUG_LOG")"
printf '%s wrapper_start\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >>"$CDDA_DEBUG_LOG"

exec python3 "$ROOT/scripts/cdda_mcp_server.py"
