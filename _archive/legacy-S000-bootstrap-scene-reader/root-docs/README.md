# cdda-demo-clean

Clean rebuild of the CDDA live-scene harness with a relationship-first dashboard.

## Validated Finding

- Nested `codex exec` is usable in this workspace.
- `workspace-write` nested runs can create files under `cdda-demo/tmp/`.
- The harness now includes a local MCP runtime server that can drive a tmux-backed CDDA curses build.
- `./scripts/smoke.sh` installs the terminal-only CDDA runtime if needed and drives it to an actual in-game screen through MCP tools.

This matters because the harness no longer stops at abstract feasibility. We can use Codex CLI itself as the agent surface while the runtime adapter owns tmux control and screen capture.

## Current Goal

- Keep the proven tmux + MCP runtime surface.
- Rebuild the demo in a cleaner workspace instead of extending the messy original repo.
- Present the web UI honestly, keeping CDDA raw state separate from captured/parsed channel views without claiming native contracts that do not yet exist.
- Preserve agent freedom by offering tools and smoke loops, not a heavy execution framework.

## First Commands

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/preflight.sh
./scripts/install-cdda-terminal.sh
./scripts/open-dashboard.sh
./scripts/open-codex.sh
./scripts/open-persistent-mcp.sh
./scripts/mcp-status.sh
./scripts/stop-persistent-mcp.sh
./scripts/open-clone-hermes-mcp.sh
./scripts/clone-hermes-mcp-status.sh
./scripts/stop-clone-hermes-mcp.sh
./scripts/open-autoplay.sh
./scripts/open-live-loop.sh
./scripts/smoke.sh
```

## Runbook

- Full operator guide: [RUNBOOK.md](/Users/yetian/Desktop/new-real-100-commits/RUNBOOK.md)
- Multi-agent design: [ARCHITECTURE.md](/Users/yetian/Desktop/new-real-100-commits/ARCHITECTURE.md)
- Browser entry after boot: [http://127.0.0.1:8875](http://127.0.0.1:8875)

## Current Shape

- `.codex/` holds local Codex CLI defaults for this subtree.
- `scripts/preflight.sh` checks local dependencies, locale support, and your current Codex login state.
- `scripts/install-cdda-terminal.sh` downloads the official macOS terminal-only CDDA build into `tmp/runtime/cdda-terminal/`.
- `scripts/start-cdda-mcp.sh` launches the local MCP server with the right runtime environment.
- `scripts/cdda_mcp_server.py` exposes tmux-backed runtime tools over MCP stdio.
- `scripts/open-codex.sh` launches `codex` in this folder with `spark`, `workspace-write`, `never`, and the local `cdda` MCP server wired in.
- `scripts/start-cdda-mcp-proxy.sh` exposes the local `cdda` stdio server as a persistent streamable HTTP MCP endpoint at `http://127.0.0.1:8766/mcp`.
- `scripts/open-persistent-mcp.sh` starts that persistent local MCP proxy in tmux, waits for it to answer MCP calls, and warms the shared `hermes-cdda` game session.
- `scripts/mcp-status.sh` checks whether the persistent MCP endpoint is ready and prints the current shared session status.
- `scripts/stop-persistent-mcp.sh` stops the persistent MCP proxy and the shared `hermes-cdda` game session.
- `scripts/clone_hermes_mcp_server.py` exposes the `clone_hermes` tmux session itself as a supervisory MCP surface.
- `scripts/start-clone-hermes-mcp-proxy.sh` exposes that clone wrapper over streamable HTTP at `http://127.0.0.1:8767/mcp`.
- `scripts/open-clone-hermes-mcp.sh` starts the clone wrapper proxy without disturbing an already-running `clone_hermes` session.
- `scripts/clone-hermes-mcp-status.sh` checks whether the clone wrapper MCP endpoint is ready and prints the current clone session status.
- `scripts/stop-clone-hermes-mcp.sh` stops only the clone wrapper proxy, not the clone session itself.
- `scripts/open-dashboard.sh` starts the relationship-first local dashboard on `http://127.0.0.1:8875`, preserving the tmux-backed runtime while reorganizing the web view into use-case and topology sections.
- `scripts/open-autoplay.sh` starts one bounded background `codex exec` run that attaches to `cdda-smoke`, makes a conservative batch of in-game decisions, and leaves logs under `artifacts/autoplay/<run-id>/`.
- `scripts/stop-autoplay.sh` stops the latest background autoplay tmux session if it is still running.
- `scripts/open-live-loop.sh` starts a persistent background loop that keeps launching bounded `codex exec` rounds, alternating one safe game action with one public livestream commentary update for the dashboard.
- `scripts/stop-live-loop.sh` stops the persistent live loop session.
- `scripts/smoke.sh` resets a tiny workspace under `tmp/smoke/current/`, ensures the terminal runtime is installed, and runs one bounded `codex exec` smoke that reaches an in-game screen.
- `fixtures/smoke-cdda/` contains the tiny local request used by the runtime smoke.

This folder is intentionally thin. Runtime adapters, MCP tools, and the human channel can grow here once the smoke loop stays healthy.

## Persistent MCP

Run this once to keep a local MCP endpoint ready for another agent:

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/open-persistent-mcp.sh
```

The shared local MCP endpoint is:

```text
http://127.0.0.1:8766/mcp
```

It serves the same `cdda` tools over streamable HTTP and keeps the shared game session name fixed as `hermes-cdda`.

## Clone MCP

Run this to expose the already-running `clone_hermes` worker as its own MCP endpoint:

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/open-clone-hermes-mcp.sh
```

The local supervisory MCP endpoint is:

```text
http://127.0.0.1:8767/mcp
```

This wrapper is designed to attach to an existing `clone_hermes` tmux session by default. It will not restart the clone unless an MCP client explicitly calls `clone_restart`.

## Latest Evidence

- Nested write test succeeded: `codex exec` created `tmp/nested-write-test.txt` during validation.
- The runtime path is now concrete: official terminal-only CDDA build -> tmux session -> MCP tools (`ensure_game`, `observe`, `act`) -> Codex smoke.
- Smoke artifacts include the Codex transcript, an MCP event log, and the final captured game screen under `artifacts/smoke/<run-id>/`.
