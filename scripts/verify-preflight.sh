#!/usr/bin/env bash
set -euo pipefail

echo "== omx doctor =="
omx doctor

echo
echo "== repo-local codex auth =="
CODEX_HOME="$PWD/.codex" codex login status

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
echo "== moon fmt =="
moon fmt

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
