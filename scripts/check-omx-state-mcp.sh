#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPAIR=0
FORCE=0
WARN_ONLY=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repair)
      REPAIR=1
      ;;
    --force)
      FORCE=1
      ;;
    --warn-only)
      WARN_ONLY=1
      ;;
    *)
      echo "usage: $0 [--repair] [--force] [--warn-only]" >&2
      exit 2
      ;;
  esac
  shift
done

running_in_active_codex_thread() {
  [ -n "${CODEX_THREAD_ID:-}" ] || return 1

  parent_command="$(ps -o command= -p "${PPID:-0}" 2>/dev/null || true)"
  case "$parent_command" in
    *"codex app-server"*) return 0 ;;
  esac

  case "${CODEX_INTERNAL_ORIGINATOR_OVERRIDE:-}" in
    "Codex Desktop") return 0 ;;
  esac

  return 1
}

list_mcp_processes() {
  local ps_output

  if ! ps_output="$(ps axww -o pid=,ppid=,command= 2>/dev/null)"; then
    echo "Unable to inspect OMX MCP server processes via ps." >&2
    echo "Run this check from a terminal that permits process inspection." >&2
    return 2
  fi

  while IFS= read -r line; do
    line="${line#"${line%%[![:space:]]*}"}"
    [ -z "$line" ] && continue

    pid="${line%%[[:space:]]*}"
    rest="${line#"$pid"}"
    rest="${rest#"${rest%%[![:space:]]*}"}"
    ppid="${rest%%[[:space:]]*}"
    cmd="${rest#"$ppid"}"
    cmd="${cmd#"${cmd%%[![:space:]]*}"}"

    case "$cmd" in
      *state-server.js*) server="state" ;;
      *memory-server.js*) server="memory" ;;
      *code-intel-server.js*) server="code-intel" ;;
      *trace-server.js*) server="trace" ;;
      *wiki-server.js*) server="wiki" ;;
      *) continue ;;
    esac

    printf "%s\t%s\t%s\t%s\n" "$ppid" "$server" "$pid" "$cmd"
  done <<<"$ps_output" | sort -t "$(printf '\t')" -k1,1n -k2,2 -k3,3n
}

find_duplicate_rows() {
  awk -F '\t' '
    {
      rows[NR] = $0
      groups[NR] = $1 FS $2
      pids[NR] = $3
      latest[groups[NR]] = $3
      count[groups[NR]]++
    }
    END {
      for (i = 1; i <= NR; i++) {
        group = groups[i]
        if (count[group] > 1 && pids[i] != latest[group]) {
          print rows[i]
        }
      }
    }
  ' "$1"
}

process_rows="$(mktemp)"
duplicate_rows="$(mktemp)"
trap 'rm -f "$process_rows" "$duplicate_rows"' EXIT

if ! list_mcp_processes >"$process_rows"; then
  if [ "$WARN_ONLY" -eq 1 ]; then
    echo "Warning only: unable to inspect OMX MCP server processes in this environment."
    echo "Proceeding without duplicate sibling detection."
    exit 0
  fi
  exit 2
fi

if [ ! -s "$process_rows" ]; then
  echo "No OMX MCP server processes found."
  exit 0
fi

find_duplicate_rows "$process_rows" >"$duplicate_rows"

if [ ! -s "$duplicate_rows" ]; then
  echo "No duplicate OMX MCP sibling processes found."
  echo
  echo "Current OMX MCP server processes:"
  cat "$process_rows"
  exit 0
fi

echo "Duplicate OMX MCP sibling processes:"
while IFS=$'\t' read -r ppid server pid cmd; do
  echo "  pid=${pid} ppid=${ppid} server=${server} cmd=${cmd}"
done <"$duplicate_rows"

if [ "$WARN_ONLY" -eq 1 ]; then
  echo
  echo "Warning only: duplicate OMX MCP siblings detected."
  echo "Continuing without repair; use an external terminal to clean them up later if needed."
  exit 0
fi

if [ "$REPAIR" -eq 0 ]; then
  echo
  echo "Run ./scripts/repair-omx-state-mcp.sh from an external terminal to clean them up."
  exit 1
fi

echo
if [ "$FORCE" -ne 1 ] && running_in_active_codex_thread; then
  echo "Repair requested from an active Codex Desktop thread; refusing to reset the"
  echo "current conversation transport."
  echo
  echo "Open an external terminal at the repo root and run:"
  echo "  bash ./scripts/repair-omx-state-mcp.sh"
  echo
  echo "If you intentionally want to reset the current thread transport, rerun:"
  echo "  bash ./scripts/check-omx-state-mcp.sh --repair --force"
  exit 2
fi

echo "Repair requested; delegating to scripts/repair-omx-state-mcp.sh ..."
if [ "$FORCE" -eq 1 ]; then
  exec bash "$ROOT_DIR/scripts/repair-omx-state-mcp.sh" --force
fi
exec bash "$ROOT_DIR/scripts/repair-omx-state-mcp.sh"
