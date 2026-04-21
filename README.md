# bootstrap-scene-reader

This folder has been reset into an independent project checkout.

## Current status

- The old Git worktree pointer was broken and has been archived.
- The previous bootstrap-scene-reader implementation is no longer treated as the active implementation.
- `_mynot/` is intentionally preserved as project memory and layered planning material.
- The old MoonBit `cdda_native_contract` work has been moved to `_archive/legacy-S000-bootstrap-scene-reader/moonbit/` for reference before any rebuild.

## Active goal

The active goal is now **project reset and re-orientation**:

1. keep the historical planning/material evidence that may still be useful;
2. remove stale root-level claims that the project is already complete;
3. avoid treating the old MoonBit/domain-contract implementation as current truth;
4. make this directory a clean, standalone Git repository for the next intent/architecture pass.

## Important directories

- `_mynot/` — retained layered workspace/project memory. It may contain historical assumptions; validate before promoting anything back to current intent.
- `_archive/legacy-S000-bootstrap-scene-reader/` — archived old implementation, root docs, OMX plans/context, and broken worktree pointer.
- `.codex/` / `.omx/` — local agent/orchestration configuration. Runtime logs/state are ignored.
- `artifacts/` / `tmp/` — empty placeholders for future generated output.

## Rebuild rule

Do not resume from `moonbit/cdda_native_contract` as if it were the current codebase. If the MoonBit/domain-contract direction is still wanted, start from a fresh intent freeze and rebuild plan, using the archive only as evidence.
