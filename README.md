# harness-player

`harness-player` is a rehearsal repository for three layers working together:

- **OMX** for orchestration and long-running local workflows
- **MoonBit** for the real implementation and validation signal
- **GitHub Actions** for PR-time CI and comment-based review automation

This is intentionally a harness, not a product application.

## What is already wired

- Project-local OMX setup under `.codex/` and `.omx/`
- A repo-local workflow skill:
  - `.codex/skills/moonbit-omx-github-workflow`
- A minimal MoonBit package that supports real validation
- GitHub workflows for:
  - MoonBit CI
  - Codex PR review comments
- PR and issue templates for repeatable rehearsal runs

## Fastest local preflight

Run this from the repo root:

```bash
bash ./scripts/verify-preflight.sh
```

The script validates:

- `omx doctor`
- `CODEX_HOME=.codex codex login status`
- `moon version`
- `moon check`
- `moon test`
- `moon fmt`
- `moon info`
- `moon coverage analyze -- -f html -o coverage.html`
- workflow file presence

Expected coverage report output:

```text
coverage.html/index.html
```

## Fastest OMX rehearsal path

Open an OMX session in the repo:

```bash
omx --madmax --high
```

Inside the session, use the shortest realistic path:

```text
deep-interview "clarify the rehearsal task"
ralplan "approve the MoonBit implementation and verification path"
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

## Live GitHub prerequisites

For the GitHub side to work in the hosted repository:

- the repo must have Actions enabled
- the repo must define `OPENAI_API_KEY` in GitHub secrets
- the workflows must be present on the default branch

These are **remote validation prerequisites**, not local preflight requirements.

## Optional enhancements

This harness intentionally does **not** require extra tools beyond OMX and MoonBit.

Optional extras you may add later:

- `actionlint` for local GitHub Actions linting
- `gh` for local GitHub PR / issue operations
- `moon prove` once Why3 and proof prerequisites are available

## Files to know

- `AGENTS.md` — repo contract
- `skills/moonbit-omx-github-workflow/SKILL.md` — local combined workflow skill
- `scripts/verify-preflight.sh` — local preflight entrypoint
- `docs/rehearsals/end-to-end.md` — end-to-end rehearsal walkthrough
