# Official OMX Usage

This document separates two things:

- upstream OMX behavior and recommendations
- repository-local conventions layered on top of those upstream surfaces

When this document says "official", it means upstream OMX or OpenAI Codex documentation.
When this document says "repository-local", it means a policy this repository chooses for itself.

This repository uses:

- OMX for orchestration, persistence, planning, teams, and runtime state
- MoonBit for the structured product substrate and the repo-owned CLI/product paths that are intentionally implemented in MoonBit
- GitHub Actions for hosted CI and PR automation

## Source Alignment

This document is aligned to:

- [oh-my-codex homepage](https://oh-my-codex.dev/)
- [oh-my-codex docs](https://oh-my-codex.dev/docs.html)
- [OpenAI Codex CLI reference](https://developers.openai.com/codex/cli/reference#codex-exec)
- [OpenAI Codex config reference](https://developers.openai.com/codex/config-reference#configtoml)

## Mental Model

Use OMX as the operator layer on top of Codex CLI:

- `omx` launches the interactive operator session
- OMX skills such as `$deep-interview`, `$ralplan`, `$autopilot`, `$team`, and `$ralph` drive workflow inside that session
- `omx exec` is the non-interactive batch surface
- `omx team` is the durable tmux + worktree coordination surface
- `omx status`, `omx hud`, `omx trace`, and `omx state` are observability surfaces

For this repository, MoonBit is strongest where typed structure, portable logic,
package boundaries, provenance semantics, capture normalization, extraction, and
repo-owned CLI/product behavior materially benefit from MoonBit.

Do not force MoonBit onto every host/runtime boundary:

- pure OMX/runtime/hook/tmux/transport issues should be validated in the OMX lane first
- thin GitHub wrapper issues should be debugged in the workflow/wrapper lane first
- return to `moon check/test/fmt/info` when MoonBit-owned product surfaces are actually in scope or when full preflight is requested

## Bootstrap

Official project bootstrap:

```bash
npm install -g @openai/codex oh-my-codex
omx setup --scope project
omx doctor
```

Project readiness is healthy when:

- `.codex/` is present and configured for the project
- `.omx/state/` exists
- `omx doctor` passes
- repo-local Codex auth works
- MoonBit validation commands work when the MoonBit/product lane is in scope

## Launch Surfaces

Use the official entrypoint that matches the job.

### Interactive operator session

Treat `omx --madmax --high` only as a human-facing interactive launch surface. Do not treat it as the full-auto recommendation.

Inside the interactive session, use explicit OMX workflow skills:

```text
$deep-interview "clarify the task"
$ralplan "approve the implementation path"
$ralph "carry the plan to completion"
```

Use this interactive session when you want:

- durable takeover
- a persistent lane
- an operator-visible workflow
- the official skill-driven flow

### Interactive recovery

```bash
omx resume
```

Use `resume` only to continue an existing interactive session.

Do not treat `resume` as an automation command. It may wait for input because it restores a human-facing session.

### Non-interactive batch automation

```bash
omx exec "task"
```

Use `omx exec` for:

- CI-style runs
- scripted orchestration
- one-shot repo checks
- non-interactive wrappers

In this repository, `omx exec` is useful for repo automation helpers such as:

```bash
bash ./scripts/omx-takeover.sh --auto
```

When repeated OMX MCP sibling processes or transport residue make the normal
takeover lane unreliable, use the repo-local clean-start wrapper from an
external terminal:

```bash
bash ./scripts/omx-takeover.sh --restart --auto
```

Upstream docs position it as a non-interactive batch surface, not as the homepage's primary interactive operator entrypoint.

For this repository, the default automation wrapper is still:

```bash
bash ./scripts/omx-takeover.sh --auto
```

The repository-local clean-start variant archives restartable `.omx` runtime
state, repairs duplicate MCP siblings, and then relaunches the same batch lane:

```bash
bash ./scripts/omx-takeover.sh --restart --auto
```

If the issue is transport death rather than product validation, prefer capturing
the restart lane with transport debug enabled:

```bash
bash ./scripts/capture-omx-transport-debug.sh
```

If you need to prove that the installed OMX pipeline orchestrator is callable
independently of prompt-side keyword routing, use the repo-local bridge:

```bash
node ./scripts/run-autopilot-pipeline-bridge.mjs --task "Advance the current CLI-visible materialized export report toward the first true persisted export/materialization write path."
```

This is a repository-local proof harness. It validates direct pipeline API
invocation and emitted stage artifacts/state; it does not by itself prove that
prompt-side `$autopilot` activation is already wired to the runner.

For this repository, prompt-side `$autopilot` follow-through is now reinforced
by a repo-local hook layer:

- `.codex/hooks.json` runs `scripts/autopilot-userprompt-followthrough.mjs`
  after the native OMX `UserPromptSubmit` hook
- inside tmux-backed OMX sessions, that script delegates to
  `scripts/run-autopilot-official-followthrough.mjs`
- outside tmux, it falls back to `scripts/reconcile-autopilot-entry.mjs` so the
  canonical `ralplan -> team -> ralph` bridge is still materialized and the
  stale prompt seed is cleared

The repo-local tmux injection policy also allows `autopilot` in
`.omx/tmux-hook.json`, so managed sessions can continue from an active
autopilot state instead of being rejected as `mode_not_allowed`.

### Read-only exploration

```bash
omx explore --prompt "question"
```

Use `explore` for read-only exploration. Do not use it as the implementation lane.

## Core Modes and When To Use Them

### `$deep-interview`

Use when the task is ambiguous and needs clarification before planning.

### `$ralplan`

Use when you need a reviewed plan before implementation. This is the planning front door for larger work.

### `$autopilot`

Use when the task is clear and you want autonomous execution from idea to working code.

### `$ulw`

Use when you want aggressive parallel subagent execution inside the current lane.

### `$ralph`

Use when you want the persistence surface that keeps working until the goal is verified complete.

Upstream docs position Ralph as the persistence surface that keeps working until the goal is verified complete.

### `$team`

Use when you need durable parallel execution with worker coordination.

Official current behavior:

- workers use isolated git worktrees automatically by default
- no extra `--worktree` flag is needed
- the leader workspace stays clean
- use `omx team status`, `omx team await`, `omx team resume`, and `omx team shutdown` to operate the team

### `$ultraqa`

Use after implementation when you want repeated test -> verify -> fix QA cycling.

## Official Recommended Workflows

These are the upstream-recommended patterns.

### Quality-first canonical flow

```text
$deep-interview -> $ralplan -> $team/$ralph
```

Use this when the request is ambiguous or quality-sensitive.

### Full-Auto from PRD

```text
$ralplan -> $team -> $ralph
```

Use this for larger features that need planning first.

### No-Brainer

```text
$autopilot -> $ulw -> $ralph
```

Use this when the task is clear and execution-heavy.

### Fix / Debugging

```text
$plan -> $ralph -> $ultraqa
```

Use this for debugging and fix loops.

## Team Mode

Official OMX team usage in this repository:

```bash
omx team 3:executor "parallel task"
omx team status <team-name> --json
omx team await <team-name> --json
omx team resume <team-name>
omx team shutdown <team-name>
```

Best practice for this repo:

- prefer a clean leader worktree before starting `team`
- let workers use the default isolated worktrees
- use `team` for durable parallel implementation, not multiple sessions writing the same worktree

## Observability and Control

Use these surfaces to inspect and control OMX runtime state:

```bash
omx doctor
omx status
omx hud --json
omx trace trace_timeline --input '{"filter":"all","last":20}' --json
omx state
omx cancel
omx reasoning
```

Use repo-local verification helpers for this repository:

```bash
bash ./scripts/check-omx-state-mcp.sh --repair
bash ./scripts/verify-omx-runtime.sh
bash ./scripts/verify-moon-omx.sh
bash ./scripts/verify-preflight.sh
bash ./scripts/omx-takeover.sh --auto
```

Interpret them as separate lanes:

- `verify-omx-runtime.sh`: OMX runtime, MCP transport, repo-local Codex auth/runtime, and `omx exec` smoke
- `verify-moon-omx.sh`: MoonBit-owned product code, package, and CLI validation
- `verify-preflight.sh`: combined delivery-readiness proof

Do not treat MoonBit revalidation as the primary diagnostic for OMX transport failures, hook-routing bugs, tmux issues, or repo-local Codex runtime problems.

## Repository-Local Conventions

The choices below are not claimed as upstream defaults. They are this repository's local operating conventions built on the upstream OMX surfaces above.

### Local repo batch automation

```bash
bash ./scripts/omx-takeover.sh --auto
```

### Local full-auto workflow guidance

Use one of these explicit workflows instead of treating `omx --madmax --high` as automation:

- larger or quality-sensitive work: `$ralplan -> $team -> $ralph`
- clear execution-heavy work: `$autopilot -> $ulw -> $ralph`
- ambiguous work: `$deep-interview -> $ralplan -> $team/$ralph`

### Local completion-continuation rule

For this repository, local completion is not the default stopping point when the
next steps are standard delivery work and access already exists.

Repository-local expectation:

1. finish local implementation + validation for the layer actually touched
2. continue into branch/PR delivery work when git/GitHub auth is already available
3. observe hosted CI/PR feedback when it can be done safely
4. move into the next tracked grounded stage when the next step is already legible from current docs/plans/discussions

That means:

- for MoonBit-owned product changes, run the MoonBit lane
- for pure OMX/runtime/hook/tmux/transport changes, the OMX lane may be sufficient
- for release/preflight requests, run the combined lane

Stop only for:

- missing credentials or repository access
- destructive operations
- materially ambiguous next-stage scope
- explicit user stop/cancel instructions

### Local parallel implementation

```bash
omx team N:role "task"
```

### MoonBit completion when MoonBit is in scope

```bash
moon check
moon test
moon fmt
moon info
```

## Anti-Patterns

Do not use these as the repository-local default operating model:

- treating `omx resume` as automation
- treating `omx exec` as the durable persistent takeover lane
- treating OMX mode success as a substitute for MoonBit validation when MoonBit-owned product work was changed
- running multiple implementation sessions against the same worktree when `team` or worktrees should be used
- rerunning MoonBit by reflex for pure OMX/runtime/hook/tmux/state issues that never touched MoonBit-owned surfaces
