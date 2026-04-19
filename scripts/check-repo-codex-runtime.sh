#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_HOME_DIR="${CODEX_HOME:-$ROOT_DIR/.codex}"

usage() {
  cat <<'EOF'
usage: check-repo-codex-runtime.sh

Validates that the repo-local CODEX_HOME used by OMX automation can write
session/state files before `omx exec` is launched.
EOF
}

if [ "$#" -ne 0 ]; then
  usage >&2
  exit 2
fi

fail_runtime() {
  local detail="${1:-}"

  echo "repo-local Codex runtime is not writable: ${CODEX_HOME_DIR}" >&2
  if [ -n "$detail" ]; then
    echo "detail: ${detail}" >&2
  fi
  echo "omx exec requires writable session/state paths under CODEX_HOME." >&2
  echo "Use an external terminal or a sandbox that can write ${CODEX_HOME_DIR}." >&2
  exit 1
}

if [ ! -d "$CODEX_HOME_DIR" ]; then
  fail_runtime "directory does not exist"
fi

if [ ! -w "$CODEX_HOME_DIR" ]; then
  fail_runtime "directory is not writable"
fi

if ! mkdir -p "$CODEX_HOME_DIR/sessions" 2>/dev/null; then
  fail_runtime "unable to create or access ${CODEX_HOME_DIR}/sessions"
fi

if [ ! -w "$CODEX_HOME_DIR/sessions" ]; then
  fail_runtime "sessions directory is not writable"
fi

if [ -e "$CODEX_HOME_DIR/state_5.sqlite" ] && [ ! -w "$CODEX_HOME_DIR/state_5.sqlite" ]; then
  fail_runtime "state database is not writable"
fi

probe_dir="$CODEX_HOME_DIR/sessions/.omx-runtime-probe.$$"
if ! mkdir "$probe_dir" 2>/dev/null; then
  fail_runtime "unable to create session probe directory"
fi
rmdir "$probe_dir"

echo "repo-local Codex runtime writable: ${CODEX_HOME_DIR}"
