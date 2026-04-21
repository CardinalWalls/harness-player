#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="$ROOT/tmp/live/current"
LOOP_SESSION="${CDDA_LIVE_LOOP_SESSION:-cdda-live-loop}"
LOOP_LOG="$STATE_DIR/loop.log"
MODEL_CHOICE="${CDDA_LIVE_MODEL:-spark}"

"$ROOT/scripts/preflight.sh"
CDDA_INSTALL_DIR="$ROOT/tmp/runtime/cdda-terminal" "$ROOT/scripts/install-cdda-terminal.sh"
DASHBOARD_URL="$("$ROOT/scripts/open-dashboard.sh" | tail -n 1)"

mkdir -p "$STATE_DIR"

tmux kill-session -t "$LOOP_SESSION" 2>/dev/null || true
while IFS= read -r existing_session; do
  [[ -n "$existing_session" ]] || continue
  tmux kill-session -t "$existing_session" 2>/dev/null || true
done < <(tmux list-sessions -F '#S' 2>/dev/null | grep '^cdda-autoplay-' || true)

tmux new-session -d -s "$LOOP_SESSION" \
  "CDDA_LIVE_MODEL='$MODEL_CHOICE' CDDA_LIVE_LOOP_SESSION='$LOOP_SESSION' '$ROOT/scripts/run-live-loop.sh' >'$LOOP_LOG' 2>&1"

printf '%s\n' "$LOOP_SESSION"
printf '%s\n' "$DASHBOARD_URL"
