# RALPLAN Planning Integrity Note

- Status: `ratified-execution-authority`
- Source: repository audit on `2026-04-19`
- Scope: planning-process correction before any `ralph` or `team` execution handoff

## Why this note exists

The current repository contains substantial interview and planning work, but the user correctly identified a process-integrity gap:

- there are plan artifacts
- there are state files that say `ITERATE` or `APPROVE`
- but there is not yet an auditable preserved chain showing the current branch passed a real sequential `planner -> architect -> critic` convergence

This note is additive.
It does **not** delete, replace, or compress away existing work.
Its job is to freeze the current corpus, document the safety gate, and define what the next real `ralplan` pass must consume.

## Safety verdict

Current status is:

- `deep-interview` outputs exist and remain valid planning input
- research outputs under `docs/discussions/` exist and remain valid planning input
- a named canonical execution package now exists under `docs/plans/`
- `CEP-1` is ratified as execution authority
- execution still remains governed by blocker gates and freeze policy

Execution is no longer blocked on planning authority.
Execution is now governed by `CEP-1` plus the blocker gates and freeze policy defined inside it.

## Evidence

### 1. Ralplan requires a real consensus loop

The repo-local runtime skill [`.codex/skills/ralplan/SKILL.md`](/Users/yetian/Desktop/finall-start-100-commits/.codex/skills/ralplan/SKILL.md:1) requires:

- Planner draft first
- Architect review second
- Critic review third
- sequential completion before execution handoff

### 2. Prior approval state is not enough by itself

The older state file [`.omx/state/sessions/019da1c6-1f74-7051-817a-ecab5d901105/ralplan-state.json`](/Users/yetian/Desktop/finall-start-100-commits/.omx/state/sessions/019da1c6-1f74-7051-817a-ecab5d901105/ralplan-state.json:1) records `verdict: "APPROVE"` for the earlier `test-asset-first` branch.

But the session directory only contains:

- `ralplan-state.json`
- `skill-active-state.json`

There is no preserved architect-review artifact in that session directory, and there is no preserved critic-review artifact in that session directory that can be audited independently.

### 3. The current synthesis branch required ratification work

The current synthesis branch is represented mainly by:

- [ralplan-input-synthesis-from-assets.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-input-synthesis-from-assets.md:1)
- [ralplan-synthesis-execution-plan.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-synthesis-execution-plan.md:1)
- [ralplan-task-breakdown-synthesis-from-assets.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-task-breakdown-synthesis-from-assets.md:1)

These documents were useful and materially grounded, but originally lacked the preserved review trail needed for a completed consensus package.
That gap is now addressed by the preserved ratification reviews listed below.

### 4. `.omx/plans/` is not currently the rich source

The file [`.omx/plans/ralplan-input-test-asset-first.md`](/Users/yetian/Desktop/finall-start-100-commits/.omx/plans/ralplan-input-test-asset-first.md:1) is only a mirror stub pointing back to the tracked docs copy.

That is acceptable for workflow routing, but it means we must audit the tracked `docs/` artifacts directly rather than assuming `.omx/plans/` holds the current full package.

## Preservation contract

From this point forward, planning cleanup for this branch must follow these rules:

- Do not delete existing `docs/discussions/` research outputs as part of planning convergence.
- Do not replace raw or intermediate research with a shorter summary that loses traceability.
- Any future "tightening" must be additive:
  - index note
  - authority map
  - canonical bundle declaration
  - unresolved-question register
- If a plan branch becomes historical, mark it as historical explicitly rather than silently overwriting or discarding it.

## Current artifact map

### Preserved research corpus

These are first-class inputs and should remain intact:

- [docs/discussions/README.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/README.md:1)
- [2026-04-19-architecture-research-report.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-architecture-research-report.md:1)
- [2026-04-19-moonbit-native-candidates-matrix.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-moonbit-native-candidates-matrix.md:1)
- [2026-04-19-synthesis-method-from-test-assets.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-synthesis-method-from-test-assets.md:1)
- [2026-04-19-test-assets-and-mock-boundaries.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-test-assets-and-mock-boundaries.md:1)
- [2026-04-19-seed-rules-reference.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-seed-rules-reference.md:1)
- [2026-04-19-seed-asset-corpus-candidates.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-seed-asset-corpus-candidates.md:1)
- [2026-04-19-seed-mock-boundaries.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-seed-mock-boundaries.md:1)
- [2026-04-19-research-coverage-manifest.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-research-coverage-manifest.md:1)
- [2026-04-19-interview-handoff-note.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-interview-handoff-note.md:1)

### Stable spec-level constraint document

- [docs/specs/asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/specs/asset-centric-control-plane.md:1)

This remains the strongest durable product-constraint document for the branch.

### Earlier plan branch

- [docs/plans/ralplan-input-test-asset-first.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-input-test-asset-first.md:1)
- [docs/plans/prd-asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/prd-asset-centric-control-plane.md:1)
- [docs/plans/test-spec-asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/test-spec-asset-centric-control-plane.md:1)

These documents are preserved and still useful, especially for constraints and verification language.
They should not be deleted.
However, they are not sufficient by themselves as the sole authority for the current synthesis-driven execution branch.

### Current synthesis planning branch

- [docs/plans/ralplan-input-synthesis-from-assets.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-input-synthesis-from-assets.md:1)
- [docs/plans/ralplan-synthesis-execution-plan.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-synthesis-execution-plan.md:1)
- [docs/plans/ralplan-task-breakdown-synthesis-from-assets.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-task-breakdown-synthesis-from-assets.md:1)

This is the branch that went through the real consensus pass and now owns `CEP-1`.

## Authority model

The governing authority model is:

1. `docs/discussions/` is the preserved research substrate.
2. `docs/specs/asset-centric-control-plane.md` is the stable architectural constraint reference.
3. `docs/plans/ralplan-input-synthesis-from-assets.md` is the current planner intake for the synthesis branch.
4. `docs/plans/ralplan-synthesis-execution-plan.md` is the current lane-oriented execution draft.
5. `docs/plans/ralplan-task-breakdown-synthesis-from-assets.md` is the current task-graph draft.
6. This note is the authority map and safety gate for execution.

## Canonical execution package

The active package is now explicitly named:

- `CEP-1` = Canonical Execution Package 1

`CEP-1` consists of:

1. this note
2. [docs/specs/asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/specs/asset-centric-control-plane.md:1)
3. [docs/plans/ralplan-input-synthesis-from-assets.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-input-synthesis-from-assets.md:1)
4. [docs/plans/ralplan-synthesis-execution-plan.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-synthesis-execution-plan.md:1)
5. [docs/plans/ralplan-task-breakdown-synthesis-from-assets.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-task-breakdown-synthesis-from-assets.md:1)
6. preserved named research inputs from `docs/discussions/`

`CEP-1` is the ratified execution authority package for this branch.

## Historical preservation map

The following remain historical-but-preserved and are not execution authority for `CEP-1`:

- [docs/plans/ralplan-input-test-asset-first.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-input-test-asset-first.md:1)
- [docs/plans/prd-asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/prd-asset-centric-control-plane.md:1)
- [docs/plans/test-spec-asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/test-spec-asset-centric-control-plane.md:1)

These may inform verification language and comparison, but they may not silently override `CEP-1`.

## Preserved review artifacts

- [docs/plans/reviews/2026-04-19-architect-review-planning-integrity.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/reviews/2026-04-19-architect-review-planning-integrity.md:1)
- [docs/plans/reviews/2026-04-19-critic-review-planning-integrity.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/reviews/2026-04-19-critic-review-planning-integrity.md:1)
- [docs/plans/reviews/2026-04-19-architect-review-cep1-ratification.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/reviews/2026-04-19-architect-review-cep1-ratification.md:1)
- [docs/plans/reviews/2026-04-19-critic-review-cep1-ratification.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/reviews/2026-04-19-critic-review-cep1-ratification.md:1)

Current review state:

- architect review exists and returned `ITERATE`
- critic review attempt exists but returned procedural `REJECT`
- a substantive critic pass returned `ITERATE`
- a fresh architect ratification pass returned `APPROVE`
- a fresh critic ratification pass returned `APPROVE`

## Lane freeze policy

The package is execution-safe only if the following freezes are explicit and enforced:

- Freeze A: planning inputs freeze
  - scope:
    - rules manifest
    - corpus manifest
    - mock contract manifest
  - must hold before:
    - tasks `1.1` through `2.4`
  - reopen authority:
    - user
    - planner with architect/critic follow-up
  - required evidence to reopen:
    - a concrete contradiction, missing invariant, or missing fixture class tied to named research input

- Freeze B: contract freeze
  - scope:
    - package manifest type
    - package validation boundaries
    - provenance metadata model
  - must hold before:
    - tasks `3.1` through `4.2`
  - reopen authority:
    - user
    - planner with architect approval
  - required evidence to reopen:
    - failing fixture class, broken first-proof criterion, or kernel-boundary violation

- Freeze C: integration freeze
  - scope:
    - minimum real Hermes-facing path
    - thin local surface obligations
    - closed-loop readiness criteria
  - must hold before:
    - any `ralph` or `team` execution handoff
  - reopen authority:
    - user
    - planner with critic approval
  - required evidence to reopen:
    - inability to satisfy Gate 4, or a contradiction with the stable spec first-proof loop

## Unresolved-question register

| ID | Question | Status | Blocker level | Owner | Closure condition |
|---|---|---|---|---|---|
| U1 | Should the final execution package remain a small document bundle or later collapse into one index doc? | open | non-blocking | planner | one canonical package name exists now; future merge only happens after execution proves stable |
| U2 | What structured format should the first rules/corpus/mock manifests use? | open | blocking-before-Task-1.1 | planner + implementation lane A | manifest format chosen and written into Phase 0 outputs |
| U3 | How much hosted/local surface is required beyond inspection plus one export/share trigger? | open | blocking-before-Task-4.2 | planner + surface lane E | thin-surface acceptance is frozen and reflected in Task 4.2 verification |

## Execution gate

`CEP-1` is now the governing execution authority.

Do **not** bypass the blocker gates inside `CEP-1`:

- `U2` must close before Task `1.1`
- `U3` must close before Task `4.2`
- Freeze A/B/C reopen rules remain mandatory during execution

## Immediate next step

The current `ralplan` action is complete:

1. planner package preserved
2. architect and critic review artifacts preserved
3. `CEP-1` ratified as execution authority
4. future execution must respect blocker gates and freeze policy

## Changelog

- Initial planning-integrity note created to restore auditability and preserve all prior work before any execution handoff.
- Revised to define `CEP-1`, explicit lane freezes, and an execution-safe unresolved-question register.
- Ratified `CEP-1` after fresh architect and critic approval.
