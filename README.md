# finall-start-100-commits

`finall-start-100-commits` is the primary repository for this project.

It combines three layers in one place:

- **OMX** for planning, orchestration, and long-running execution modes
- **MoonBit** for the real implementation and validation signal
- **GitHub Actions** for PR-time CI and review automation rehearsal

## What is already wired

- Project planning artifacts under `docs/`
- Project-local OMX setup under `.codex/` and `.omx/`
- Repo-local workflow skills under `skills/`
- A minimal MoonBit package that supports real validation
- GitHub workflows for:
  - MoonBit CI
  - Codex PR review comments
- PR and issue templates for repeatable rehearsal runs

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

## GitHub rehearsal path

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
