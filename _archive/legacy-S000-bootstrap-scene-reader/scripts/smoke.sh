#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_ID="$(date '+%Y%m%d-%H%M%S')"
RUN_DIR="$ROOT/artifacts/smoke/$RUN_ID"
SMOKE_DIR="$ROOT/tmp/smoke/current"
PROMPT_FILE="$ROOT/prompts/cdda-smoke.md"
OUTPUT_FILE="$RUN_DIR/codex-output.txt"
ERROR_FILE="$RUN_DIR/codex-error.txt"
NOTE_FILE="$SMOKE_DIR/agent-note.md"
SESSION_NAME="cdda-smoke"
PROMPT_TEXT="$(cat "$PROMPT_FILE")"

"$ROOT/scripts/preflight.sh"
CDDA_INSTALL_DIR="$ROOT/tmp/runtime/cdda-terminal" "$ROOT/scripts/install-cdda-terminal.sh"

tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true
rm -rf "$SMOKE_DIR"
mkdir -p "$SMOKE_DIR" "$RUN_DIR"
rsync -a "$ROOT/fixtures/smoke-cdda/" "$SMOKE_DIR/"

set +e
CODEX_EXIT=1

for attempt in 1 2 3; do
  codex exec \
    -C "$ROOT" \
    -s workspace-write \
    --skip-git-repo-check \
    --ephemeral \
    -m gpt-5.3-codex-spark \
    --enable apps \
    -c 'approval_policy="never"' \
    -c 'model_reasoning_effort="high"' \
    -c 'apps._default.default_tools_approval_mode="approve"' \
    -c 'apps._default.open_world_enabled=true' \
    -c 'apps._default.destructive_enabled=true' \
    -c 'apps.cdda.enabled=true' \
    -c 'apps.cdda.default_tools_enabled=true' \
    -c 'apps.cdda.default_tools_approval_mode="approve"' \
    -c 'apps.cdda.open_world_enabled=true' \
    -c 'apps.cdda.destructive_enabled=true' \
    -c 'apps.cdda.tools.session_status.approval_mode="approve"' \
    -c 'apps.cdda.tools.ensure_game.approval_mode="approve"' \
    -c 'apps.cdda.tools.observe.approval_mode="approve"' \
    -c 'apps.cdda.tools.act.approval_mode="approve"' \
    -c 'apps.cdda.tools.reach_playable.approval_mode="approve"' \
    -c 'apps.cdda.tools.stop_session.approval_mode="approve"' \
    -c 'apps.mcp__cdda.enabled=true' \
    -c 'apps.mcp__cdda.default_tools_enabled=true' \
    -c 'apps.mcp__cdda.default_tools_approval_mode="approve"' \
    -c 'apps.mcp__cdda.open_world_enabled=true' \
    -c 'apps.mcp__cdda.destructive_enabled=true' \
    -c 'apps.mcp__cdda.tools.session_status.approval_mode="approve"' \
    -c 'apps.mcp__cdda.tools.ensure_game.approval_mode="approve"' \
    -c 'apps.mcp__cdda.tools.observe.approval_mode="approve"' \
    -c 'apps.mcp__cdda.tools.act.approval_mode="approve"' \
    -c 'apps.mcp__cdda.tools.reach_playable.approval_mode="approve"' \
    -c 'apps.mcp__cdda.tools.stop_session.approval_mode="approve"' \
    -c 'mcp_servers.openaiDeveloperDocs.enabled=false' \
    -c 'mcp_servers.cdda.required=true' \
    -c "mcp_servers.cdda.command=\"$ROOT/scripts/start-cdda-mcp.sh\"" \
    -c 'mcp_servers.cdda.startup_timeout_sec=60' \
    -c 'mcp_servers.cdda.tool_timeout_sec=120' \
    -c "mcp_servers.cdda.env={CDDA_ROOT=\"$ROOT\",CDDA_INSTALL_DIR=\"$ROOT/tmp/runtime/cdda-terminal\",CDDA_HOME_DIR=\"$ROOT/tmp/runtime/home\",CDDA_SESSION_NAME=\"$SESSION_NAME\",CDDA_FIXED_SESSION_NAME=\"1\",CDDA_EVENT_LOG=\"$RUN_DIR/events.jsonl\"}" \
    "$PROMPT_TEXT" >"$OUTPUT_FILE" 2>"$ERROR_FILE"
  CODEX_EXIT="$?"
  if [[ "$CODEX_EXIT" -eq 0 ]]; then
    break
  fi
  if [[ "$attempt" -lt 3 ]] && grep -Eiq 'dns error|failed to lookup address information|stream disconnected before completion|error sending request for url \(https://chatgpt.com/backend-api/codex/responses\)' "$ERROR_FILE"; then
    sleep 5
    continue
  fi
  break
done
set -e

if [[ "$CODEX_EXIT" -ne 0 ]]; then
  echo "smoke failed: codex exec exited with status $CODEX_EXIT" >&2
  [[ -s "$OUTPUT_FILE" ]] && tail -n 60 "$OUTPUT_FILE" >&2
  [[ -s "$ERROR_FILE" ]] && tail -n 60 "$ERROR_FILE" >&2
  exit "$CODEX_EXIT"
fi

if [[ ! -f "$NOTE_FILE" ]]; then
  echo "smoke failed: missing $NOTE_FILE" >&2
  [[ -s "$OUTPUT_FILE" ]] && tail -n 60 "$OUTPUT_FILE" >&2
  [[ -s "$ERROR_FILE" ]] && tail -n 60 "$ERROR_FILE" >&2
  exit 1
fi

FIRST_LINE="$(sed -n '1p' "$NOTE_FILE")"
SECOND_LINE="$(sed -n '2p' "$NOTE_FILE")"
THIRD_LINE="$(sed -n '3p' "$NOTE_FILE")"

if [[ "$FIRST_LINE" != "cdda-smoke-ok" ]]; then
  echo "smoke failed: first line must be cdda-smoke-ok" >&2
  [[ -s "$OUTPUT_FILE" ]] && tail -n 60 "$OUTPUT_FILE" >&2
  [[ -s "$ERROR_FILE" ]] && tail -n 60 "$ERROR_FILE" >&2
  exit 1
fi

if [[ -z "$SECOND_LINE" || -z "$THIRD_LINE" ]]; then
  echo "smoke failed: agent-note.md must contain three lines" >&2
  [[ -s "$OUTPUT_FILE" ]] && tail -n 60 "$OUTPUT_FILE" >&2
  [[ -s "$ERROR_FILE" ]] && tail -n 60 "$ERROR_FILE" >&2
  exit 1
fi

tmux capture-pane -p -t "$SESSION_NAME" -S -220 >"$RUN_DIR/final-screen.txt" || true

echo "smoke ok: $NOTE_FILE"
echo "artifact dir: $RUN_DIR"
echo "codex output: $OUTPUT_FILE"
echo "codex error: $ERROR_FILE"
