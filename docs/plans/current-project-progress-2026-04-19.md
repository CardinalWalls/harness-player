# Current Project Progress - 2026-04-19

## Summary

As of **2026-04-19**, this repository is at a **clear local milestone**:

- `CEP-1` remains the ratified execution authority.
- The MoonBit proof slice is runnable through `moon run cmd/main`.
- The CLI can now persist a materialized export artifact to `artifacts/materialized-exports/`.
- The repo-local OMX validation lane and combined preflight lane both pass locally.

In short: the project is no longer just planning plus substrate code. It now has a locally runnable, locally verifiable, CLI-visible proof slice with a real write path.

## What is clearly complete

### 1. Planning authority is stable

The active execution package is `CEP-1`, documented under `docs/plans/` and tied to the asset-centric control-plane direction.

### 2. The first proof slice is runnable

Run:

```bash
moon run cmd/main
```

This prints the current thin-surface proof across package, session, channel, topology, projection, lineage, capture, control, and export summaries.

### 3. The first persisted export path exists

Run:

```bash
moon run cmd/main -- --report-mode materialized-export --route-body "pause on lineage review" --write-export
```

This writes a materialized export artifact under `artifacts/materialized-exports/` instead of only printing a report. That is the clearest proof that the project has crossed from in-memory/demo reporting into a real local materialization path.

### 4. Local verification is green

Fresh verification run on **2026-04-19**:

- `moon check` — passed
- `moon test` — passed (`46/46`)
- `moon fmt --check` — passed
- `moon info` — passed
- `bash ./scripts/verify-omx-runtime.sh` — passed
- `bash ./scripts/verify-preflight.sh` — passed

## Current delivery status

### Locally true

- MoonBit package/test surface is green.
- Repo-local OMX setup is healthy enough for local runtime and preflight verification.
- `omx exec` smoke passes in the current repo-local setup.
- The CLI-visible materialized export flow is demonstrated locally.

### Not yet claimed here

- Hosted GitHub Actions were **not** re-run live as part of this checkpoint.
- Remote PR/update/push status is **not** part of this local proof.
- The worktree is **not clean**; it still contains tracked and untracked local changes.

## Most important remaining gap

The main remaining gap is no longer basic implementation viability.
It is **delivery clarity**:

- decide which subset of the current local changes should be committed together
- push/update the branch when ready
- confirm the hosted GitHub workflows on the resulting remote revision

## Recommended next step

If the goal is delivery, the next highest-value step is:

1. keep the current verified milestone intact
2. group the current local changes into a reviewable commit set
3. push/update the branch
4. confirm hosted CI and PR-review behavior remotely

If the goal is product expansion instead, the next implementation slice should build on the now-proven persisted export/materialization path rather than reopening planning scope.
