#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEB_DIR="$ROOT/tmp/web"
PID_FILE="$WEB_DIR/dashboard.pid"
LOG_FILE="$WEB_DIR/dashboard.log"
URL_FILE="$WEB_DIR/dashboard-url.txt"
HOST="${CDDA_WEB_HOST:-127.0.0.1}"
PORT="${CDDA_WEB_PORT:-8875}"
URL="http://$HOST:$PORT"
DASHBOARD_SESSION="${CDDA_WEB_TMUX_SESSION:-cdda-dashboard-web-clean}"

"$ROOT/scripts/preflight.sh"
CDDA_INSTALL_DIR="$ROOT/tmp/runtime/cdda-terminal" "$ROOT/scripts/install-cdda-terminal.sh"

mkdir -p "$WEB_DIR"

if tmux has-session -t "$DASHBOARD_SESSION" 2>/dev/null; then
  echo "$URL"
  exit 0
fi

tmux new-session -d -s "$DASHBOARD_SESSION" \
  "CDDA_ROOT='$ROOT' CDDA_INSTALL_DIR='$ROOT/tmp/runtime/cdda-terminal' CDDA_HOME_DIR='$ROOT/tmp/runtime/home-hermes' CDDA_SESSION_NAME='hermes-cdda' CDDA_FIXED_SESSION_NAME='1' python3 '$ROOT/scripts/cdda_web_server.py' --host '$HOST' --port '$PORT' >'$LOG_FILE' 2>&1"

PID="$(tmux list-panes -t "$DASHBOARD_SESSION" -F '#{pane_pid}' | head -n 1)"
echo "$PID" >"$PID_FILE"
echo "$URL" >"$URL_FILE"

for _ in {1..40}; do
  if curl -fsS "$URL/api/health" >/dev/null 2>&1 \
    && curl -fsS "$URL/api/state" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 0.25
done

if [[ "${ready:-0}" != "1" ]]; then
  echo "dashboard failed to become ready" >&2
  tmux capture-pane -p -t "$DASHBOARD_SESSION" -S -120 | tail -n 80 >&2 || true
  exit 1
fi

curl -fsS -X POST "$URL/api/human-hermes/start" \
  -H 'Content-Type: application/json' \
  --data '{}' >/dev/null || true

echo "$URL"
