#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$ROOT/.codex/config.toml"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"

fail() {
  echo "preflight failed: $1" >&2
  exit 1
}

for cmd in codex python3 tmux rsync curl hdiutil npx hermes; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    fail "missing command: $cmd"
  fi
done

if [[ ! -f "$CONFIG_FILE" ]]; then
  fail "missing local Codex config: $CONFIG_FILE"
fi

if ! grep -Eq '^model = "gpt-5\.3-codex-spark"$' "$CONFIG_FILE"; then
  fail "local Codex config must default to gpt-5.3-codex-spark"
fi

if ! grep -Eq '^\[features\]$' "$CONFIG_FILE" || ! grep -Eq '^codex_hooks = true$' "$CONFIG_FILE"; then
  fail "codex_hooks must be enabled in $CONFIG_FILE"
fi

if ! codex login status >/dev/null 2>&1; then
  fail "Codex auth unavailable in this shell; run codex login"
fi

if [[ ! -d "$CODEX_HOME_DIR" ]]; then
  fail "missing Codex home: $CODEX_HOME_DIR"
fi

if [[ ! -w "$CODEX_HOME_DIR" ]]; then
  fail "Codex home is not writable: $CODEX_HOME_DIR"
fi

if [[ -e "$CODEX_HOME_DIR/sessions" && ! -w "$CODEX_HOME_DIR/sessions" ]]; then
  fail "Codex sessions directory is not writable: $CODEX_HOME_DIR/sessions"
fi

if [[ -e "$CODEX_HOME_DIR/state_5.sqlite" && ! -w "$CODEX_HOME_DIR/state_5.sqlite" ]]; then
  fail "Codex state db is not writable: $CODEX_HOME_DIR/state_5.sqlite"
fi

if ! grep -qx 'en_US.UTF-8' < <(locale -a); then
  fail "missing locale en_US.UTF-8 required by the CDDA terminal build"
fi

echo "preflight ok: codex, hermes, tmux, rsync, curl, hdiutil, npx, python3, local spark config, auth, and Codex home write access are available"
