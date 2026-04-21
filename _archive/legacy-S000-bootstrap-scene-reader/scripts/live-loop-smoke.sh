#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="$ROOT/tmp/live/current"
SMOKE_MESSAGE="live-loop smoke interrupt $(date '+%H%M%S')"

cleanup() {
  "$ROOT/scripts/stop-live-loop.sh" >/dev/null 2>&1 || true
}
trap cleanup EXIT

json_field() {
  local file="$1"
  local field="$2"
  python3 - "$file" "$field" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
field = sys.argv[2]
payload = json.loads(path.read_text(encoding="utf-8"))
value = payload
for part in field.split("."):
    value = value[part]
print(value)
PY
}

wait_for() {
  local description="$1"
  local timeout_seconds="$2"
  local command="$3"
  local elapsed=0
  while (( elapsed < timeout_seconds )); do
    if eval "$command"; then
      return 0
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done
  echo "live-loop smoke failed: timed out waiting for $description" >&2
  exit 1
}

"$ROOT/scripts/preflight.sh"
CDDA_INSTALL_DIR="$ROOT/tmp/runtime/cdda-terminal" "$ROOT/scripts/install-cdda-terminal.sh"
tmux kill-session -t cdda-dashboard-web-clean 2>/dev/null || true
"$ROOT/scripts/stop-live-loop.sh" >/dev/null 2>&1 || true

DASHBOARD_URL="$("$ROOT/scripts/open-dashboard.sh" | tail -n 1)"
"$ROOT/scripts/open-live-loop.sh" >/dev/null

wait_for "loop status file" 30 "[ -f '$STATE_DIR/loop-status.json' ]"
wait_for "first completed round" 180 "[ \"\$(json_field '$STATE_DIR/loop-status.json' last_completed_round)\" -ge 1 ]"

RUN_ID="$(json_field "$STATE_DIR/loop-status.json" run_id)"
RUN_DIR="$ROOT/artifacts/live-loop/$RUN_ID"

wait_for "first round summary" 60 "find '$RUN_DIR' -name 'round-summary.json' | grep -q ."

curl -fsS -X POST "$DASHBOARD_URL/api/live-config" \
  -H 'Content-Type: application/json' \
  --data '{"reflection_level":"story"}' >/dev/null

wait_for "second running round" 120 "[ \"\$(json_field '$STATE_DIR/loop-status.json' current_exec_round)\" -ge 2 ] && [ \"\$(json_field '$STATE_DIR/loop-status.json' round_status)\" = 'running' ]"
TARGET_ROUND="$(json_field "$STATE_DIR/loop-status.json" current_exec_round)"

curl -fsS -X POST "$DASHBOARD_URL/api/human-message" \
  -H 'Content-Type: application/json' \
  --data "$(printf '{"text":"%s"}' "$SMOKE_MESSAGE")" >/dev/null

wait_for "interrupted round outcome" 60 "[ \"\$(json_field '$STATE_DIR/loop-status.json' last_round_outcome)\" = 'interrupted' ] && [ \"\$(json_field '$STATE_DIR/loop-status.json' last_completed_round)\" -ge '$TARGET_ROUND' ]"
INTERRUPTED_ROUND="$(json_field "$STATE_DIR/loop-status.json" last_completed_round)"

wait_for "next round request with human message" 120 "[ \"\$(json_field '$STATE_DIR/loop-status.json' round)\" -gt '$INTERRUPTED_ROUND' ] && grep -Fq '$SMOKE_MESSAGE' '$STATE_DIR/request.txt'"
wait_for "game-state document" 20 "grep -Fq '# Game State' '$STATE_DIR/game-state.md'"
wait_for "story reflection level applied" 60 "[ \"\$(json_field '$STATE_DIR/loop-status.json' reflection_level)\" = 'story' ]"

ROUND_SUMMARIES="$(find "$RUN_DIR" -name 'round-summary.json' | wc -l | tr -d ' ')"
echo "live-loop smoke ok"
echo "dashboard: $DASHBOARD_URL"
echo "run id: $RUN_ID"
echo "round summaries: $ROUND_SUMMARIES"
