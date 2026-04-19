#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORCE=0

if [ "${1:-}" = "--force" ]; then
  FORCE=1
  shift
fi

if [ "$#" -ne 0 ]; then
  echo "usage: $0 [--force]" >&2
  exit 2
fi

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

if [ "$FORCE" -ne 1 ] && running_in_active_codex_thread; then
  echo "Refusing to run inside an active Codex Desktop thread." >&2
  echo >&2
  echo "This repair kills duplicate MCP sibling processes and can close the transport" >&2
  echo "for the current conversation. Open an external terminal at the repo root and" >&2
  echo "run: bash ./scripts/repair-omx-state-mcp.sh" >&2
  echo >&2
  echo "If you intentionally want to reset the current thread transport, rerun with --force." >&2
  exit 2
fi

list_mcp_processes() {
  local ps_output

  if ! ps_output="$(ps axww -o pid=,ppid=,command= 2>/dev/null)"; then
    echo "Unable to inspect OMX MCP server processes via ps." >&2
    echo "Run this repair from a terminal that permits process inspection." >&2
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
stubborn_pids="$(mktemp)"
trap 'rm -f "$process_rows" "$duplicate_rows" "$stubborn_pids"' EXIT

list_mcp_processes >"$process_rows"

if [ ! -s "$process_rows" ]; then
  echo "No OMX MCP server processes found."
  exit 0
fi

find_duplicate_rows "$process_rows" >"$duplicate_rows"

if [ ! -s "$duplicate_rows" ]; then
  echo "No duplicate OMX MCP sibling processes found."
else
  echo "Duplicate OMX MCP sibling processes:"
  while IFS=$'\t' read -r ppid server pid cmd; do
    echo "  pid=${pid} ppid=${ppid} server=${server} cmd=${cmd}"
  done <"$duplicate_rows"

  echo
  echo "Sending SIGTERM to duplicate OMX MCP sibling processes..."
  while IFS=$'\t' read -r _ _ pid _; do
    kill -TERM "$pid" 2>/dev/null || true
  done <"$duplicate_rows"

  sleep 1

  while IFS=$'\t' read -r _ _ pid _; do
    if kill -0 "$pid" 2>/dev/null; then
      echo "$pid" >>"$stubborn_pids"
    fi
  done <"$duplicate_rows"

  if [ -s "$stubborn_pids" ]; then
    echo "Escalating to SIGKILL for stubborn OMX MCP sibling processes..."
    while IFS= read -r pid; do
      kill -KILL "$pid" 2>/dev/null || true
    done <"$stubborn_pids"
  fi
fi

if command -v omx >/dev/null 2>&1; then
  echo
  echo "Running omx cleanup for orphaned OMX MCP processes..."
  (cd "$ROOT_DIR" && omx cleanup) || true
fi

echo
echo "Remaining OMX MCP server processes:"
list_mcp_processes || true
