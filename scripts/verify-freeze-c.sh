#!/usr/bin/env bash
set -euo pipefail

echo "== moon run cmd/main =="
moon run cmd/main

echo
echo "== moon run cmd/main -- --route-body 'pause on lineage review' =="
moon run cmd/main -- --route-body "pause on lineage review"

echo
echo "== phase 4 thin surface gate =="
echo "Freeze C CLI gate passed."
