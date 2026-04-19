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
bash ./scripts/check-omx-state-mcp.sh "${check_args[@]}"

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
  # Current desktop/runtime path needs these disabled to avoid chatgpt.com plugin
  # marketplace and analytics 403s during non-interactive smoke checks.
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
echo "== moon version =="
moon version

echo
echo "== moon check =="
moon check

echo
echo "== moon test =="
moon test

echo
echo "== moon fmt --check =="
moon fmt --check

echo
echo "== moon info =="
moon info

echo
echo "== moon coverage =="
rm -rf coverage.html
moon coverage analyze -- -f html -o coverage.html
test -f coverage.html/index.html

echo
echo "== workflow files =="
for workflow_file in \
  .github/workflows/moonbit-ci.yml \
  .github/workflows/codex-pr-review.yml
do
  test -f "$workflow_file"
  echo "$workflow_file"
done

echo
echo "== template files =="
for template_file in \
  .github/pull_request_template.md \
  .github/ISSUE_TEMPLATE/development-task.md
do
  test -f "$template_file"
  echo "$template_file"
done

echo
echo "== done =="
