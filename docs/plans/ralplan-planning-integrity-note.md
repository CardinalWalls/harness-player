# RALPLAN Planning Integrity Note

- Status: `draft-for-review`
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
- synthesis-oriented plan drafts exist under `docs/plans/`
- execution is still gated

Execution is gated because the current branch does **not** yet have a preserved, auditable consensus package for this synthesis-driven plan set.

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

### 3. The current synthesis branch is still draft-shaped

The current synthesis branch is represented mainly by:

- [ralplan-input-synthesis-from-assets.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-input-synthesis-from-assets.md:1)
- [ralplan-synthesis-execution-plan.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-synthesis-execution-plan.md:1)
- [ralplan-task-breakdown-synthesis-from-assets.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-task-breakdown-synthesis-from-assets.md:1)

These documents are useful and materially grounded, but they do not yet include the preserved review trail that would justify calling them a completed consensus package.

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

This is the branch that should go through the next real consensus pass.

## Temporary authority model

Until the new consensus pass completes, the safest authority model is:

1. `docs/discussions/` is the preserved research substrate.
2. `docs/specs/asset-centric-control-plane.md` is the stable architectural constraint reference.
3. `docs/plans/ralplan-input-synthesis-from-assets.md` is the current planner intake for the synthesis branch.
4. `docs/plans/ralplan-synthesis-execution-plan.md` is the current lane-oriented execution draft.
5. `docs/plans/ralplan-task-breakdown-synthesis-from-assets.md` is the current task-graph draft.
6. This note is the safety gate and authority map until review completes.

## Execution gate

Do **not** enter `ralph`, `team`, or large-scale implementation until all of the following are true:

- a preserved planner artifact names the canonical synthesis branch inputs explicitly
- a preserved architect review challenges boundaries, dependencies, and execution shape
- a preserved critic review evaluates plan quality against those artifacts
- the resulting package states clearly:
  - what is canonical
  - what remains historical but preserved
  - what unresolved questions remain intentionally open
  - which lane inputs are frozen enough for parallel work

## Immediate next step

The next safe `ralplan` action is:

1. treat this note plus the three synthesis planning docs as the planner draft package
2. run a real sequential `architect` review on that package
3. revise if needed
4. run a real sequential `critic` review on the revised package
5. only then decide whether the branch is ready to become a canonical execution package

## Changelog

- Initial planning-integrity note created to restore auditability and preserve all prior work before any execution handoff.
