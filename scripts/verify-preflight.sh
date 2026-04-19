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
echo "== repo-local codex auth =="
if command -v codex >/dev/null 2>&1; then
  CODEX_HOME="$PWD/.codex" codex login status
else
  echo "skipped: codex is not installed locally"
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
find .github/workflows -maxdepth 1 -type f | sort

echo
echo "== template files =="
find .github -maxdepth 2 \( -name 'pull_request_template.md' -o -name 'development-task.md' \) | sort

echo
echo "== done =="
