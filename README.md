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

## Fastest local validation

Run these from the repo root:

```bash
bash ./scripts/verify-moon-omx.sh
bash ./scripts/verify-preflight.sh
```

The scripts validate:

- `moon version`
- `moon check`
- `moon test`
- `moon fmt`
- `moon info`
- `omx doctor`
- `CODEX_HOME=.codex codex login status`
- `moon coverage analyze -- -f html -o coverage.html`
- workflow and template file presence

## Fastest OMX workflow path

Open an OMX session in the repo and use the shortest realistic path:

```text
deep-interview "clarify the task"
ralplan "approve the implementation and verification path"
ralph "carry the approved change to completion with MoonBit validation"
```

For broader parallel work, use `team` instead of `ralph`.

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

- checks out the PR merge ref
- installs MoonBit
- runs `openai/codex-action`
- posts the result back to the PR as a comment

## Files to know

- `AGENTS.md` — repo contract
- `docs/` — canonical tracked specs and plans
- `skills/moonbit-omx-workflow/SKILL.md` — MoonBit + OMX workflow skill
- `skills/moonbit-omx-github-workflow/SKILL.md` — combined MoonBit + OMX + GitHub workflow skill
- `scripts/verify-moon-omx.sh` — fast MoonBit validation entrypoint
- `scripts/verify-preflight.sh` — local preflight entrypoint
