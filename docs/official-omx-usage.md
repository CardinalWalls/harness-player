# Official OMX Usage

This document separates two things:

- upstream OMX behavior and recommendations
- repository-local conventions layered on top of those upstream surfaces

When this document says "official", it means upstream OMX or OpenAI Codex documentation.
When this document says "repository-local", it means a policy this repository chooses for itself.

This repository uses:

- OMX for orchestration, persistence, planning, teams, and runtime state
- MoonBit for implementation and ground-truth validation
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

For this repository, OMX success never replaces MoonBit success. Always return to:

- `moon check`
- `moon test`
- `moon fmt`
- `moon info`

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
- MoonBit validation commands work

## Launch Surfaces

Use the official entrypoint that matches the job.

### Interactive operator session

Official homepage recommendation for trusted local environments:

```bash
omx --madmax --high
```

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

Upstream docs position it as a non-interactive batch surface, not as the homepage's primary interactive operator entrypoint.

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
bash ./scripts/verify-moon-omx.sh
bash ./scripts/verify-preflight.sh
bash ./scripts/omx-takeover.sh --auto
```

## Repository-Local Conventions

The choices below are not claimed as upstream defaults. They are this repository's local operating conventions built on the upstream OMX surfaces above.

### Local durable repo takeover

```bash
omx --madmax --high
```

Then inside Codex choose the official workflow that matches the task.

### Local repo batch automation

```bash
bash ./scripts/omx-takeover.sh --auto
```

### Local completion-continuation rule

For this repository, local completion is not the default stopping point when the
next steps are standard delivery work and access already exists.

Repository-local expectation:

1. finish local implementation + MoonBit verification
2. continue into branch/PR delivery work when git/GitHub auth is already available
3. observe hosted CI/PR feedback when it can be done safely
4. move into the next tracked grounded stage when the next step is already legible from current docs/plans/discussions

Stop only for:

- missing credentials or repository access
- destructive operations
- materially ambiguous next-stage scope
- explicit user stop/cancel instructions

### Local parallel implementation

```bash
omx team N:role "task"
```

### Ground-truth completion

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
- treating OMX mode success as a substitute for MoonBit validation
- running multiple implementation sessions against the same worktree when `team` or worktrees should be used
