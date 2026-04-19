# Interview Stage Work Plan

## Stage identity

This is the current OMX `deep-interview` stage.

Its purpose is not implementation.
Its purpose is to make the project legible enough for later planning and execution.

## Stage goal

Answer, with grounded evidence:

- what software we are actually building
- what should be reused directly
- what should be MoonBit-native
- what the research/test-asset synthesis method looks like
- what first-wave source material, rules, asset candidates, and mock boundaries should be

## Stage work items

### 1. Clarify product subject vs synthesis method

Status: `completed`

Outputs:

- `2026-04-19-omx-interview-summary.md`
- `2026-04-19-synthesis-method-from-test-assets.md`

### 2. Compare reference systems

Status: `completed`

Outputs:

- `2026-04-19-software-synthesis-subject-comparison.md`
- `2026-04-19-architecture-research-report.md`

### 3. Define MoonBit-native candidates

Status: `completed`

Outputs:

- `2026-04-19-moonbit-native-candidates-matrix.md`
- `2026-04-19-phase-ordering-for-all-four-centers.md`

### 4. Define test asset and mock strategy

Status: `completed`

Outputs:

- `2026-04-19-test-assets-and-mock-boundaries.md`
- `2026-04-19-first-wave-concrete-asset-sources.md`
- `2026-04-19-extraction-rules-and-quality-grading.md`
- `2026-04-19-per-source-extraction-notes.md`
- `2026-04-19-first-extraction-batch-plan.md`

### 5. Run first CLI-backed source inspection

Status: `completed`

Inspected sources:

- `agentskills/agentskills`
- `anthropics/skills`
- `motiful/skill-forge`
- `entireio/cli`
- `NousResearch/hermes-agent`
- `go-gitea/gitea`

Outputs:

- `2026-04-19-seed-rules-reference.md`
- `2026-04-19-seed-asset-corpus-candidates.md`
- `2026-04-19-seed-mock-boundaries.md`

### 6. Prepare handoff shape for later planning

Status: `completed`

Output:

- a compact handoff note that says:
  - what is now stable
  - what remains unresolved
  - what later `ralplan` should consume directly

Produced:

- `2026-04-19-interview-handoff-note.md`

## What is stable now

- product subject vs synthesis method split
- shareable package convergence on `skill + profile + topology`
- default exclusion of raw runtime state from external package
- Hermes as first host runtime, not product identity
- strong reference roles for Entire, skill-forge, and Gitea
- MoonBit-native interest centered on provenance/capture/package/export substrate
- first-wave test asset sources and first mock boundaries

## What remains unresolved

- exact internal model of `topology`
- exact package manifest shape
- exact checkpoint metadata branch format
- exact hosted/local product minimum surface
- exact backend split between MoonBit-native Git and fallback Git integration

## Exit condition for this stage

This stage should be considered ready to hand off when:

- the current documents are considered sufficient research input
- the next OMX step can use them without reopening foundational identity questions

## Recommended next OMX step

Move from `deep-interview` to a planning handoff that consumes:

- architecture report
- MoonBit-native candidates matrix
- seed rules reference
- seed asset corpus candidates
- seed mock boundaries
