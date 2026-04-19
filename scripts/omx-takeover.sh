#!/usr/bin/env bash
set -euo pipefail

MODE="full"
REPAIR=0
FORCE=0
LAUNCH_MODE="auto"
MADMAX=0
PROMPT=${OMX_TAKEOVER_PROMPT:-}

usage() {
  cat <<'EOF'
usage: omx-takeover.sh [--fast|--full] [--repair] [--force] [--auto|--interactive] [--madmax] [--prompt "task"]

  --fast         Run OMX doctor, transport health, and MoonBit validation
  --full         Run the full local preflight (default)
  --repair       Repair duplicate OMX MCP siblings before validation
  --force        Allow repair inside the active thread transport
  --auto         Launch non-interactive takeover through omx exec (default)
  --interactive  Only print the recommended interactive OMX lane
  --madmax       Pass dangerously-bypass-approvals-and-sandbox to omx exec
  --prompt       Override the default omx exec takeover prompt
EOF
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

  omx "${exec_args[@]}" "$prompt_text"
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
if [ "$REPAIR" -eq 1 ]; then
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

echo
if [ "$MODE" = "fast" ]; then
  echo "== omx doctor =="
  if command -v omx >/dev/null 2>&1; then
    omx doctor
  else
    echo "skipped: omx is not installed locally"
  fi

  echo
  echo "== omx_state transport =="
  run_transport_check

  echo
  bash ./scripts/verify-moon-omx.sh

  echo
  bash ./scripts/verify-freeze-c.sh
else
  if [ "$REPAIR" -eq 1 ]; then
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
