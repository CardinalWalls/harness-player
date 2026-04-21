#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOWNLOAD_DIR="$ROOT/tmp/downloads"
INSPECT_DIR="$ROOT/tmp/inspect"
INSTALL_DIR="${CDDA_INSTALL_DIR:-$ROOT/tmp/runtime/cdda-terminal}"
DMG_URL="${CDDA_DMG_URL:-https://github.com/CleverRaven/Cataclysm-DDA/releases/download/0.H-RELEASE/cdda-osx-terminal-only-universal-2024-11-23-1857.dmg}"
DMG_FILE="$DOWNLOAD_DIR/cdda-terminal.dmg"

mkdir -p "$DOWNLOAD_DIR" "$INSPECT_DIR" "$(dirname "$INSTALL_DIR")"

if [[ -x "$INSTALL_DIR/cataclysm" && -d "$INSTALL_DIR/data" ]]; then
  echo "cdda terminal runtime already installed at $INSTALL_DIR"
  exit 0
fi

curl -L --fail -o "$DMG_FILE" "$DMG_URL"

ATTACH_OUT="$(hdiutil attach -nobrowse -readonly "$DMG_FILE")"
MOUNT_POINT="$(printf '%s\n' "$ATTACH_OUT" | awk -F '\t' '/\/Volumes\// {print $3; exit}')"

cleanup() {
  if [[ -n "${MOUNT_POINT:-}" && -d "$MOUNT_POINT" ]]; then
    hdiutil detach "$MOUNT_POINT" >/dev/null || true
  fi
}
trap cleanup EXIT

if [[ -z "$MOUNT_POINT" ]]; then
  echo "failed to mount $DMG_FILE" >&2
  exit 1
fi

rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
rsync -a "$MOUNT_POINT/Cataclysm.app/Contents/Resources/" "$INSTALL_DIR/"

if [[ ! -x "$INSTALL_DIR/cataclysm" ]]; then
  echo "install failed: missing $INSTALL_DIR/cataclysm" >&2
  exit 1
fi

echo "cdda terminal runtime installed at $INSTALL_DIR"
