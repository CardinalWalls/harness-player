# Legacy archive: S000 bootstrap scene reader

This directory preserves the pre-reset implementation and root documentation from the former `new-real-100-commits-S000-bootstrap-scene-reader` worktree.

Archived on: 2026-04-21

Why archived:
- The folder is being made into an independent project rather than a broken Git worktree.
- The old current-goal narrative about undoing `reach_playable()`, server-side `/api/*`, and server-authored `human-instruction.jsonl` is no longer the active project goal.
- The MoonBit `cdda_native_contract` implementation is treated as historical evidence/reference, not the current implementation surface.

What is preserved:
- `root-docs/` — previous README/PROGRESS/ARCHITECTURE/RUNBOOK/realrun notes.
- `moonbit/` — previous MoonBit source, with generated `_build` caches removed before archival.
- `scripts/`, `web/`, `prompts/`, `fixtures/` — previous runtime/demo support files.
- `omx-artifacts/` — previous OMX plans/context from the old story lane.
- `BROKEN_GIT_WORKTREE_POINTER.txt` — the old invalid `.git` worktree pointer.

The `_mynot/` directory intentionally remains in place at repository root per user instruction. Treat it as retained project memory until a new intent/architecture pass decides which parts are still current.
