# Project Progress: `bootstrap-scene-reader` — independent reset

**Last Updated**: 2026-04-21
**Current Phase**: reset / re-orientation

> This is now the root progress file for the independent project checkout.
> `_mynot/` is preserved, but historical material inside it is not automatically current intent.

---

## Current Work

### RESET-000 — independent project cleanup

**Started**: 2026-04-21  
**Status**: In progress  
**Scope**: detach from broken worktree history, archive stale implementation surfaces, and prepare a clean standalone repository.

**Completed during reset**:
- [x] Verified old MoonBit baseline before archival: `moon info && moon fmt --check && moon test` passed, 13/13.
- [x] Archived broken `.git` worktree pointer.
- [x] Archived stale root docs and old implementation/runtime surfaces under `_archive/legacy-S000-bootstrap-scene-reader/`.
- [x] Preserved `_mynot/` in place.

**Remaining**:
- [x] Initialize standalone Git repository.
- [x] Commit reset baseline with Lore-style commit message.
- [ ] Decide the next fresh intent/architecture lane before rebuilding implementation.

---

## Archived / Historical

The previous `S000-bootstrap-scene-reader` lane is archived, not deleted:

- Archive root: `_archive/legacy-S000-bootstrap-scene-reader/`
- Previous MoonBit implementation: `_archive/legacy-S000-bootstrap-scene-reader/moonbit/`
- Previous root docs: `_archive/legacy-S000-bootstrap-scene-reader/root-docs/`
- Previous OMX plans/context: `_archive/legacy-S000-bootstrap-scene-reader/omx-artifacts/`

The old narrative about undoing `reach_playable()`, server-side `/api/*`, and server-authored `human-instruction.jsonl` is no longer the active project goal. It is historical context only.

---

## Next Decision Needed

Before new implementation, freeze the new intent:

- Is this still a CDDA/Hermes scene-reader test bench?
- Is MoonBit still desired as the domain-contract language?
- Which parts of `_mynot/` remain authoritative versus archived evidence?

Do not rebuild from the archived implementation without answering those at the intent layer.
