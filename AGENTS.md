<!-- AUTONOMY DIRECTIVE — DO NOT REMOVE -->
YOU ARE AN AUTONOMOUS CODING AGENT. EXECUTE SAFE, REVERSIBLE NEXT STEPS WITHOUT ASKING FOR PERMISSION.
ONLY PAUSE FOR DESTRUCTIVE ACTIONS, UNCLEAR REQUIREMENTS, OR EXTERNAL BLOCKERS.
<!-- END AUTONOMY DIRECTIVE -->

# OMX + MoonBit Contract

This file applies to `/Users/yetian/Desktop/finall-start-100-commits`.

## Repo Role

- This repository uses **OMX as the orchestration/runtime layer**.
- This repository uses **MoonBit as the implementation toolchain**.
- This repository also carries **GitHub PR/CI workflow surfaces** for local preflight and hosted validation.
- Treat them as complementary:
  - OMX decides workflow, planning, orchestration, persistence, and verification loops.
  - MoonBit commands are the source of truth for build/test/format/info status.
  - GitHub Actions provide the platform-side CI and PR automation surface.

## First Read

- For MoonBit work, read `./.codex/skills/moonbit-omx-workflow/SKILL.md` first.
- For tasks that touch MoonBit, OMX, GitHub Actions, PR review, or CI, also read `./skills/moonbit-omx-github-workflow/SKILL.md`.
- For general OMX workflow behavior, use the installed OMX skills already present under `.codex/skills/`.

## Default Workflow

- Small, concrete task: execute directly.
- Ambiguous task: `deep-interview -> ralplan`.
- Large implementation: `ralplan -> team` or `ralplan -> ralph`.
- Do not use OMX planning/orchestration to replace MoonBit validation; always come back to the actual `moon` toolchain.

## MoonBit Rules

- Prefer real commands over inference:
  - `moon check`
  - `moon test`
  - `moon fmt`
  - `moon info`
- Use `moon test --build-only` only for diagnosis; it never counts as completion.
- If `moon check` or `moon test` fail, the task is not complete.
- If proof is not explicitly requested, do not block on `moon prove`.
- If proof is requested, only claim success when `moon prove` actually passes.

## GitHub Workflow Rules

- Keep CI definitions under `.github/workflows/`.
- `moonbit-ci.yml` is the repository's MoonBit validation workflow.
- `codex-pr-review.yml` is the repository's PR review harness for Codex on GitHub Actions.
- When changing these workflows, keep permissions minimal and prompts specific.

## OMX Rules

- Keep `.omx/` as runtime state, not as product source.
- Prefer OMX skills and modes that fit the task:
  - `deep-interview` for clarification
  - `ralplan` for consensus planning
  - `team` for durable parallel execution
  - `ralph` for persistent completion + verification
- When reporting completion from an OMX workflow, include the MoonBit commands that actually passed.

## Project Layout

- `skills/` is the source-of-truth area for repo-local custom skills.
- `.codex/skills/` is the runtime-facing skill surface used by Codex/OMX.
- `scripts/` contains deterministic helper scripts.
- `1 raw discussion about the scope/` is input/reference material; do not rewrite it unless the user explicitly asks.

## Git Discipline

- Never revert user-authored files unless explicitly asked.
- Keep changes inside this repository.
- Before reporting completion, check `git status --short`.

## Reporting

- Name the files changed.
- Name the MoonBit commands actually run.
- Name any OMX checks actually run.
- Name any GitHub-side limits that were only validated locally, not executed live.
- Call out any remaining blockers or intentional gaps.
