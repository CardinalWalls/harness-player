<!-- AUTONOMY DIRECTIVE — DO NOT REMOVE -->
YOU ARE AN AUTONOMOUS CODING AGENT. EXECUTE SAFE, REVERSIBLE NEXT STEPS WITHOUT ASKING FOR PERMISSION.
ONLY PAUSE FOR DESTRUCTIVE ACTIONS, UNCLEAR REQUIREMENTS, OR EXTERNAL BLOCKERS.
<!-- END AUTONOMY DIRECTIVE -->

# OMX + MoonBit Contract

This file applies to `/Users/yetian/Desktop/finall-start-100-commits`.

## Repo Role

- This repository uses **OMX** as the orchestration/runtime layer.
- This repository uses **MoonBit** as the implementation and validation layer.
- This repository also carries **GitHub PR/CI** workflow files under `.github/workflows/`.
- Keep the layers separate:
  - OMX handles setup, orchestration, deep interview, planning, team execution, persistence, and recovery.
  - MoonBit commands are the source of truth for build/test/format/info status.
  - GitHub Actions is the hosted automation surface, not the local source of truth.

## First Read

- For OMX usage, launch patterns, and mode selection, read `./docs/official-omx-usage.md`.
- For MoonBit work, read `./skills/moonbit-omx-workflow/SKILL.md` first.
- For tasks that touch MoonBit, OMX, GitHub Actions, PR review, or CI, also read `./skills/moonbit-omx-github-workflow/SKILL.md`.
- Treat repo-tracked `skills/` as the source of truth. Do not rely on `.codex/skills/` mirrors for repository correctness.

## Official OMX Runtime

- Follow the official OMX bootstrap path from the upstream docs:
  - `npm install -g oh-my-codex`
  - `omx setup --scope project`
  - `omx doctor`
- Use `omx` to launch Codex CLI with the OMX runtime attached.
- Use `omx resume` to continue a previous OMX session.
- Use `omx explore --prompt "..."` only for the official read-only exploration surface.
- Use `omx agents-init .` only when you explicitly need OMX to scaffold lightweight `AGENTS.md` files for a repo or subtree.
- Keep `.omx/` as runtime state:
  - `.omx/state/` for mode state
  - `.omx/logs/` for runtime logs
  - `.omx/plans/` for planning artifacts
  - `.omx/notepad.md` for resilient notepad memory
  - `.omx/project-memory.json` for persistent project memory

## Official OMX Usage Policy

- Follow the official homepage launch pattern for trusted local operator sessions:
  - `omx --madmax --high`
- Inside the interactive Codex session, use explicit OMX workflow skills such as:
  - `$deep-interview`
  - `$ralplan`
  - `$autopilot`
  - `$ulw`
  - `$team`
  - `$ralph`
  - `$ultraqa`
- Treat `omx resume` as interactive recovery only. It resumes an existing session and may wait for input.
- Treat `omx exec` as non-interactive batch automation for scripts, CI, and one-shot orchestration. The upstream docs position it as a batch surface, not as the homepage's primary durable operator entrypoint.
- Treat `omx explore` as the read-only exploration lane and keep it out of implementation flows.
- For durable repo takeover, prefer an interactive OMX session plus the official workflow skills, not `resume` and not a one-shot `exec`.

## Official Full-Auto Usage

- Follow the official canonical workflow for quality-first work:
  - `omx deep-interview "task or feature idea"` when the request is ambiguous.
  - Then use `$ralplan` to produce the consensus plan.
  - Then use `$team` or `omx team N:role "task"` for parallel execution.
  - Finish with `ralph` or `omx ralph` so the session persists until verified complete.
- For big feature work, use the official "Full-Auto from PRD" pattern:
  - `$ralplan -> $team -> $ralph`
- For clear, execution-heavy work, use the official "No-Brainer" pattern:
  - `$autopilot -> $ulw -> $ralph`
- For fixes and debugging, use the official bug-fix pattern:
  - `$plan -> $ralph -> $ultraqa`
- Team mode runs in isolated git worktrees by default. Prefer `omx team` when parallel workers would otherwise touch overlapping files.
- When using `team`, prefer starting from a clean leader worktree so worker worktrees inherit the intended repository state.
- Inside Codex CLI, prefer explicit skill syntax such as `$ralplan`, `$team`, `$autopilot`, `$ulw`, `$ralph`, and `$ultraqa` instead of vague paraphrases.
- `ralph` is the persistence surface with strong verification requirements and includes Ultrawork automatically. Do not claim completion before the requested validation is actually green.

## Repo OMX Local Convention

- This section is repository-local policy layered on top of the upstream OMX docs.
- Local default durable operator lane for this repository:
  - launch `omx --madmax --high` in a trusted local terminal
  - then use the official workflow that matches the task:
  - ambiguous or large work: `$deep-interview -> $ralplan -> $team/$ralph`
  - clear execution-heavy work: `$autopilot -> $ulw -> $ralph`
  - bug-fix work: `$plan -> $ralph -> $ultraqa`
- Local default non-interactive repo automation lane:
  - `bash ./scripts/omx-takeover.sh --auto`
- Local default parallel implementation lane:
  - `omx team N:role "task"` or `$team ...`
- After OMX orchestration, completion still depends on the MoonBit validation commands below.

## Continuation Policy

- Repository-local default: do not stop at local implementation if the remaining steps are low-risk, standard delivery work, and the required auth/tooling is already available.
- After fresh local verification is green, continue automatically through the next available stages in order:
  1. local delivery readiness confirmation
  2. branch commit/push or PR update when git/gh auth is already available
  3. live GitHub PR/CI observation where the repository access already exists
  4. the next tracked project stage that can be grounded from current docs/plans/discussions without reopening core scope ambiguity
- Only stop before those stages if:
  - the next action is destructive
  - credentials/access are missing
  - the next stage is materially ambiguous
  - the user explicitly says not to continue
- When the next stage is derived automatically, write the chosen boundary into tracked docs or plans instead of keeping it only in ephemeral runtime state.

## MoonBit Ground Truth

- Do not let OMX workflow success replace MoonBit tool success.
- Prefer real commands over inference:
  - `moon check`
  - `moon test`
  - `moon fmt`
  - `moon info`
- Use `moon test --build-only` only for diagnosis; it never counts as completion.
- If `moon check` or `moon test` fail, the task is not complete.
- If proof is not explicitly requested, do not block on `moon prove`.
- If proof is requested, only claim success when `moon prove` actually passes.
- When a feature needs a runnable entrypoint, expose it under `cmd/` so it can be executed with `moon run`.
- Use deterministic helpers in `scripts/` when they make the default CLI path easier to repeat.

## GitHub Workflow Rules

- Keep CI definitions under `.github/workflows/`.
- `moonbit-ci.yml` is the repository's MoonBit validation workflow.
- `codex-pr-review.yml` is the repository's Codex PR review harness.
- When editing workflow files, keep permissions minimal and prompts/task scopes specific.
- If local behavior and GitHub Actions behavior disagree, debug the workflow wrapper separately and treat local MoonBit results as the implementation truth.

## Project Layout

- `skills/` is the source-of-truth area for repo-local custom skills.
- `.codex/` is local runtime/setup state and should not be treated as tracked product source.
- `.omx/` is OMX runtime state and should not be treated as product source.
- `scripts/` contains deterministic helper scripts.
- `1 raw discussion about the scope/` is reference material; do not rewrite it unless the user explicitly asks.

## Git Discipline

- Never revert user-authored files unless explicitly asked.
- Keep changes inside this repository.
- Check `git status --short` before reporting completion.

## Reporting

- Name the files changed.
- Name the MoonBit commands actually run.
- Name any OMX checks actually run.
- Name any GitHub-side limits that were only validated locally, not executed live.
- Call out any remaining blockers or intentional gaps.
