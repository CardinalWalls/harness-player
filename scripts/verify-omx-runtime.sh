#!/usr/bin/env bash
set -euo pipefail

run_optional_tool_check() {
  local label="$1"
  local command_name="$2"
  shift 2

  echo "== ${label} =="
  if command -v "$command_name" >/dev/null 2>&1; then
    "$@"
  else
    echo "skipped: ${command_name} is not installed locally"
  fi
}

echo
run_optional_tool_check "omx doctor" omx omx doctor

echo
echo "== omx_state transport =="
check_args=()
if [ -n "${CODEX_THREAD_ID:-}" ]; then
  echo "active Codex thread detected; duplicate sibling checks run in warning-only mode"
  check_args+=(--warn-only)
fi
if [ "${#check_args[@]}" -gt 0 ]; then
  bash ./scripts/check-omx-state-mcp.sh "${check_args[@]}"
else
  bash ./scripts/check-omx-state-mcp.sh
fi

echo
echo "== repo-local codex auth =="
if command -v codex >/dev/null 2>&1; then
  CODEX_HOME="$PWD/.codex" codex login status
else
  echo "skipped: codex is not installed locally"
fi

echo
echo "== repo-local codex runtime =="
bash ./scripts/check-repo-codex-runtime.sh

echo
echo "== repo-local omx exec smoke =="
if command -v omx >/dev/null 2>&1; then
  omx exec \
    --disable plugins \
    --disable apps \
    --disable general_analytics \
    --skip-git-repo-check \
    -C . \
    "Reply with exactly OMX-EXEC-OK"
else
  echo "skipped: omx is not installed locally"
fi

echo
echo "== done =="
