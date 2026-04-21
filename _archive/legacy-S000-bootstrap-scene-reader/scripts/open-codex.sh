#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$ROOT/scripts/preflight.sh"
CDDA_INSTALL_DIR="$ROOT/tmp/runtime/cdda-terminal" "$ROOT/scripts/install-cdda-terminal.sh"

exec codex \
  -C "$ROOT" \
  -m gpt-5.3-codex-spark \
  -a never \
  -s workspace-write \
  --enable apps \
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
  -c 'mcp_servers.cdda.required=true' \
  -c "mcp_servers.cdda.command=\"$ROOT/scripts/start-cdda-mcp.sh\"" \
  -c 'mcp_servers.cdda.startup_timeout_sec=60' \
  -c 'mcp_servers.cdda.tool_timeout_sec=120' \
  -c "mcp_servers.cdda.env={CDDA_ROOT=\"$ROOT\",CDDA_INSTALL_DIR=\"$ROOT/tmp/runtime/cdda-terminal\",CDDA_HOME_DIR=\"$ROOT/tmp/runtime/home\",CDDA_SESSION_NAME=\"cdda-curses\"}"
