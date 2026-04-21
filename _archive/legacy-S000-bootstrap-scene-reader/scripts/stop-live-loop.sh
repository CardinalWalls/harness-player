#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="$ROOT/tmp/live/current"
STATUS_FILE="$STATE_DIR/loop-status.json"
EXEC_STATUS_FILE="$STATE_DIR/exec-status.json"
LOOP_SESSION="${CDDA_LIVE_LOOP_SESSION:-cdda-live-loop}"

tmux kill-session -t "$LOOP_SESSION" 2>/dev/null || true

mkdir -p "$STATE_DIR"
cat >"$STATUS_FILE" <<EOF
{
  "updated_at": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
  "active": false,
  "run_id": "",
  "round": 0,
  "round_status": "stopped",
  "model": "",
  "model_choice": "",
  "loop_session": "$LOOP_SESSION",
  "game_session": "cdda-smoke",
  "artifact_dir": "",
  "last_exit_code": 0,
  "current_exec_pid": 0,
  "current_exec_round": 0,
  "pending_human_message_count": 0,
  "reflection_level": "plain",
  "last_completed_round": 0,
  "last_round_action_count": 0,
  "last_round_outcome": "none"
}
EOF

cat >"$EXEC_STATUS_FILE" <<EOF
{
  "run_id": "",
  "round": 0,
  "pid": 0,
  "status": "stopped",
  "updated_at": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
  "output_file": "",
  "error_file": "",
  "events_file": "",
  "round_dir": ""
}
EOF

echo "$LOOP_SESSION"
