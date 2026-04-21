#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_ID="$(date '+%Y%m%d-%H%M%S')"
RUN_DIR="$ROOT/artifacts/autoplay/$RUN_ID"
STATE_DIR="$ROOT/tmp/autoplay/current"
PROMPT_FILE="$ROOT/prompts/cdda-autoplay.md"
OUTPUT_FILE="$RUN_DIR/codex-output.txt"
ERROR_FILE="$RUN_DIR/codex-error.txt"
REQUEST_FILE="$STATE_DIR/request.txt"
NOTE_FILE="$STATE_DIR/agent-note.md"
STATUS_FILE="$STATE_DIR/status.txt"
SESSION_FILE="$STATE_DIR/tmux-session.txt"
RUN_FILE="$STATE_DIR/run-id.txt"
ARTIFACT_FILE="$STATE_DIR/artifact-dir.txt"
URL_FILE="$STATE_DIR/dashboard-url.txt"
AGENT_SESSION="cdda-autoplay-$RUN_ID"
GAME_SESSION="${CDDA_AUTOPLAY_GAME_SESSION:-cdda-smoke}"
MODEL="${CDDA_AUTOPLAY_MODEL:-gpt-5.3-codex-spark}"
MAX_DECISIONS="${CDDA_AUTOPLAY_MAX_DECISIONS:-12}"
WAIT_MS="${CDDA_AUTOPLAY_WAIT_MS:-900}"
STARTUP_WAIT_MS="${CDDA_AUTOPLAY_STARTUP_WAIT_MS:-3500}"
PROMPT_TEXT="$(cat "$PROMPT_FILE")"

"$ROOT/scripts/preflight.sh"
CDDA_INSTALL_DIR="$ROOT/tmp/runtime/cdda-terminal" "$ROOT/scripts/install-cdda-terminal.sh"
DASHBOARD_URL="$("$ROOT/scripts/open-dashboard.sh" | tail -n 1)"

while IFS= read -r existing_session; do
  [[ -n "$existing_session" ]] || continue
  tmux kill-session -t "$existing_session" 2>/dev/null || true
done < <(tmux list-sessions -F '#S' 2>/dev/null | grep '^cdda-autoplay-' || true)

rm -rf "$STATE_DIR"
mkdir -p "$STATE_DIR" "$RUN_DIR"

printf '%s\n' "$RUN_ID" >"$RUN_FILE"
printf '%s\n' "$RUN_DIR" >"$ARTIFACT_FILE"
printf '%s\n' "$AGENT_SESSION" >"$SESSION_FILE"
printf '%s\n' "$DASHBOARD_URL" >"$URL_FILE"
printf 'starting\n' >"$STATUS_FILE"
rm -f "$NOTE_FILE"

printf '%s\n' \
  "Goal: use Codex CLI through the local cdda MCP tools and make up to $MAX_DECISIONS safe in-game decisions." \
  "If needed, first reconnect to the existing game and reach a playable in-game screen." \
  "Prefer dismissing incidental popups with Escape, then explore conservatively around the evac shelter." \
  "Use small key sequences and re-observe after every action." \
  "Wait about $WAIT_MS ms after normal actions and about $STARTUP_WAIT_MS ms for initial startup or reconnect." \
  >"$REQUEST_FILE"

TMUX_CMD="
cd $(printf '%q' "$ROOT")
codex exec \
  -C $(printf '%q' "$ROOT") \
  -s workspace-write \
  --skip-git-repo-check \
  --ephemeral \
  -m $(printf '%q' "$MODEL") \
  --enable apps \
  -c 'approval_policy=\"never\"' \
  -c 'model_reasoning_effort=\"high\"' \
  -c 'apps._default.default_tools_approval_mode=\"approve\"' \
  -c 'apps._default.open_world_enabled=true' \
  -c 'apps._default.destructive_enabled=true' \
  -c 'apps.cdda.enabled=true' \
  -c 'apps.cdda.default_tools_enabled=true' \
  -c 'apps.cdda.default_tools_approval_mode=\"approve\"' \
  -c 'apps.cdda.open_world_enabled=true' \
  -c 'apps.cdda.destructive_enabled=true' \
  -c 'apps.cdda.tools.session_status.approval_mode=\"approve\"' \
  -c 'apps.cdda.tools.ensure_game.approval_mode=\"approve\"' \
  -c 'apps.cdda.tools.observe.approval_mode=\"approve\"' \
  -c 'apps.cdda.tools.act.approval_mode=\"approve\"' \
  -c 'apps.cdda.tools.reach_playable.approval_mode=\"approve\"' \
  -c 'apps.cdda.tools.stop_session.approval_mode=\"approve\"' \
  -c 'apps.mcp__cdda.enabled=true' \
  -c 'apps.mcp__cdda.default_tools_enabled=true' \
  -c 'apps.mcp__cdda.default_tools_approval_mode=\"approve\"' \
  -c 'apps.mcp__cdda.open_world_enabled=true' \
  -c 'apps.mcp__cdda.destructive_enabled=true' \
  -c 'apps.mcp__cdda.tools.session_status.approval_mode=\"approve\"' \
  -c 'apps.mcp__cdda.tools.ensure_game.approval_mode=\"approve\"' \
  -c 'apps.mcp__cdda.tools.observe.approval_mode=\"approve\"' \
  -c 'apps.mcp__cdda.tools.act.approval_mode=\"approve\"' \
  -c 'apps.mcp__cdda.tools.reach_playable.approval_mode=\"approve\"' \
  -c 'apps.mcp__cdda.tools.stop_session.approval_mode=\"approve\"' \
  -c 'mcp_servers.openaiDeveloperDocs.enabled=false' \
  -c 'mcp_servers.cdda.required=true' \
  -c 'mcp_servers.cdda.command=\"$(printf '%q' "$ROOT/scripts/start-cdda-mcp.sh")\"' \
  -c 'mcp_servers.cdda.startup_timeout_sec=60' \
  -c 'mcp_servers.cdda.tool_timeout_sec=120' \
  -c 'mcp_servers.cdda.env={CDDA_ROOT=\"$(printf '%q' "$ROOT")\",CDDA_INSTALL_DIR=\"$(printf '%q' "$ROOT/tmp/runtime/cdda-terminal")\",CDDA_HOME_DIR=\"$(printf '%q' "$ROOT/tmp/runtime/home")\",CDDA_SESSION_NAME=\"$(printf '%q' "$GAME_SESSION")\",CDDA_FIXED_SESSION_NAME=\"1\",CDDA_EVENT_LOG=\"$(printf '%q' "$RUN_DIR/events.jsonl")\"}' \
  $(printf '%q' "$PROMPT_TEXT") \
  >$(printf '%q' "$OUTPUT_FILE") \
  2>$(printf '%q' "$ERROR_FILE")
status=\$?
printf 'exit=%s\nfinished_at=%s\n' \"\$status\" \"\$(date '+%Y-%m-%d %H:%M:%S')\" >$(printf '%q' "$STATUS_FILE")
exec \$SHELL -l
"

tmux new-session -d -s "$AGENT_SESSION" "sh -lc $(printf '%q' "$TMUX_CMD")"

printf '%s\n' "$AGENT_SESSION"
printf '%s\n' "$RUN_DIR"
printf '%s\n' "$DASHBOARD_URL"
