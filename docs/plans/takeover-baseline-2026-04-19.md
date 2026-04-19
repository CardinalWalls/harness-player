# Takeover Baseline - 2026-04-19

- Status: `validated-local-baseline`
- Date: `2026-04-19`
- Scope: repository takeover / operator handoff baseline

## Purpose

Record the current verified takeover baseline in a tracked document instead of leaving it only in `.omx/` runtime state.

## Active lanes

### Full-auto lane

```text
$ralplan -> $team -> $ralph
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
- The current proof slice now also exposes a CLI-visible `materialized-export` report mode under `cmd/main/` that surfaces package, checkpoint, capture, materialization, payload, registry, manifest, activation, and surface summaries through the existing mock/materialization seams.
- The Freeze C handoff note and the CLI gate are coherent with current local execution.

## Non-claims / limits

- This note does **not** claim that GitHub Actions were executed live on GitHub.
- GitHub workflow validation in this takeover was local/coherence-only.
- This note does **not** claim that existing local edits have been reviewed line-by-line for product intent; only that the declared validation baseline currently passes.

## Latest continuation step

The current repository continuation step after takeover baseline verification is complete:

- the CLI proof slice now advances beyond summary-only output via:
  - `moon run cmd/main -- --report-mode materialized-export --route-body "pause on lineage review" --write-export`
- this path keeps the default thin-surface report intact while exposing a fuller materialized export view built from:
  - package/export metadata
  - checkpoint metadata
  - normalized capture linkage
  - provenance/materialization routing
  - mock payload, registry, manifest, and activation seams
- the materialized export report is now also persisted to:
  - `artifacts/materialized-exports/pkg-story-distiller-v1-checkpoint-1.txt` (or a numbered sibling when that filename already exists)

Why this matters:

- the CLI surface no longer stops at compact export summaries only
- the materialized export path is now both visible and durably written to disk from the CLI
- the first persisted export/materialization write path now exists without broadening the mock or provenance contracts

## Highest-value next step

Advance from the first persisted text export write toward a structured export bundle or manifest that can be re-read without parsing the human-facing multiline report.

Why this is the next step:

- the current proof slice now proves routing, capture, lineage, export, materialization reporting, and one real persisted write end-to-end
- the persisted artifact is still the human-facing multiline report body rather than a structured export package or manifest
- the repository's product thesis centers durable assets and provenance, so the next strongest move is to make the persisted export machine-readable and eventually round-trippable

## 2026-04-19 automation revalidation addendum

During a fresh revalidation from the active Codex thread:

- `omx doctor` still passed
- live OMX MCP parity still responded through the repo-attached state/memory/trace tools
- `bash ./scripts/check-omx-state-mcp.sh --warn-only` now degrades to a warning when `ps` inspection is blocked by the in-thread sandbox
- the official repo-local automation lane `bash ./scripts/omx-takeover.sh --auto` now advances past the warning-only transport check and stops at the next real blocker: repo-local `.codex/` is not writable in this sandbox, so `omx exec` cannot create session/state files

Current continuation boundary:

- local MoonBit proof remains green
- non-interactive OMX takeover requires an external terminal or another environment that can write `.codex/`
- after that environment boundary is removed, rerun `bash ./scripts/omx-takeover.sh --auto` before moving on to the next structured export/import slice
