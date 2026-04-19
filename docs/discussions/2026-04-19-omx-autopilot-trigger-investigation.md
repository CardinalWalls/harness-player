# OMX Autopilot Trigger Investigation

- Date: `2026-04-19`
- Status: `open-investigation`
- Scope: why `$autopilot` looked like it stayed in `planning`, how official OMX automation is actually wired, and which trigger mechanisms fired vs did not fire in this repository

## Why this note exists

During real repository work, the user repeatedly experienced a mismatch between:

- the official OMX promise that `autopilot` is full autonomous execution
- the observed runtime behavior where the visible state often looked stuck at `planning`

This note records the full investigation path, current evidence, and the remaining gap to close.

## Official claim we are checking

Official docs and homepage describe:

- `autopilot` as **Full autonomous execution from idea to delivered code**
- the clear-task "No-Brainer" workflow as:
  - `$autopilot -> $ultrawork -> $ralph`

Official references:

- <https://oh-my-codex.dev/docs.html>
- <https://oh-my-codex.dev/>

## Repository context during investigation

Repository:

- `/Users/yetian/Desktop/finall-start-100-commits`

Relevant local repo policy files already updated during this work:

- `AGENTS.md`
- `README.md`
- `docs/official-omx-usage.md`

Those files now encode the repo-local expectation that after local verification is green, the system should keep going through routine delivery work when auth/access already exist.

## What work actually happened while the state looked confusing

Despite later state views showing `planning`, actual execution occurred in this repository:

- CEP-1 / first-proof work was carried through local verification
- topology default discussion and topology manifest were added
- topology fixture corpus support was added in `src/fixture/`
- tests increased from `37/37` to `40/40`
- the branch was committed and pushed
- PR `#3` was updated live on GitHub

Representative commit:

- `3d3bb6d` — `Extend delivery defaults and add topology fixture corpus`

So the problem was never "nothing ran." The problem was understanding which part of official autopilot automation had actually triggered.

## Investigation questions

We investigated three distinct possibilities:

1. Did `$autopilot` fail to trigger at all?
2. Did it trigger but get redirected by the official `ralplan` gate?
3. Did it trigger and start, but later get re-seeded to a new `planning` state instead of resuming?

## Evidence collected

### A. Native hook wiring exists and is active

From `.codex/hooks.json`:

- `UserPromptSubmit` calls the OMX native hook script:
  - `codex-native-hook.js`

This means prompt submission is definitely routed through official OMX hook handling.

### B. Keyword detection does seed `autopilot`

Installed source:

- `/opt/homebrew/lib/node_modules/oh-my-codex/dist/hooks/keyword-detector.js`

Relevant config:

- `autopilot: { mode: 'autopilot', initialPhase: 'planning' }`

This is the first important finding:

> On keyword activation, the official hook seeds autopilot mode state with initial phase `planning`.

So seeing `planning` in the HUD/state is consistent with the official implementation of the first trigger layer.

### C. The native hook message only promises activation + initialization

Installed source:

- `/opt/homebrew/lib/node_modules/oh-my-codex/dist/scripts/codex-native-hook.js`

The generated message shape says:

- detected workflow keyword
- skill activated
- initial state initialized

It does **not** say that a full pipeline runner has been launched at that moment.

This is the second important finding:

> The prompt-side hook is clearly responsible for workflow activation and state seeding, not obviously for directly starting the full autopilot pipeline executor.

### D. Official `ralplan` gate for vague execution requests is real

Installed tests:

- `/opt/homebrew/lib/node_modules/oh-my-codex/dist/hooks/__tests__/keyword-detector.test.js`

Relevant tested behavior:

- `isUnderspecifiedForExecution('autopilot build the app') === true`
- `applyRalplanGate(['autopilot'], 'autopilot build the app')`
  redirects to `ralplan`

This matters because broad prompts such as:

- `完成所有工作`
- `自己定义，并完成所有工作`
- `做所有工作啊`

are exactly the kind of prompts that can feel "clear enough" to a human operator but still be judged underspecified by the official execution gate.

### E. But in our successful session, the evidence does **not** show a ralplan redirect

We inspected the actual successful session scope:

- session id: `019da4a3-73d5-78b3-9ffe-5c5e621d4d29`

The session-scoped skill state showed:

- `skill: "autopilot"`
- `keyword: "$autopilot"`
- `phase: "execution"`
- `source: "keyword-detector"`
- `initialized_mode: "autopilot"`

That means this specific successful lane did more than just seed planning; it progressed far enough that the persisted skill-active record later reflected `execution`.

This is the third important finding:

> For the successful lane we inspected, there was no direct evidence that the request had been rewritten into `ralplan`. The workflow really did activate as `autopilot`.

### F. Official continuation logic exists

Installed source:

- `/opt/homebrew/lib/node_modules/oh-my-codex/dist/hooks/keyword-detector.js`

Installed tests:

- same file's tests around:
  - `preserves activated_at for same-skill continuation`
  - `preserves seeded mode progress for same-skill continuation`

The tests explicitly show that:

- when `skill-active-state.json` is still active for `autopilot`
- and the session-scoped `autopilot-state.json` is active at `execution`
- then a new prompt like `autopilot keep going`
  should preserve:
  - `current_phase: execution`
  - `started_at`
  - existing context snapshot path

This is the fourth important finding:

> Official OMX **does** have same-skill continuation behavior for autopilot. The capability is real.

### G. That continuation depends on the prior autopilot state still being active

The same implementation computes:

- `sameSkill = previous?.active === true && previous.skill === match.skill`

and only preserves prior mode state when the previous skill/mode is still active.

In our session, when we later inspected:

- `.omx/state/sessions/019da4a3-73d5-78b3-9ffe-5c5e621d4d29/skill-active-state.json`

we saw:

- `active: false`
- `skill: "autopilot"`
- `phase: "execution"`

and the session-scoped `autopilot-state.json` file itself had already been cleared.

This is the fifth important finding:

> The official continuation path was no longer eligible. The old autopilot had already been completed/cleared, so a new `$autopilot` keyword created a new seed state back at `planning`.

### H. The pipeline implementation exists, but current installed production code still does not show a wired runtime call chain

Installed source:

- `/opt/homebrew/lib/node_modules/oh-my-codex/dist/pipeline/orchestrator.js`

Confirmed present:

- `runPipeline(config)`
- `createAutopilotPipelineConfig(...)`

Confirmed by source comments:

- default autopilot pipeline is:
  - `RALPLAN -> team-exec -> ralph-verify`

Non-test `dist/` search results currently show:

- `runPipeline`, `createAutopilotPipelineConfig`, `canResumePipeline`, and `readPipelineState`
  exist only under:
  - `dist/pipeline/orchestrator.js`
  - `dist/pipeline/index.js`
  - type declarations
- repository-wide non-test search did **not** find any production import or call
  site outside the pipeline module itself
- `codex-native-hook.js` imports `detectKeywords`, `detectPrimaryKeyword`, and
  `recordSkillActivation`, but does not import pipeline orchestrator functions
- `keyword-detector.js` seeds mode/skill state and transition metadata, but does
  not import pipeline orchestrator functions

This upgrades the finding from "not yet found" to a stronger statement:

> In the currently installed `oh-my-codex v0.13.2` production `dist/` tree on this machine, we do not have evidence of any wired production call site that launches the autopilot pipeline orchestrator from keyword-triggered `$autopilot` activation.

What **is** present in production code:

- keyword detection
- workflow-state seeding
- transition bookkeeping
- stop/visibility plumbing for `autopilot`

What is **not** yet evidenced in production code:

- a concrete runtime bridge from prompt-side `$autopilot` activation to
  `runPipeline(createAutopilotPipelineConfig(...))`

Current practical implication:

- the installed pipeline subsystem appears real but unintegrated
- the observed behavior is consistent with a system that seeds `autopilot`
  state and skill guidance without necessarily launching the canonical
  `RALPLAN -> team-exec -> ralph-verify` runner

### I. Fresh reproduction: new prompt-side autopilot seed appears without CLI-visible active mode

During a later prompt in the same desktop thread, the native hook again reported:

- workflow keyword `$autopilot` detected
- `autopilot-state.json` initialized for session `019da501-0c19-7dd0-bf2b-3013311eed74`

Fresh file-backed evidence showed:

- `.omx/state/sessions/019da501-0c19-7dd0-bf2b-3013311eed74/autopilot-state.json`
  contained:
  - `active: true`
  - `current_phase: "planning"`
- matching session-scoped `skill-active-state.json` also showed:
  - `skill: "autopilot"`
  - `active: true`
  - `phase: "planning"`

At the same time, CLI parity surfaces showed:

- root `.omx/state/autopilot-state.json` remained:
  - `active: false`
  - `current_phase: "cancelled"`
- `omx state list-active --json` returned:
  - `{"active_modes":[]}`
- `omx status` did **not** show active `autopilot`, but still surfaced
  `skill-active: ACTIVE`

This is the seventh important finding:

> Prompt-side `$autopilot` activation can create a fresh session-scoped planning seed even when CLI-visible mode state remains inactive, which is consistent with hook/state seeding being real while the production pipeline runner still lacks a demonstrated runtime bridge.

### J. Repo-local bridge proved the installed pipeline API is callable

To separate "API exists" from "prompt path is wired", we added a repo-local
bridge script:

- [scripts/run-autopilot-pipeline-bridge.mjs](/Users/yetian/Desktop/finall-start-100-commits/scripts/run-autopilot-pipeline-bridge.mjs:1)

That script imports the installed package's pipeline API directly from:

- `/opt/homebrew/lib/node_modules/oh-my-codex/dist/pipeline/index.js`

and runs:

- `createAutopilotPipelineConfig(...)`
- `runPipeline(...)`

against this repository.

Observed result on `2026-04-19`:

- pipeline status: `completed`
- stage sequence persisted into root `.omx/state/autopilot-state.json`
- `ralplan` stage skipped because planning artifacts already existed
- `team-exec` stage completed and emitted a concrete `omx team ...` launch
  instruction
- `ralph-verify` stage completed and emitted a concrete `omx ralph ...` launch
  instruction

Bridge artifact:

- `.omx/plans/autopilot-pipeline-bridge-2026-04-19T095634Z.md`

This is the eighth important finding:

> The installed `v0.13.2` pipeline orchestrator is callable and persists real pipeline state when invoked directly; the missing piece is the production bridge from prompt-side `$autopilot` activation into that runner.

### K. Prompt-side seeding still races back in after bridge-driven completion

Immediately after the repo-local bridge completed and wrote root autopilot state
as:

- `active: false`
- `current_phase: "complete"`
- `pipeline_name: "autopilot"`

a later prompt again triggered native keyword detection for `Autopilot` and
recreated session-scoped files under:

- `.omx/state/sessions/019da501-0c19-7dd0-bf2b-3013311eed74/autopilot-state.json`
- `.omx/state/sessions/019da501-0c19-7dd0-bf2b-3013311eed74/skill-active-state.json`

with:

- `active: true`
- `current_phase: "planning"`
- `source: "keyword-detector"`

At the same moment:

- root `.omx/state/autopilot-state.json` still reflected the completed bridge
  pipeline
- `omx status` showed `autopilot: inactive (phase: complete)` plus
  `skill-active: inactive` before the fresh prompt, then later hook prompts
  still reacted to the new session-scoped planning seed
- `omx state list-active --json` remained empty

This is the ninth important finding:

> Even after a direct pipeline run completes cleanly, prompt-side keyword detection can immediately reseed session-scoped `autopilot` planning state again, creating a second layer of drift between canonical/root pipeline state and hook-facing session state.

### L. Repo-local reconcile now converts prompt-side planning seeds into real pipeline runs

To reduce that drift without modifying the global installation, we added a
repo-local reconcile helper:

- [scripts/reconcile-autopilot-entry.mjs](/Users/yetian/Desktop/finall-start-100-commits/scripts/reconcile-autopilot-entry.mjs:1)

Its behavior:

1. find the latest active session-scoped `autopilot-state.json`
2. recover task text from:
   - explicit `--task`, else
   - `task_description` in the seed, else
   - the latest bridge report, else
   - the tracked takeover baseline continuation step
3. invoke the installed pipeline API through:
   - [scripts/run-autopilot-pipeline-bridge.mjs](/Users/yetian/Desktop/finall-start-100-commits/scripts/run-autopilot-pipeline-bridge.mjs:1)
4. clear the consumed session-scoped `autopilot` / `skill-active` seed files

Observed result on `2026-04-19`:

- prompt-side native hook created a fresh session-scoped seed with:
  - `active: true`
  - `current_phase: "planning"`
  - no `task_description`
- reconcile recovered the task from the tracked repository context
- bridge reran successfully and produced:
  - `.omx/plans/autopilot-pipeline-bridge-2026-04-19T100506Z.md`
- after reconcile:
  - `omx status` showed `autopilot: inactive (phase: complete)`
  - `skill-active: inactive`
  - `omx state list-active --json` returned `{"active_modes":[]}`
  - no session-scoped `autopilot-state.json` or `skill-active-state.json` remained

This is the tenth important finding:

> Prompt-side `$autopilot` seeding can be lossily emitted in the current install, but a repo-local reconcile layer can recover the intended task, drive the real installed pipeline API, and restore canonical state consistency afterward.

## Timeline summary

### What likely happened

1. `$autopilot` was detected successfully by native hook routing
2. official keyword detector seeded autopilot state
3. the lane progressed far enough to be reflected later as `phase: execution`
4. repository work actually continued and completed significant local and remote delivery actions
5. that autopilot state was later completed/cleared
6. subsequent fresh `$autopilot` prompts seeded **new** autopilot state back to `planning`
7. the user saw the later `planning` state and reasonably concluded the system was "not really running"
8. a fresh reproduction later confirmed that prompt-side seeding can happen again
   in session-scoped state even while CLI-visible active-mode surfaces remain empty
9. a repo-local bridge then proved that the installed pipeline API itself works when called directly, reinforcing that the missing link is runtime wiring rather than absent pipeline code

### What did **not** happen

We found no evidence that the successful execution lane was primarily failing because of the official `ralplan` gate.

## New finding: stale deep-interview overlap can block autopilot even when CLI status looks clear

On `2026-04-19`, a later prompt-side denial reported:

- `Cannot activate autopilot: deep-interview is already active`
- `Unsupported workflow overlap: deep-interview + autopilot`

But at the same time, CLI parity surfaces showed:

- `omx status` -> no active `deep-interview`
- `omx state list-active --json` -> `{"active_modes":[]}`

File-backed inspection then showed the real discrepancy:

- session-scoped `.omx/state/sessions/.../deep-interview-state.json` still had `active: true`
- matching `.omx/state/sessions/.../skill-active-state.json` still had `skill: "deep-interview"` and `active: true`

This produced a sixth important finding:

> Hook-facing session files can stay logically active after CLI-visible mode status has already gone inactive, and those stale session files are enough to deny later `$autopilot` activation.

Operational fix used:

- `omx state clear --input '{"mode":"deep-interview","all_sessions":true}' --json`
- `omx state clear --input '{"mode":"skill-active","all_sessions":true}' --json`

After that cleanup:

- `omx status` remained inactive
- `omx state list-active --json` remained empty
- no lingering session-scoped `deep-interview-state.json` or `skill-active-state.json` files remained

Practical implication:

- there are at least two separate failure classes in play:
  - MCP transport death / `Transport closed`
  - stale session-scoped workflow state causing false overlap denial
- fixing one does not automatically fix the other

## Current best explanation

The official promise is not fake.

The current implementation appears to be layered:

1. **keyword/runtime activation layer**
   - detect workflow keyword
   - seed state
   - inject skill guidance
2. **workflow continuation layer**
   - preserve in-flight autopilot progress if the same active autopilot lane is continued
3. **pipeline/orchestrator layer**
   - implemented as a standalone subsystem
   - not yet evidenced as wired into the current production `$autopilot` trigger path on this machine
   - full staged runner exists
   - but its actual production trigger point is not yet identified in this investigation

So the current discrepancy is:

> we have strong evidence that the first two layers fired, but we do not yet have a verified source-level proof of where the third layer is actually invoked in production.

## Practical diagnosis for this repository

For this repository's observed behavior, the dominant issue was:

- not "no trigger at all"
- not "definitely ralplan-gated every time"
- but **loss of active autopilot continuity**, followed by later re-seeding to a fresh `planning` state

That made the workflow look much less automatic than the official docs imply.

## Remaining open questions

1. Which production path actually calls `runPipeline(...)`?
2. Is autopilot pipeline launch currently tied only to a different CLI/runtime entrypoint instead of keyword activation?
3. Should repo-local policy enforce:
   - resume active autopilot by default
   - or preserve recent autopilot lane state longer before cleanup?

## Repository-local follow-up directions

The current likely improvement directions are:

1. prevent repeated `$autopilot` prompts from re-seeding a new planning lane when an active autopilot lane already exists
2. preserve active autopilot continuity until the user-visible flow truly reaches a terminal state
3. continue tracing the real production invocation path of `runPipeline(...)`

## Files and sources inspected

Official docs:

- <https://oh-my-codex.dev/docs.html>
- <https://oh-my-codex.dev/>

Installed local OMX runtime files:

- `.codex/hooks.json`
- `/opt/homebrew/lib/node_modules/oh-my-codex/dist/hooks/keyword-detector.js`
- `/opt/homebrew/lib/node_modules/oh-my-codex/dist/hooks/__tests__/keyword-detector.test.js`
- `/opt/homebrew/lib/node_modules/oh-my-codex/dist/scripts/codex-native-hook.js`
- `/opt/homebrew/lib/node_modules/oh-my-codex/dist/scripts/__tests__/codex-native-hook.test.js`
- `/opt/homebrew/lib/node_modules/oh-my-codex/dist/pipeline/orchestrator.js`
- `/opt/homebrew/lib/node_modules/oh-my-codex/templates/AGENTS.md`
- `/opt/homebrew/lib/node_modules/oh-my-codex/README.md`

Repository-local evidence:

- `.omx/state/sessions/019da4a3-73d5-78b3-9ffe-5c5e621d4d29/skill-active-state.json`
- `.omx/logs/turns-2026-04-19.jsonl`
- `.codex/sessions/2026/04/19/...`

## Current verdict

- **Confirmed:** keyword trigger and state seeding succeeded
- **Confirmed:** successful autopilot execution happened in practice
- **Confirmed:** official continuation logic exists
- **Confirmed:** later repeated `$autopilot` prompts can re-seed planning after earlier completion/cleanup
- **Unconfirmed:** exact production call chain that launches full autopilot pipeline from runtime activation
