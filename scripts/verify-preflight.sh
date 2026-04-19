#!/usr/bin/env bash
set -euo pipefail

bash ./scripts/verify-omx-runtime.sh

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
