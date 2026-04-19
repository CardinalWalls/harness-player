# finall-start-100-commits

`finall-start-100-commits` is the primary repository for this project.

It combines three layers in one place:

- **OMX** for planning, orchestration, and long-running execution modes
- **MoonBit** for the real implementation and validation signal
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

## CLI-first development standard

Development in this repository is CLI-first.

- Build runnable features behind repo-owned CLI entrypoints, preferably under `cmd/`, so they can be executed with `moon run`.
- Use `moon` commands as the primary implementation and validation surface.
- Use scripts in `scripts/` to package the default verification path for both local work and automation.
- Use OMX to orchestrate planning, agent workflows, and long-running execution, but not to replace the repository's own CLI contract.

For the repository-wide official OMX usage model, read [docs/official-omx-usage.md](./docs/official-omx-usage.md).

## Fastest local validation

Run these from the repo root:

```bash
bash ./scripts/check-omx-state-mcp.sh --repair
bash ./scripts/verify-moon-omx.sh
bash ./scripts/verify-preflight.sh
```

If you use `--repair`, prefer running it from an external terminal instead of
inside the currently active Codex desktop thread, because it may kill duplicate
MCP siblings that are still attached to the active thread.
The repair script now refuses to run inside an active Codex Desktop thread
unless you pass `--force`.

The scripts validate:

- live `omx_state` MCP transport health
- duplicate OMX MCP sibling process cleanup
- `moon version`
- `moon check`
- `moon test`
- `moon fmt`
- `moon info`
- `omx doctor`
- `CODEX_HOME=.codex codex login status`
- `moon coverage analyze -- -f html -o coverage.html`
- workflow and template file presence

For the non-interactive OMX automation lane, the repo-local `.codex/` directory
must also be writable because `omx exec` creates session/state files there.

## OMX takeover and automation

Use different OMX entrypoints for different jobs:

- `omx --madmax --high` is the official recommended interactive launch surface for trusted local environments.
- `omx resume` restores an existing interactive Codex session from the terminal.
- `omx exec` is the non-interactive batch surface for scripts and CI.
- `omx team` is the durable parallel execution surface and uses isolated git worktrees by default.
- inside Codex, use the official workflow skills such as `$deep-interview`, `$ralplan`, `$autopilot`, `$ulw`, `$team`, `$ralph`, and `$ultraqa`.

Important reminder:

- `omx resume` is not an automation command. It restores an interactive session and may wait for user input.
- `omx exec` is useful for one-shot automation, but upstream docs present it as batch execution rather than the primary interactive operator entrypoint.
- If you want the repository's full official OMX operating model, use the interactive launch plus the official workflow skills described in [docs/official-omx-usage.md](./docs/official-omx-usage.md).

Repository note:

- the exact "default way we operate this repo" is our local convention layered on top of the upstream OMX docs
- [docs/official-omx-usage.md](./docs/official-omx-usage.md) now distinguishes upstream OMX recommendations from repository-local policy

Continuation note:

- the repository-local default is to keep going after local verification when the next step is routine delivery work and the required git/GitHub access is already available
- that means local green -> push/update branch -> update or create PR -> watch hosted checks -> continue into the next tracked grounded stage when feasible
- only explicit blockers, missing access, destructive actions, or real ambiguity should stop the flow

Recommended automated takeover:

```bash
bash ./scripts/omx-takeover.sh --auto
```

If you need fully non-interactive full-access execution inside an already isolated environment:

```bash
bash ./scripts/omx-takeover.sh --auto --madmax
```

Recommended interactive workflow:

```text
$deep-interview "clarify the task"
$ralplan "approve the implementation and verification path"
$ralph "carry the approved change to completion with MoonBit validation"
```

For broader parallel work, use `team` instead of `ralph`.

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
- `moon fmt`
- `moon info`
- `moon coverage analyze -- -f html -o coverage.html`

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
