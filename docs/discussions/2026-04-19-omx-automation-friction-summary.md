# OMX Automation Friction Summary - 2026-04-19

## Why this note exists

This note puts the current OMX automation confusion into one place.

It combines:

- what the official OMX docs currently claim
- what the official OpenAI Codex CLI docs currently claim about `codex exec`
- what we actually observed inside this repository
- which parts should be trusted for day-to-day execution
- which parts are still friction points or misleading surfaces

The goal is simple:

- stop re-litigating the same confusion every session
- keep one durable reference for "what is supposed to be automatic" versus "what actually worked"

## Official sources checked

- oh-my-codex homepage:
  - <https://oh-my-codex.dev/>
- oh-my-codex documentation:
  - <https://oh-my-codex.dev/docs.html>
- OpenAI Codex CLI reference for `codex exec`:
  - <https://developers.openai.com/codex/cli/reference#codex-exec>

## Version audit

As checked on `2026-04-19`:

- local installed OMX version on this machine:
  - `oh-my-codex v0.13.2`
- local installed package metadata:
  - `/opt/homebrew/lib/node_modules/oh-my-codex/package.json`
  - `version: "0.13.2"`
- official website/docs pages currently visible:
  - mostly still describe `v0.13.1`
- official GitHub releases page currently shows:
  - `v0.13.2` as the latest release
  - release timestamp: `2026-04-18`

Current practical conclusion:

- this is **not** an obviously wrong old version
- it appears to be the current latest package/release line
- the official website/docs content is lagging behind the package/release state
- so the current confusion is better explained by:
  - partial integration
  - documentation lag
  - workflow-vs-runtime ambiguity
  - not by "you installed the wrong historical version"

## Short conclusion

- `omx --madmax --high` is not the highest automation surface.
- `omx --madmax --high` is only a human-facing interactive Codex launch surface.
- The official highest-end OMX workflow for larger work is:
  - `$ralplan -> $team -> $ralph`
- The official clear-task OMX workflow is:
  - `$autopilot -> $ultrawork -> $ralph`
- The official OpenAI non-interactive batch surface is:
  - `codex exec`
- In this repository, the non-interactive OMX wrapper surface is:
  - `omx exec`
  - or repo-local wrapper `bash ./scripts/omx-takeover.sh --auto`

## Official model, separated cleanly

### 1. OpenAI Codex CLI

OpenAI's current `codex exec` docs say:

- use `codex exec` for scripted or CI-style runs that should finish without human interaction
- `--json` emits newline-delimited JSON events
- `resume` can continue a previous non-interactive task

Local CLI help on this machine confirms:

- `codex exec [OPTIONS] [PROMPT]`
- `codex exec [OPTIONS] <COMMAND> [ARGS]`
- `codex exec resume [OPTIONS] [SESSION_ID] [PROMPT]`

This is the cleanest answer to "what is the official non-interactive Codex surface":

- `codex exec`

### 2. OMX orchestration layer

Current oh-my-codex docs present multiple surfaces:

- canonical quality-first workflow:
  - `deep-interview -> ralplan -> team/ralph`
- big-feature full-auto workflow:
  - `$ralplan -> $team -> $ralph`
- clear-task no-brainer workflow:
  - `$autopilot -> $ultrawork -> $ralph`
- orchestration wrapper:
  - `omx exec`
- durable parallel execution:
  - `omx team`

This means the official OMX story is layered, not singular:

- `codex exec` is the OpenAI non-interactive base command
- `omx exec` wraps execution through OMX orchestration
- `omx team` is the tmux/worktree parallel execution surface
- `$ralplan`, `$team`, `$ralph`, `$autopilot`, and `$ultrawork` are workflow surfaces

## What actually caused confusion in this repository

### 1. `omx --madmax --high` was easy to mistake for "full auto"

This was the biggest documentation trap.

Why it misled us:

- it sounds like the highest-end launch mode
- `madmax` sounds like "maximum automation"
- it often got described as the default or official launch path
- in practice it still opens a human-facing interactive Codex session

What it really is:

- a permissive interactive launch surface
- not the highest-end automation workflow
- not the clean answer to "what should I use if I want it to just run"

Repository-local docs were updated to stop recommending it as the automation answer.

### 2. `autopilot` keyword activation is not the same thing as reliable autonomous execution

This is a real, reproduced friction point.

We observed that merely mentioning `autopilot` can create fresh mode state files under `.omx/state/sessions/...` with:

- `active: true`
- `current_phase: "planning"`
- `source: "keyword-detector"`

For example, after a fresh mention of `autopilot`, the repository created:

- `.omx/state/sessions/019da4e7-286c-7df0-be1f-aa1bc9dc7929/autopilot-state.json`
- `.omx/state/sessions/019da4e7-286c-7df0-be1f-aa1bc9dc7929/skill-active-state.json`

The current persisted values show:

- mode `autopilot`
- phase `planning`
- source `keyword-detector`
- transition message `ralplan -> autopilot`

This confirms an important distinction:

- keyword-triggered state seeding is real
- but a visible `autopilot` state does not by itself prove that a full pipeline is running smoothly

See also:

- `docs/discussions/2026-04-19-omx-autopilot-trigger-investigation.md`

### 3. Official OMX messaging is internally layered enough to feel contradictory

The official docs simultaneously say things like:

- canonical workflow is `deep-interview -> ralplan -> team/ralph`
- full-auto from PRD is `$ralplan -> $team -> $ralph`
- no-brainer is `$autopilot -> $ultrawork -> $ralph`
- `autopilot` is the flagship full autonomous mode

All of those can be true in implementation intent, but in practice they create a user-facing question:

- which one is actually the mainline automation answer right now

The most stable practical answer today is:

- for serious larger work, trust `$ralplan -> $team -> $ralph`
- for non-interactive batch execution, trust `codex exec`
- treat `autopilot` keyword activation as a higher-friction surface until proven reliable in the current repo/runtime

### 4. `omx exec` versus `codex exec` was never cleanly explained early enough

This created avoidable confusion.

What the surfaces appear to mean now:

- `codex exec`
  - official OpenAI non-interactive base command
- `omx exec`
  - OMX wrapper around non-interactive execution
  - local `omx --help` describes it as:
    - `Run codex exec non-interactively with OMX AGENTS/overlay injection`

Practical interpretation:

- if the question is "what is OpenAI's official batch command", the answer is `codex exec`
- if the question is "what is OMX's batch wrapper", the answer is `omx exec`

### 5. MCP reliability has been another real friction layer

This repository already spent real effort repairing and stabilizing MCP wiring.

Even during this summary pass, OMX state MCP calls returned:

- `Transport closed`

That does not invalidate the repo, but it does reinforce the current practical rule:

- when OMX state MCP feels flaky, trust local state files and concrete command behavior more than optimistic mode labels

## Current working truth table

## Current real entry map

This is the most practical "what can actually start what" map for the currently installed OMX.

### Confirmed real CLI entrypoints

- `omx exec`
  - real CLI command
  - wraps `codex exec`
  - non-interactive batch execution surface
- `omx team`
  - real CLI command
  - launches tmux worker runtime
- `omx ralph`
  - real CLI command
  - launches Codex with Ralph persistence mode active
- `omx explore`
  - real CLI command
- `omx autoresearch`
  - real CLI command

### Confirmed prompt/hook activation paths

- `autopilot`
  - prompt keyword / skill activation path exists
  - seeds mode state
- `ralplan`
  - prompt keyword / skill activation path exists
  - seeds mode state
- `ralph`
  - prompt keyword / skill activation path exists
  - seeds mode state
- `team`
  - prompt keyword / skill activation path exists
  - seeds mode state

### Not currently confirmed as a dedicated CLI runtime entrypoint

- `omx autopilot`
  - not found in the installed CLI command dispatch

### Not currently confirmed as a live production runtime path

- prompt `autopilot` -> `runPipeline(createAutopilotPipelineConfig(...))`
  - not proven in the installed production code

## Practical operator map for this repository

If you want something you can actually rely on today:

- planning first:
  - `$ralplan`
- durable parallel execution:
  - `omx team ...`
  - or `$team ...` with explicit runtime follow-through
- persistent completion / verification:
  - `omx ralph ...`
  - or `$ralph ...`
- non-interactive batch run:
  - `codex exec ...`
  - or `omx exec ...`

If you want the least misleading "full-auto" mental model today:

- treat `$ralplan -> $team -> $ralph` as the real operator workflow
- treat `autopilot` as a high-level promise layer whose fully wired runtime path is not yet proven in this install

## OMX mode vs workflow vs pipeline

These three layers are related, but they are not the same thing.

### 1. Mode state

Mode state is the persisted runtime status under `.omx/state/...`.

Examples:

- `autopilot-state.json`
- `ralplan-state.json`
- `ralph-state.json`
- `team-state.json`

What mode state tells us:

- which named workflow mode is currently marked active
- which phase string is currently persisted
- whether a transition like `ralplan -> autopilot` was recorded

What mode state does **not** prove:

- that the full promised workflow really executed end-to-end
- that tmux workers actually launched
- that planning/execution/verification completed in the claimed way

In current OMX code, mode state is managed by shared base lifecycle code and hook seeding logic.

### 2. Workflow skill

Workflow skills are the human-facing orchestration contracts:

- `autopilot`
- `ralplan`
- `ralph`
- `team`

These skills describe the intended operator workflow:

- what should happen first
- what phases should exist
- what handoffs should occur
- what counts as completion

This is the layer most users read first, which is why it is easy to over-trust it.

The skill text is a workflow specification and guidance layer.
It is not by itself proof that the runtime currently implements every promised step automatically.

### 3. Pipeline orchestrator

The pipeline layer is a separate implementation concept under:

- `/opt/homebrew/lib/node_modules/oh-my-codex/dist/pipeline/`

Its orchestrator defines a sequential pipeline runner:

- `runPipeline(config)`
- `createAutopilotPipelineConfig(task, options)`

The intended default autopilot pipeline is:

- `ralplan`
- `team-exec`
- `ralph-verify`

This is a stronger implementation artifact than skill text because it is actual code.
But it is still separate from hook-triggered mode seeding and separate from the visible HUD state.

## What the current local implementation actually shows

### A. Mode transitions are real

Current local OMX code explicitly tracks workflow transitions and overlap rules.

Examples from the installed implementation:

- `ralplan -> team`
- `ralplan -> ralph`
- `ralplan -> autopilot`

That means OMX really does treat these as related modes in one broader workflow family.

### B. Autopilot state seeding is real

Current hook code seeds:

- `autopilot` with initial phase `planning`
- `ralplan` with initial phase `planning`
- `ralph` with initial phase `starting`
- `team` with initial phase `starting`

So when you see:

- `autopilot:planning`

that can be a genuine hook-seeded mode state while still not proving that a deeper pipeline ran.

### C. The pipeline implementation exists

The installed orchestrator code is real and does define:

- `runPipeline(config)`
- pipeline state persistence through mode state
- `createAutopilotPipelineConfig(...)`

So the idea is not imaginary.

### D. But the current installed production call chain is still missing

This is the most important current finding.

In the installed `dist/` tree, repository-wide search found:

- implementation of `runPipeline`
- implementation of `createAutopilotPipelineConfig`
- stage adapters under `dist/pipeline/stages/`
- exports
- tests

But it did **not** find a production runtime call site that actually invokes:

- `runPipeline(...)`

or:

- `createAutopilotPipelineConfig(...)`

outside tests and exports.

Current practical conclusion:

- the pipeline subsystem exists
- but in the currently installed version, we do not yet have proof that your `autopilot` prompt path is actually entering that pipeline runner

That means your suspicion is justified:

- we likely have **not** had a verified end-to-end `runPipeline` execution in this environment

### E. There is no dedicated `omx autopilot` CLI entry in the current installed command surface

Current local CLI command routing exposes:

- `omx exec`
- `omx team`
- `omx ralph`
- `omx explore`
- `omx autoresearch`

But there is no dedicated:

- `omx autopilot`

in the current installed command dispatch table.

This matters because it means prompt-side `autopilot` behavior is currently much more dependent on hook-triggered skill activation than on an explicit CLI runtime entrypoint.

### F. `omx exec` is an execution wrapper, not the hidden autopilot pipeline

Current local `omx` help says:

- `omx exec      Run codex exec non-interactively with OMX AGENTS/overlay injection`

And the installed implementation shows that `omx exec` calls `execWithOverlay(...)`, which then runs:

- `codex exec ...`

through OMX launch preparation and overlay injection.

Current practical conclusion:

- `omx exec` is a batch execution wrapper around `codex exec`
- it is not evidence of a hidden `runPipeline(...)` autopilot executor

### G. The native hook message itself only promises activation and initialization

Current installed native hook messaging says things like:

- workflow keyword detected
- `mode transiting: ...`
- `skill: <mode> activated and initial state initialized at ...`

This is important because the hook message does **not** say:

- pipeline started
- tmux workers launched
- ralplan/team/ralph execution completed

Current practical conclusion:

- the native hook is a workflow activation and state-seeding layer
- it is not by itself proof of full runtime pipeline execution

## Why `$ralplan -> $team -> $ralph` still matters if `runPipeline` is not wired

Because that sequence is still meaningful as a workflow handoff even without a single pipeline runner.

Think of it like this:

- `ralplan`
  - planning mode / consensus planning step
- `team`
  - tmux worker execution step
- `ralph`
  - persistence + verification completion step

So:

- `$ralplan -> $team -> $ralph`

can be real as a manual or semi-automatic operator workflow
even if:

- `runPipeline(createAutopilotPipelineConfig(...))`

is not actually being called under the hood yet.

That is the key distinction that caused so much confusion:

- documented workflow chain: real as an intended operating model
- fully wired one-shot pipeline executor: not yet proven active in this install

## What `runPipeline` appears to be today

Based on the installed stage adapters, `runPipeline` currently looks closer to:

- a structural orchestration layer
- a reusable implementation substrate
- a partially integrated future-facing pipeline surface

than to:

- the already-confirmed live entrypoint for normal `$autopilot` prompts

One especially revealing detail:

- the `team-exec` and `ralph-verify` stage adapters mainly build execution descriptors and instruction strings
- they do not themselves directly launch `omx team` or `omx ralph`

So even inside the pipeline layer, part of the implementation still looks adapter-like rather than fully end-to-end live execution.

### If the goal is "I want the official highest-end OMX workflow"

Use:

- `$ralplan -> $team -> $ralph`

Why:

- this is the clearest high-end workflow explicitly documented by oh-my-codex for big work
- it aligns better with the current canonical quality-first posture
- it relies on the more explicit planning/team/verification chain

### If the goal is "I want the official non-interactive Codex command"

Use:

- `codex exec`

Why:

- OpenAI explicitly positions it for scripted and CI-style runs without human interaction

### If the goal is "I want OMX to wrap that batch execution"

Use:

- `omx exec`

Why:

- local `omx --help` explicitly says it runs `codex exec` non-interactively with OMX overlay behavior

### If the goal is "I want tmux/worktree parallel workers"

Use:

- `omx team`

Why:

- this is the explicit tmux/team execution surface in OMX docs and local help

### If the goal is "I want to just say autopilot and trust the magic"

Current practical answer:

- do not trust that surface blindly in this repository yet

Why:

- we reproduced keyword-triggered planning-state seeding
- that is not the same thing as a visibly reliable end-to-end automation pipeline

## Minimal `codex exec` usage notes

These examples are grounded in the current local CLI help and OpenAI's current docs.

### Run a non-interactive prompt

```bash
codex exec "Summarize the repository status and propose the next safe step."
```

### Read the prompt from stdin

```bash
printf '%s\n' "Review the current branch and list the main risks." | codex exec -
```

### Emit machine-readable JSON events

```bash
codex exec --json "Run the requested checks and report the result."
```

### Use the lower-friction sandboxed automatic mode

```bash
codex exec --full-auto "Implement the scoped change and run the relevant tests."
```

### Resume the most recent non-interactive session

```bash
codex exec resume --last "Continue from the previous stopping point."
```

### Use the OMX wrapper instead

```bash
omx exec "moon test"
```

## Recommended day-to-day rule for this repository

Until OMX autopilot behavior is made more legible and reliable in this repo:

- do not use `omx --madmax --high` as the answer to "highest automation"
- do not treat a lit-up `autopilot` state as proof that the workflow is healthy
- use `$ralplan -> $team -> $ralph` when asking for the highest-end OMX workflow
- use `codex exec` when you want the official non-interactive Codex surface
- use `omx exec` or `bash ./scripts/omx-takeover.sh --auto` when you want repo-local OMX batch wrapping

## 2026-04-19 operator clarification

### Why MoonBit validation kept repeating

MoonBit validation kept repeating because the repo contract and local wrapper
scripts treat `moon check`, `moon test`, `moon fmt`, and `moon info` as the
ground-truth completion gate after each OMX lane transition or fresh completion
claim.

Evidence:

- `AGENTS.md` says MoonBit commands are the source of truth and OMX success does
  not replace `moon` success.
- `skills/moonbit-omx-workflow/SKILL.md` defines the same default validation
  sequence.
- `scripts/verify-preflight.sh` and `scripts/verify-moon-omx.sh` explicitly run
  the MoonBit chain as part of takeover/preflight proof.

Practical interpretation:

- rerunning MoonBit after real code or workflow-boundary changes is meaningful
- rerunning MoonBit during a pure OMX transport-debug loop is mostly
  reassurance, not root-cause evidence for `omx_state`
- once one fresh green baseline exists and no MoonBit-owned files changed,
  additional reruns are low-signal and should not be mistaken for transport
  debugging

### `omx_state` was repaired earlier; what was actually fixed

The repository already has evidence that `omx_state` parity worked earlier on
the same day.

Evidence from `.omx/notepad.md`:

- `2026-04-19T06:18:11Z` — verified `mcp__omx_state/state_list_active` and
  `state_write`; `omx exec` smoke returned `OMX-EXEC-OK`
- `2026-04-19T07:01:00Z` — official OMX lane restored; `ralph` confirmed active
  via `omx status/state`
- `2026-04-19T07:15:52Z` — MCP parity surfaces responded cleanly through both
  MCP tools and OMX CLI
- `2026-04-19T07:33:21Z` — repository-side false-green bug fixed in
  `scripts/check-omx-state-mcp.sh` and `scripts/repair-omx-state-mcp.sh` so
  `ps` permission failures no longer masquerade as healthy transport
- `2026-04-19T09:14:30Z` — another repo-side bug fixed in
  `scripts/verify-preflight.sh`; empty-array expansion under Bash 3.2 was
  crashing restart/auto runs before transport conclusions could be trusted

What that means:

- we did previously restore healthy `omx_state` parity
- the current failure is not explained by those already-fixed repository bugs
- the current issue is a new transport-death episode on top of otherwise healthy
  CLI/runtime surfaces

### What "OMX state transport has not recovered" means

This phrase should be read narrowly.

It does **not** mean:

- OMX as a whole is down
- all state is gone
- duplicate sibling MCP processes are definitely still present

Current evidence:

- `omx status` still responds and reports active modes
- `bash ./scripts/check-omx-state-mcp.sh --warn-only` currently reports one MCP
  server per type and no duplicate siblings
- MCP tool calls to `omx_state` and `omx_memory` now fail with
  `Transport closed`

Current practical meaning:

- the Codex Desktop thread's live MCP stdio connection died
- the underlying OMX runtime is still at least partially healthy through CLI
  parity surfaces
- this is a transport-boundary problem between the current thread and the MCP
  servers, not proof that the state-server fleet is absent or duplicated right
  now

Most likely interpretation:

- a prior thread interruption, in-thread restart attempt, or stdio/session
  boundary reset killed the MCP transport for this desktop thread
- because OMX MCP servers are plain Node stdio processes, transport death can
  strand the thread even while CLI parity surfaces remain readable

Operator rule from this incident:

- if MCP tools say `Transport closed` but `omx status` and
  `check-omx-state-mcp.sh` are healthy, debug transport death instead of
  rerunning MoonBit
- on the next repro, capture CLI parity first and then rerun with
  `OMX_MCP_TRANSPORT_DEBUG=1` to log why the stdio transport closed

### Separate but related: stale session-scoped workflow state

Another repository-local friction source was confirmed on `2026-04-19`:

- prompt-side hook logic denied `$autopilot` because it believed
  `deep-interview` was still active
- but `omx status` and `omx state list-active --json` both showed no active
  `deep-interview`

Root cause:

- stale session-scoped files under `.omx/state/sessions/...` still marked
  `deep-interview` and `skill-active` as active

Repair used:

```bash
omx state clear --input '{"mode":"deep-interview","all_sessions":true}' --json
omx state clear --input '{"mode":"skill-active","all_sessions":true}' --json
```

Practical rule:

- do not assume CLI-visible inactive status means hook-facing session files are
  already clean
- if workflow-overlap denials keep appearing, inspect and clear stale
  session-scoped mode files separately from MCP transport debugging

## Remaining open problems

- prove the exact production call chain from keyword-triggered `autopilot` activation to the real OMX pipeline runner
- decide whether repo docs should demote `autopilot` from a recommended surface until that runtime path is easier to verify
- improve MCP state reliability so we do not need to fall back to local file inspection as often
- document one or two repository-approved `codex exec` and `omx exec` examples that everyone can reuse
