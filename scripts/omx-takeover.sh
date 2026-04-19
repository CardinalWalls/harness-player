#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="full"
REPAIR=0
FORCE=0
RESTART=0
ARCHIVE_RUNTIME=1
LAUNCH_MODE="auto"
MADMAX=0
TRANSPORT_DEBUG=0
PROMPT=${OMX_TAKEOVER_PROMPT:-}

usage() {
  cat <<'EOF'
usage: omx-takeover.sh [--fast|--full] [--repair] [--restart] [--no-archive-runtime] [--force] [--auto|--interactive] [--madmax] [--transport-debug] [--prompt "task"]

  --fast         Run OMX runtime/transport validation only
  --full         Run runtime/transport plus MoonBit/product preflight (default)
  --repair       Repair duplicate OMX MCP siblings before validation
  --restart      Archive restartable .omx runtime state, repair siblings, then restart takeover
  --no-archive-runtime
                 Keep current .omx runtime files in place during --restart
  --force        Allow repair inside the active thread transport
  --auto         Launch non-interactive takeover through omx exec (default)
  --interactive  Only print the recommended interactive OMX lane
  --madmax       Pass dangerously-bypass-approvals-and-sandbox to omx exec
  --transport-debug
                 Enable OMX_MCP_TRANSPORT_DEBUG=1 during omx exec
  --prompt       Override the default omx exec takeover prompt
EOF
}

running_in_active_codex_thread() {
  [ -n "${CODEX_THREAD_ID:-}" ] || return 1

  parent_command="$(ps -o command= -p "${PPID:-0}" 2>/dev/null || true)"
  case "$parent_command" in
    *"codex app-server"*) return 0 ;;
  esac

  case "${CODEX_INTERNAL_ORIGINATOR_OVERRIDE:-}" in
    "Codex Desktop") return 0 ;;
  esac

  return 1
}

archive_restartable_runtime_state() {
  local archive_dir timestamp moved rel src dst

  timestamp="$(date -u +%Y-%m-%dT%H%M%SZ)"
  archive_dir="$ROOT_DIR/.omx/archive/${timestamp}-clean-start"
  moved=0

  while IFS= read -r rel; do
    [ -z "$rel" ] && continue
    src="$ROOT_DIR/$rel"
    [ -e "$src" ] || continue

    dst="$archive_dir/$rel"
    mkdir -p "$(dirname "$dst")"
    mv "$src" "$dst"
    echo "archived: $rel"
    moved=1
  done <<'EOF'
.omx/context
.omx/ralph
.omx/plans/autopilot-impl.md
.omx/plans/autopilot-spec.md
.omx/state/current-task-baseline.json
.omx/state/deep-interview-state.json
.omx/state/dispatch.json
.omx/state/leader-runtime-activity.json
.omx/state/ralph-progress.json
.omx/state/session.json
.omx/state/skill-active-state.json
.omx/state/subagent-tracking.json
.omx/state/team-leader-nudge.json
.omx/state/team-state.json
EOF

  if [ "$moved" -eq 1 ]; then
    echo "runtime archive: ${archive_dir}"
  else
    rmdir "$archive_dir" 2>/dev/null || true
    echo "runtime archive: nothing restartable to archive"
  fi
}

run_restart_prep() {
  if [ "$RESTART" -ne 1 ]; then
    return 0
  fi

  if [ "$FORCE" -ne 1 ] && running_in_active_codex_thread; then
    echo "Restart requested from an active Codex Desktop thread; refusing to reset the current conversation transport."
    echo
    echo "Open an external terminal at the repo root and run:"
    echo "  bash ./scripts/omx-takeover.sh --restart --auto"
    echo
    echo "If you intentionally want to reset the current thread transport, rerun with --force."
    exit 2
  fi

  echo "== clean restart preparation =="
  if [ "$ARCHIVE_RUNTIME" -eq 1 ]; then
    archive_restartable_runtime_state
  else
    echo "runtime archive: skipped (--no-archive-runtime)"
  fi

  echo
  echo "== omx_state repair =="
  if [ "$FORCE" -eq 1 ]; then
    bash ./scripts/repair-omx-state-mcp.sh --force
  else
    bash ./scripts/repair-omx-state-mcp.sh
  fi

  echo
}

run_transport_check() {
  if [ "$REPAIR" -eq 1 ]; then
    if [ "$FORCE" -eq 1 ]; then
      bash ./scripts/check-omx-state-mcp.sh --repair --force
    else
      bash ./scripts/check-omx-state-mcp.sh --repair
    fi
  elif [ -n "${CODEX_THREAD_ID:-}" ]; then
    echo "active Codex thread detected; duplicate sibling checks run in warning-only mode"
    bash ./scripts/check-omx-state-mcp.sh --warn-only
  else
    bash ./scripts/check-omx-state-mcp.sh
  fi
}

default_prompt() {
  cat <<'EOF'
Take over this repository through the official OMX automation lane. First confirm OMX project readiness, repo-local Codex auth, omx_state transport health, and the MoonBit validation chain. Then continue execution through the repository's official OMX + MoonBit contract instead of stopping at validation. Treat omx resume as interactive recovery only, not as the automation surface. Report the active lane, validations completed, blockers, and the next highest-value implementation step.
EOF
}

run_automation_lane() {
  local prompt_text
  local -a exec_args

  if ! command -v omx >/dev/null 2>&1; then
    echo "skipped: omx is not installed locally"
    return 0
  fi

  if [ -n "$PROMPT" ]; then
    prompt_text="$PROMPT"
  else
    prompt_text="$(default_prompt)"
  fi

  exec_args=(
    exec
    --disable plugins
    --disable apps
    --disable general_analytics
    --skip-git-repo-check
    -C .
  )

  if [ "$MADMAX" -eq 1 ]; then
    exec_args+=(--dangerously-bypass-approvals-and-sandbox)
  else
    exec_args+=(--full-auto)
  fi

  if [ "$TRANSPORT_DEBUG" -eq 1 ]; then
    OMX_MCP_TRANSPORT_DEBUG=1 omx "${exec_args[@]}" "$prompt_text"
  else
    omx "${exec_args[@]}" "$prompt_text"
  fi
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --fast)
      MODE="fast"
      ;;
    --full)
      MODE="full"
      ;;
    --repair)
      REPAIR=1
      ;;
    --restart)
      RESTART=1
      REPAIR=1
      ;;
    --no-archive-runtime)
      ARCHIVE_RUNTIME=0
      ;;
    --force)
      FORCE=1
      ;;
    --auto)
      LAUNCH_MODE="auto"
      ;;
    --interactive)
      LAUNCH_MODE="interactive"
      ;;
    --madmax)
      MADMAX=1
      ;;
    --transport-debug)
      TRANSPORT_DEBUG=1
      ;;
    --prompt)
      if [ "$#" -lt 2 ]; then
        usage >&2
        exit 2
      fi
      PROMPT="$2"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

echo "== OMX takeover mode =="
echo "mode: ${MODE}"
echo "launch: ${LAUNCH_MODE}"
if [ "$RESTART" -eq 1 ]; then
  echo "clean restart: requested"
elif [ "$REPAIR" -eq 1 ]; then
  echo "transport repair: requested"
else
  echo "transport repair: no"
fi
if [ "$LAUNCH_MODE" = "auto" ]; then
  if [ "$MADMAX" -eq 1 ]; then
    echo "automation policy: madmax"
  else
    echo "automation policy: full-auto"
  fi
fi
if [ "$TRANSPORT_DEBUG" -eq 1 ]; then
  echo "transport debug: enabled"
fi

echo
run_restart_prep

if [ "$MODE" = "fast" ]; then
  bash ./scripts/verify-omx-runtime.sh
else
  if [ "$REPAIR" -eq 1 ] && [ "$RESTART" -ne 1 ]; then
    echo "== omx_state repair =="
    run_transport_check
    echo
  fi
  bash ./scripts/verify-preflight.sh

  echo
  bash ./scripts/verify-freeze-c.sh
fi

echo
if [ "$LAUNCH_MODE" = "auto" ]; then
  echo "== repo-local codex runtime =="
  bash ./scripts/check-repo-codex-runtime.sh
  echo
  echo "== starting OMX automation =="
  run_automation_lane
else
  echo "== recommended interactive OMX lane =="
  echo 'deep-interview "clarify the task"'
  echo 'ralplan "approve the implementation and verification path"'
  echo 'ralph "carry the approved change to completion with MoonBit validation"'
  echo
  echo "note: omx resume restores an interactive session and may wait for input."
  echo "note: use omx exec for non-interactive takeover, scripts, and CI."
fi
