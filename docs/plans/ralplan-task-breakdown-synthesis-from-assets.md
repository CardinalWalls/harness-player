# RALPLAN Task Breakdown - Synthesis From Assets

- Status: `approved-draft`
- Source: [ralplan-synthesis-execution-plan.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-synthesis-execution-plan.md:1)
- Last-Mirrored-From: `2026-04-19`

## Why this exists

The execution plan is intentionally architectural and lane-oriented.

Before entering `ralph` or `team`, we need a concrete task graph that:

- turns the test-asset-driven method into real execution tasks
- prevents execution from reopening foundational research questions
- gives each lane bounded deliverables and verification

## Key correction

The earlier execution plan is **not enough by itself** for reliable execution.

Why:

- it says *what kinds of lanes exist*
- but not yet *which exact tasks land first*
- and not yet *how the seed asset corpus and mock boundaries drive code work*

So this document defines the missing layer:

- concrete tasks
- order
- dependencies
- expected outputs
- verification hooks

## How test assets are used in execution

The earlier research artifacts are not side notes.
They should directly drive execution in three ways:

### 1. Rule extraction drives contracts

The seed rules define:

- package invariants
- provenance invariants
- host/runtime boundary invariants

These become:

- type definitions
- validation rules
- mock API contracts

### 2. Asset corpus drives examples and tests

The seed asset corpus candidates define:

- which skill/package shapes must parse
- which references/assets/dependency patterns must be supported
- which edge cases should fail validation

These become:

- fixture corpus
- validation tests
- export/import examples

### 3. Mock boundaries drive interfaces

The seed mock boundaries define:

- what runtime events to simulate
- what checkpoint/blob operations to simulate
- what hosted/local management endpoints to simulate

These become:

- interface traits / virtual packages / service contracts
- mock implementations
- integration tests

## Execution graph

## Phase 0 - Freeze research outputs into execution inputs

### Task 0.1 - Create a seed rules manifest

Input:

- [seed-rules-reference.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-seed-rules-reference.md:1)

Output:

- one normalized `rules manifest` document or structured file

Why:

- later implementation should not re-parse prose repeatedly

### Task 0.2 - Create a seed asset corpus manifest

Input:

- [seed-asset-corpus-candidates.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-seed-asset-corpus-candidates.md:1)

Output:

- one manifest of first-wave corpus items:
  - canonical skill example
  - heavy skill example
  - reference-rich skill example
  - dependency-bearing skill example
  - static-asset skill example
  - provenance metadata sample

Why:

- execution needs concrete fixtures, not just candidate classes

### Task 0.3 - Create a seed mock contract manifest

Input:

- [seed-mock-boundaries.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-seed-mock-boundaries.md:1)

Output:

- one document defining the first interface contracts for:
  - share registry
  - runtime event stream
  - checkpoint/blob backend
  - hosted management API
  - topology activation

Why:

- execution should build against stable contracts, not vague mocks

## Phase 1 - Asset/package and provenance contracts

### Task 1.1 - Define package manifest type

Goal:

- define the first explicit external package object for:
  - `skill`
  - `profile`
  - `topology`

Likely code area:

- `src/asset/`
- possible new package such as `src/package/`

Verification:

- can represent at least the first-wave skill corpus examples

### Task 1.2 - Define package validation rules

Goal:

- validate canonical and heavy skill examples against the package model

Input from test assets:

- minimal skill
- reference-rich skill
- dependency-bearing skill
- static-asset skill

Verification:

- valid examples pass
- malformed variants fail cleanly

### Task 1.3 - Define provenance metadata model

Goal:

- define checkpoint metadata and lineage records without embedding raw runtime state in external package objects

Likely code area:

- `src/provenance/`
- new checkpoint metadata module(s)

Verification:

- one durable lineage representation exists
- can link internal capture records to exported package artifacts

## Phase 2 - Fixture corpus and mock implementations

### Task 2.1 - Materialize first-wave fixture corpus

Goal:

- create a local fixture set inside this repo for automated validation

Contents:

- minimal skill fixture
- heavy skill fixture
- reference-rich skill fixture
- dependency-bearing skill fixture
- static-asset skill fixture
- provenance metadata fixture

Verification:

- fixtures are loadable by tests without external network dependency

### Task 2.2 - Implement mock share registry

Goal:

- simulate package discovery/fetch/version listing for local testing

Verification:

- a package lookup can return a fixture package manifest

### Task 2.3 - Implement mock checkpoint/blob backend

Goal:

- simulate internal trace/blob attachment and durable metadata linkage

Verification:

- one capture record can resolve a blob reference and lineage reference

### Task 2.4 - Implement mock topology activation interface

Goal:

- simulate loading `skill + profile + topology` into a structured activation result

Verification:

- at least one fixture package yields:
  - agent list
  - channel/interaction entrypoints
  - topology graph summary

## Phase 3 - Real substrate code

### Task 3.1 - Implement package/export core in MoonBit

Goal:

- represent and validate shareable package objects in actual MoonBit code

Verification:

- `moon test` passes for package validation scenarios

### Task 3.2 - Implement provenance core in MoonBit

Goal:

- represent lineage, checkpoint metadata, and export linkage in actual MoonBit code

Verification:

- `moon test` passes for provenance scenarios

### Task 3.3 - Implement capture normalization core

Goal:

- convert runtime or mocked runtime events into structured internal records

Verification:

- one mock event becomes a normalized capture record with provenance linkage

### Task 3.4 - Define Git backend split

Goal:

- decide and implement the first backend boundary between:
  - MoonBit-native Git path
  - compatibility fallback path

Verification:

- one provenance/materialization operation has a clear backend path

## Phase 4 - Thin real integration

### Task 4.1 - Connect one real Hermes-facing path

Goal:

- ensure the system does not remain mock-only

Minimum acceptable real path:

- one skill/profile/topology-related event or loading path from Hermes-side reality

Verification:

- the event reaches our normalized capture or package layer

### Task 4.2 - Provide one thin local product surface

Goal:

- inspect package, topology, and lineage through a real user-facing surface

Verification:

- user can inspect at least:
  - package summary
  - topology summary
  - lineage summary

## Execution ordering

Recommended strict order:

1. `0.1`
2. `0.2`
3. `0.3`
4. `1.1`
5. `1.2`
6. `1.3`
7. `2.1`
8. `2.2`
9. `2.3`
10. `2.4`
11. `3.1`
12. `3.2`
13. `3.3`
14. `3.4`
15. `4.1`
16. `4.2`

## Suggested lane split for execution mode

### Lane A - Rules/contracts

Tasks:

- `0.1`
- `0.3`
- `1.1`
- `1.3`

### Lane B - Corpus/validation

Tasks:

- `0.2`
- `1.2`
- `2.1`

### Lane C - Mock substrate

Tasks:

- `2.2`
- `2.3`
- `2.4`

### Lane D - Real substrate implementation

Tasks:

- `3.1`
- `3.2`
- `3.3`
- `3.4`

### Lane E - Thin real integration and surface

Tasks:

- `4.1`
- `4.2`

## Verification gates

### Gate 1 - Planning input freeze

Pass when:

- rules manifest exists
- corpus manifest exists
- mock contract manifest exists

### Gate 2 - Contract readiness

Pass when:

- package manifest and provenance model are defined
- fixtures and mocks have concrete target contracts

### Gate 3 - MoonBit execution readiness

Pass when:

- package/provenance/capture modules have tests
- `moon check`
- `moon test`
- `moon fmt`
- `moon info`

### Gate 4 - Closed-loop readiness

Pass when:

- at least one mock path works end-to-end
- at least one real Hermes-facing path works end-to-end
- the result is inspectable through a thin local surface

## Main planning judgment

Yes, tasks need to be decomposed before execution.

And yes, the test assets are central to execution:

- they should drive manifests
- they should drive fixtures
- they should drive validation
- they should drive mock interfaces

Without this task breakdown, the execution plan would be too high-level to safely feed `ralph` or `team`.
