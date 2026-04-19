# Takeover Baseline - 2026-04-19

- Status: `validated-local-baseline`
- Date: `2026-04-19`
- Scope: repository takeover / operator handoff baseline

## Purpose

Record the current verified takeover baseline in a tracked document instead of leaving it only in `.omx/` runtime state.

## Active lanes

### Interactive durable lane

```bash
omx --madmax --high
```

Then continue with the explicit OMX workflow skills that match the job, for example:

```text
$deep-interview -> $ralplan -> $team/$ralph
```

### Non-interactive repo automation lane

```bash
bash ./scripts/omx-takeover.sh --auto
```

This lane is repository-local automation built on top of `omx exec` and should be treated as batch automation rather than the primary interactive operator surface.

## Local validation evidence

The following commands were executed locally on `2026-04-19` during takeover:

- `bash ./scripts/verify-preflight.sh`
- `bash ./scripts/verify-freeze-c.sh`

Observed results:

- `omx doctor` passed (`12 passed, 0 warnings, 0 failed`)
- `omx_state` transport check completed in active-thread warning-safe mode and reported no duplicate sibling processes
- repo-local Codex auth was available (`Logged in using ChatGPT`)
- repo-local Codex runtime writability check passed
- repo-local `omx exec` smoke returned `OMX-EXEC-OK`
- `moon check` passed
- `moon test` passed (`Total tests: 37, passed: 37, failed: 0.`)
- `moon fmt --check` passed
- `moon info` passed
- `moon coverage analyze -- -f html -o coverage.html` produced the local HTML report
- workflow/template presence checks passed locally
- Freeze C CLI gate passed via:
  - `moon run cmd/main`
  - `moon run cmd/main -- --route-body "pause on lineage review"`

## Current repository state at takeover

- The repository already contains in-progress takeover/preflight related edits in:
  - `AGENTS.md`
  - `README.md`
  - `scripts/check-omx-state-mcp.sh`
  - `scripts/repair-omx-state-mcp.sh`
  - `scripts/verify-preflight.sh`
  - `docs/official-omx-usage.md`
  - `scripts/check-repo-codex-runtime.sh`
  - `scripts/omx-takeover.sh`
  - `scripts/verify-freeze-c.sh`
- The current proof slice is runnable and currently exposes a CLI-first thin surface under `cmd/main/`.
- The Freeze C handoff note and the CLI gate are coherent with current local execution.

## Non-claims / limits

- This note does **not** claim that GitHub Actions were executed live on GitHub.
- GitHub workflow validation in this takeover was local/coherence-only.
- This note does **not** claim that existing local edits have been reviewed line-by-line for product intent; only that the declared validation baseline currently passes.

## Highest-value next step

Advance from the current summary-oriented CLI proof slice toward the first real durable export/materialization path.

Why this is the next step:

- the current CLI surface proves routing, capture, lineage, and export summaries end-to-end
- the proof slice still surfaces compact summary strings rather than a fuller materialized package/export workflow
- the repository's product thesis centers durable assets and provenance, so making export/materialization more concrete is the strongest next move after takeover baseline verification
