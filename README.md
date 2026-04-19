# finall-start-100-commits

`finall-start-100-commits` is the primary repository for this project.

It combines three layers in one place:

- **OMX** for planning, orchestration, and long-running execution modes
- **MoonBit** for the structured product substrate and the repo-owned CLI/product paths that are intentionally implemented in MoonBit
- **GitHub Actions** for PR-time CI and review automation

## What is already wired

- Project planning artifacts under `docs/`
- Project-local OMX state under `.omx/`
- Repo-tracked skill source under `skills/`
- Repo-local workflow skills under `skills/`
- A minimal MoonBit package that supports real validation
- GitHub workflows for:
  - MoonBit CI
  - Codex PR review comments
- PR and issue templates for repeatable implementation work


## Current verified milestone (2026-04-19)

The repository is currently at a **locally verified CEP-1 / first-proof milestone**.

That means the branch already has all of these in place at the same time:

- ratified `CEP-1` planning authority under `docs/plans/`
- a MoonBit-backed thin CLI surface via `moon run cmd/main`
- a persisted materialized-export write path via `--report-mode materialized-export --write-export`
- repo-local OMX runtime/preflight scripts that currently pass end-to-end local checks

Fresh local evidence gathered on **2026-04-19**:

- `moon check` ✅
- `moon test` ✅ (`46/46` passed)
- `moon fmt --check` ✅
- `moon info` ✅
- `bash ./scripts/verify-omx-runtime.sh` ✅
- `bash ./scripts/verify-preflight.sh` ✅

Fastest way to see the current product slice:

```bash
moon run cmd/main
moon run cmd/main -- --report-mode materialized-export --route-body "pause on lineage review" --write-export
```

The first command shows the current thin-surface proof.
The second command proves the current persisted export/materialization path by writing under `artifacts/materialized-exports/`.

For the grounded status snapshot and remaining gaps, read [docs/plans/current-project-progress-2026-04-19.md](./docs/plans/current-project-progress-2026-04-19.md).

## CLI-first development standard

Development in this repository is CLI-first.

- Build runnable features behind repo-owned CLI entrypoints, preferably under `cmd/`, so they can be executed with `moon run`.
- Use `moon` commands as the primary implementation and validation surface for MoonBit-owned product code, package boundaries, and MoonBit-backed CLI behavior.
- Do not treat `moon` as the default validator for pure OMX/runtime/hook/tmux/transport issues or thin GitHub wrapper changes that leave MoonBit-owned product surfaces untouched.
- Use scripts in `scripts/` to package the default verification path for both local work and automation.
- Use OMX to orchestrate planning, agent workflows, and long-running execution, but not to replace the repository's own CLI contract.

For the repository-wide official OMX usage model, read [docs/official-omx-usage.md](./docs/official-omx-usage.md).

## Fastest local validation

Pick the validation lane that matches the layer you changed:

```bash
bash ./scripts/check-omx-state-mcp.sh --repair
bash ./scripts/verify-omx-runtime.sh
bash ./scripts/verify-moon-omx.sh
bash ./scripts/verify-preflight.sh
```

Use them this way:

- `verify-omx-runtime.sh` for OMX/runtime/hook/tmux/transport/auth/session issues
- `verify-moon-omx.sh` for MoonBit-owned product code, package boundaries, and MoonBit-backed CLI behavior
- `verify-preflight.sh` when you explicitly want combined release/preflight proof across both lanes

If you use `--repair`, prefer running it from an external terminal instead of
inside the currently active Codex desktop thread, because it may kill duplicate
MCP siblings that are still attached to the active thread.
The repair script now refuses to run inside an active Codex Desktop thread
unless you pass `--force`.

If duplicate OMX MCP siblings keep recurring and you want a real clean restart,
use the restart lane from an external terminal:

```bash
bash ./scripts/omx-takeover.sh --restart --auto
```

That path archives restartable `.omx` runtime state, repairs duplicate MCP
siblings, and then relaunches the repository takeover lane.

If the problem is specifically MCP transport death and you want a durable debug
artifact, capture the restart run to `.omx/logs/`:

```bash
bash ./scripts/capture-omx-transport-debug.sh
```

If you want to prove that the installed OMX pipeline orchestrator itself is
callable from this repository, run the repo-local bridge:

```bash
node ./scripts/run-autopilot-pipeline-bridge.mjs --task "Advance the current CLI-visible materialized export report toward the first true persisted export/materialization write path."
```

That bridge writes a report under `.omx/plans/` and is intentionally narrower
than a full prompt-side `$autopilot` launch: it proves direct pipeline API
invocation, not that the current installed keyword-trigger path is already wired
to the runner.

If you want the current CLI proof slice to persist the materialized export
report to disk instead of only printing it, run:

```bash
moon run cmd/main -- --report-mode materialized-export --route-body "pause on lineage review" --write-export
```

That writes the current export artifact to:

```text
artifacts/materialized-exports/pkg-story-distiller-v1-checkpoint-1.txt
```

If that filename already exists, the CLI writes to a numbered sibling such as
`artifacts/materialized-exports/pkg-story-distiller-v1-checkpoint-1.txt.1`
instead of overwriting the previous export.

This repository now also installs a repo-local UserPromptSubmit follow-through
hook at `.codex/hooks.json` that watches for prompt-side `autopilot`
activation. When the session-scoped `autopilot` seed is present, it:

- runs `scripts/run-autopilot-official-followthrough.mjs` inside tmux-backed OMX sessions
- falls back to `scripts/reconcile-autopilot-entry.mjs` outside tmux so the
  repo-local bridge still materializes the canonical `ralplan -> team -> ralph`
  handoff and clears the stale prompt seed

The hook writes operational traces under `.omx/logs/autopilot-followthrough-*.jsonl`.

The scripts validate:

- live `omx_state` MCP transport health
- duplicate OMX MCP sibling process cleanup
- `omx doctor`
- `CODEX_HOME=.codex codex login status`
- repo-local `.codex` runtime writability
- repo-local `omx exec` smoke
- `moon version`
- `moon check`
- `moon test`
- `moon fmt --check`
- `moon info`
- `moon coverage analyze -- -f html -o coverage.html`
- workflow and template file presence

The `moon*` checks above belong to the MoonBit/product lane or full preflight lane.

Operator note:

- `verify-omx-runtime.sh` is the OMX/runtime lane
- `verify-moon-omx.sh` is the MoonBit/product-substrate lane
- `verify-preflight.sh` is the combined delivery-readiness lane
- if the problem is MCP transport, duplicate siblings, `.codex` writability, hook routing, tmux behavior, or `omx exec`, start with `verify-omx-runtime.sh` instead of rerunning MoonBit
- rerun MoonBit only when MoonBit-owned product surfaces changed or when you explicitly want full preflight proof

For the non-interactive OMX automation lane, the repo-local `.codex/` directory
must also be writable because `omx exec` creates session/state files there.

## OMX takeover and automation

Use different OMX entrypoints for different jobs:

- `omx --madmax --high` is only a human-facing interactive launch surface. Do not treat it as the automation recommendation.
- `omx resume` restores an existing interactive Codex session from the terminal.
- `omx exec` is the non-interactive batch surface for scripts and CI.
- `omx team` is the durable parallel execution surface and uses isolated git worktrees by default.
- inside Codex, use the official workflow skills such as `$deep-interview`, `$ralplan`, `$autopilot`, `$ulw`, `$team`, `$ralph`, and `$ultraqa`.

Important reminder:

- `omx resume` is not an automation command. It restores an interactive session and may wait for user input.
- `omx exec` is useful for one-shot automation, but upstream docs present it as batch execution rather than the primary interactive operator entrypoint.
- The repository's default automation lane is `bash ./scripts/omx-takeover.sh --auto`.
- The repository's clean-start automation lane for repeated transport issues is `bash ./scripts/omx-takeover.sh --restart --auto` from an external terminal.
- The repository's highest-end official full-auto workflow is `$ralplan -> $team -> $ralph` for larger work, or `$autopilot -> $ulw -> $ralph` when the task is already clear.

Repository note:

- the exact "default way we operate this repo" is our local convention layered on top of the upstream OMX docs
- [docs/official-omx-usage.md](./docs/official-omx-usage.md) now distinguishes upstream OMX recommendations from repository-local policy
- MoonBit should sit at the product's structured center, not at every runtime boundary

Continuation note:

- the repository-local default is to keep going after local verification when the next step is routine delivery work and the required git/GitHub access is already available
- that means local green -> push/update branch -> update or create PR -> watch hosted checks -> continue into the next tracked grounded stage when feasible
- only explicit blockers, missing access, destructive actions, or real ambiguity should stop the flow

Recommended automated takeover:

```bash
bash ./scripts/omx-takeover.sh --auto
```

Recommended clean restart after repeated MCP transport or sibling-process issues:

```bash
bash ./scripts/omx-takeover.sh --restart --auto
```

If you need fully non-interactive full-access execution inside an already isolated environment:

```bash
bash ./scripts/omx-takeover.sh --auto --madmax
```

Recommended full-auto workflow:

```text
$ralplan -> $team -> $ralph
```

For clear execution-heavy work, use:

```text
$autopilot -> $ulw -> $ralph
```

Before launching `omx team`, prefer a clean main worktree so worker worktrees do not inherit unrelated local edits.

## GitHub workflow path

This repository includes two workflows:

- `.github/workflows/moonbit-ci.yml`
- `.github/workflows/codex-pr-review.yml`

### MoonBit CI

Runs on:

- pushes to `main`
- all pull requests

It installs MoonBit and runs:

- `moon check`
- `moon test`
- `moon fmt --check`
- `moon info`
- `moon coverage analyze -- -f html -o coverage.html`

Interpret that workflow as validation for MoonBit-owned product surfaces and release-preflight readiness, not as the first diagnostic for every OMX/runtime issue.

### Codex PR Review

Runs on pull request events:

- `opened`
- `synchronize`
- `reopened`

It:

- checks out the PR head commit
- fetches the base ref explicitly for diff scoping
- installs MoonBit
- runs `openai/codex-action`
- posts the result back to the PR as a comment

## Files to know

- `AGENTS.md` — repo contract
- `docs/official-omx-usage.md` — official OMX operating model for this repository
- `docs/` — canonical tracked specs and plans
- `skills/moonbit-omx-workflow/SKILL.md` — MoonBit + OMX workflow skill
- `skills/moonbit-omx-github-workflow/SKILL.md` — combined MoonBit + OMX + GitHub workflow skill
- `scripts/omx-takeover.sh` — repo wrapper for validated OMX takeover and automation
- `scripts/verify-moon-omx.sh` — fast MoonBit validation entrypoint
- `scripts/verify-preflight.sh` — local preflight entrypoint
- `scripts/run-autopilot-pipeline-bridge.mjs` — repo-local proof that the installed OMX pipeline API can be invoked directly
- `scripts/autopilot-userprompt-followthrough.mjs` — repo-local UserPromptSubmit hook that reconciles prompt-side `autopilot` activation into the repo's explicit `ralplan -> team -> ralph` lane
