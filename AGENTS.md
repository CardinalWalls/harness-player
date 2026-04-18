<!-- AUTONOMY DIRECTIVE — DO NOT REMOVE -->
YOU ARE AN AUTONOMOUS CODING AGENT. EXECUTE SAFE, REVERSIBLE NEXT STEPS WITHOUT ASKING FOR PERMISSION.
ONLY PAUSE FOR DESTRUCTIVE ACTIONS, UNCLEAR REQUIREMENTS, OR EXTERNAL BLOCKERS.
<!-- END AUTONOMY DIRECTIVE -->

# Harness Player Contract

This file applies to `/Users/yetian/Desktop/harness-player`.

## Repo Purpose

- This repository is a rehearsal target for **OMX orchestration**, **MoonBit implementation/validation**, and **GitHub PR/CI workflows**.
- Treat it as a harness, not a production app.

## Layer Responsibilities

- OMX handles planning, orchestration, persistence, and long-running execution modes.
- MoonBit commands provide the real source of truth for build, test, format, and package status.
- GitHub Actions provide the platform-side CI and PR automation surface.

## First Read

- For tasks that touch MoonBit, OMX, GitHub Actions, PR review, or CI, read `./.codex/skills/moonbit-omx-github-workflow/SKILL.md` first.

## Default Workflow

- Small, concrete change: execute directly, then validate with MoonBit commands.
- Ambiguous work: `deep-interview -> ralplan`.
- Larger implementation: `ralplan -> team` or `ralplan -> ralph`.
- Do not let successful OMX orchestration substitute for successful MoonBit validation.

## MoonBit Rules

- Prefer real commands over inference:
  - `moon check`
  - `moon test`
  - `moon fmt`
  - `moon info`
- `moon test --build-only` never counts as completion.
- If proof is not explicitly requested, do not block on `moon prove`.

## GitHub Workflow Rules

- Keep CI definitions under `.github/workflows/`.
- `moonbit-ci.yml` is the repository's MoonBit validation workflow.
- `codex-pr-review.yml` is the repository's PR review harness for Codex on GitHub Actions.
- When changing these workflows, keep permissions minimal and prompts specific.

## Runtime State

- `.omx/` is runtime state and should stay out of source control.
- `.codex/skills/` is the runtime-facing skill surface.
- `skills/` is the source-of-truth area for repo-local custom skills.

## Reporting

- Before reporting completion, run `git status --short`.
- Summaries should include:
  - files changed
  - MoonBit commands actually run
  - OMX checks actually run
  - any GitHub-side limits that were only rehearsed, not executed live
