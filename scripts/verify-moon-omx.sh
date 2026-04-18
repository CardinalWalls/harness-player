#!/usr/bin/env bash
set -euo pipefail

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
echo "== done =="
