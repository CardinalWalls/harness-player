# RALPLAN - Synthesis Execution Plan

- Status: `ratified-execution-authority`
- Source: [ralplan-input-synthesis-from-assets.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-input-synthesis-from-assets.md:1)
- Last-Mirrored-From: `2026-04-19`

## Authority chain

This document is part of the ratified execution authority only when read together with:

- [docs/plans/ralplan-planning-integrity-note.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-planning-integrity-note.md:1)
- [docs/specs/asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/specs/asset-centric-control-plane.md:1)
- [docs/plans/ralplan-input-synthesis-from-assets.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-input-synthesis-from-assets.md:1)

Do not treat this file alone as the full execution authority.

## Canonical bundle declaration

The current canonical execution package is:

- `CEP-1` = Canonical Execution Package 1

`CEP-1` contains:

1. [docs/plans/ralplan-planning-integrity-note.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-planning-integrity-note.md:1)
2. [docs/specs/asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/specs/asset-centric-control-plane.md:1)
3. [docs/plans/ralplan-input-synthesis-from-assets.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-input-synthesis-from-assets.md:1)
4. this execution plan
5. [docs/plans/ralplan-task-breakdown-synthesis-from-assets.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-task-breakdown-synthesis-from-assets.md:1)
6. the named research inputs listed by the planner intake

## Historical but preserved branch

The older `test-asset-first` planning branch remains available for comparison and constraint language, but it is not the sole authority for this execution path:

- [docs/plans/ralplan-input-test-asset-first.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-input-test-asset-first.md:1)
- [docs/plans/prd-asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/prd-asset-centric-control-plane.md:1)
- [docs/plans/test-spec-asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/test-spec-asset-centric-control-plane.md:1)

## Unresolved-question register

| ID | Question | Status | Blocker level | Owner | Closure condition |
|---|---|---|---|---|---|
| U2 | Exact structured format for the first `rules manifest`, `corpus manifest`, and `mock contract manifest` | closed | resolved-in-Phase-0 | lane A + planner | closed by the structured YAML manifests committed under `docs/manifests/phase-0/` |
| U4 | Precise file layout for first corpus and mock manifests inside the repo | closed | resolved-in-Phase-0 | lane A/lane B + planner | closed by the committed `docs/manifests/phase-0/` layout and its README |
| U5 | Whether the first thin surface is CLI-first, local web-first, or a small dual surface | open | blocking-before-Phase-4 | lane E + planner | one surface choice is frozen before Task 4.2 starts |
| U6 | Whether the first proof uses a dedicated `src/package/` module or keeps package semantics in `src/asset/` | closed | resolved-in-Phase-1 | lane A + planner | closed by the dedicated `src/package/` module and its package/validation tests |

## Lane freeze schedule

- Freeze A: planning inputs freeze after Phase 0
  - freezes:
    - rules manifest
    - corpus manifest
    - mock contract manifest
  - required before:
    - Phase 1 and Phase 2 implementation begins
  - reopen only with:
    - named contradiction against research inputs or missing invariant class

- Freeze B: contract freeze after Phase 1
  - freezes:
    - package manifest shape
    - provenance metadata model
    - validation boundaries
  - required before:
    - Phase 3 and Phase 4 implementation begins
  - reopen only with:
    - failing fixture class, first-proof contradiction, or boundary violation

- Freeze C: integration freeze after Task 4.1 / before execution handoff
  - freezes:
    - minimum real Hermes path
    - thin local surface obligations
    - Gate 4 closed-loop criteria
  - required before:
    - `ralph` or `team` handoff
  - reopen only with:
    - inability to satisfy Gate 4 or contradiction with stable spec first-proof loop

## Problem

The project now has a grounded research corpus, but not yet a coherent execution plan for turning that research into software.

The risk is no longer lack of ideas.
The risk is drifting into:

- a thin Hermes adapter with no real product substrate
- a documentation pile with no synthesis loop
- a package model without provenance depth
- a provenance model without a user-facing product shape

## Product direction

Build a MoonBit-heavy software substrate for:

- capturing agent work
- attaching durable provenance and lineage
- packaging and reproducing `skill + profile + topology`
- providing a thin but real local/hosted management surface

with:

- Hermes as the first runtime host
- Agent Skills as the public skill concept
- Git as the first provenance substrate
- open-source test assets and mocks as the synthesis method

## RALPLAN-DR Summary

### Principles

- Reuse standards and mature runtimes directly where they are already strong.
- Put MoonBit at the center of the originality-critical substrate, not at every host boundary.
- Keep provenance deeper than UI.
- Keep package/share semantics explicit early.
- Use test assets and mocks to synthesize structure before binding every real integration.

### Decision Drivers

- The competition artifact must have a believable MoonBit-heavy center.
- The software must feel like a product, not a demo or glue layer.
- The execution plan must respect the user's insistence that all four centers matter:
  - provenance
  - package/share
  - capture/extraction
  - hosted/local product surface
- The first execution loop must remain small enough to finish in a scaffold-stage repo.

### Viable Options

#### Option A - Provenance-first execution

Build:

- checkpoint metadata branch
- lineage model
- Git-native materialization

Then add packages and surface.

Pros:

- strongest MoonBit substrate story
- high alignment with Entire-inspired semantics

Cons:

- risks deferring package/share clarity too long

#### Option B - Package-first execution

Build:

- manifest
- package validation
- export/import flow

Then layer provenance and capture under it.

Pros:

- externally legible early

Cons:

- risks shallow provenance and artificial package semantics

#### Option C - Synthesis-loop-first execution

Build a small but complete loop containing:

- rules/reference
- seed asset corpus
- mock boundaries
- provenance substrate
- package/export path
- thin local product surface

Pros:

- best fit for the actual synthesis method
- keeps all four centers present
- makes later hosted/local growth more natural

Cons:

- needs tighter scope discipline than single-center plans

### Recommendation

Choose Option C, with the following depth order:

1. provenance deepest
2. package/share next
3. capture/extraction thin but real
4. local product surface thin but real

## ADR

### Decision

Execute the project as a synthesis-loop-first system rather than a single-center implementation.

### Drivers

- the interview already established that the project needs all four centers
- the test-asset-driven method is part of how the software will be made coherent
- MoonBit is strongest in the structured substrate, not in reimplementing the runtime host

### Alternatives considered

- provenance-only first
- package-only first
- hosted-surface-first

### Why chosen

- provenance-only would under-serve the product layer
- package-only would under-serve the substrate
- hosted-surface-first would be UI-heavy before the domain semantics are stable

### Consequences

- research inputs remain first-class
- mock boundaries become explicit planning objects
- execution should be staged but vertically coherent

## Execution lanes

### Lane 1 - Rules and corpus stabilization

Goal:

- turn the current research outputs into a stable, reusable substrate input set

Files:

- [2026-04-19-seed-rules-reference.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-seed-rules-reference.md:1)
- [2026-04-19-seed-asset-corpus-candidates.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-seed-asset-corpus-candidates.md:1)
- [2026-04-19-seed-mock-boundaries.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-seed-mock-boundaries.md:1)

Deliverables:

- normalized rules glossary
- first corpus manifest
- first mock-boundary contract list

Why first:

- later code should not keep rediscovering the same rules

### Lane 2 - Provenance substrate

Goal:

- define the first durable MoonBit-native provenance layer

Planned targets:

- `src/provenance/`
- new package(s) for checkpoint metadata if needed

Deliverables:

- lineage model
- checkpoint metadata shape
- explicit internal-vs-durable split

Acceptance:

- one durable checkpoint metadata representation exists
- it can express linkage between internal capture and exported artifacts

### Lane 3 - Shareable package system

Goal:

- define and validate the first external package shape for:
  - `skill`
  - `profile`
  - `topology`

Planned targets:

- `src/asset/`
- possible new package/manifest module

Deliverables:

- package manifest shape
- validation rules
- export/import semantics

Acceptance:

- a package can be represented and validated
- package semantics do not assume raw runtime state is bundled

### Lane 4 - Capture normalization

Goal:

- normalize runtime-linked events into internal capture records

Planned targets:

- new capture module(s)
- adapter boundary code for one real Hermes-connected path

Deliverables:

- one runtime event shape
- one normalized internal capture representation
- linkage from capture to provenance

Acceptance:

- at least one real or replayed host event can become a normalized record

### Lane 5 - Thin local product surface

Goal:

- make the software visibly product-shaped early

Deliverables:

- inspect package
- inspect session and channel state
- inspect topology
- inspect projection visibility
- inspect lineage
- route one human control input
- trigger export/share-like action

Acceptance:

- the user can see something more concrete than internal structs
- the surface remains thin and subordinate to the substrate

## Recommended phase sequence

### Phase 0 - Research artifact normalization

Complete:

- [docs/manifests/phase-0/corpus-manifest.yaml](/Users/yetian/Desktop/finall-start-100-commits/docs/manifests/phase-0/corpus-manifest.yaml:1)
- [docs/manifests/phase-0/rules-manifest.yaml](/Users/yetian/Desktop/finall-start-100-commits/docs/manifests/phase-0/rules-manifest.yaml:1)
- [docs/manifests/phase-0/mock-contract-manifest.yaml](/Users/yetian/Desktop/finall-start-100-commits/docs/manifests/phase-0/mock-contract-manifest.yaml:1)

Status:

- completed on `2026-04-19`
- Freeze A can now treat the Phase 0 manifests as canonical execution inputs

### Phase 1 - Provenance and package contracts

Implement:

- checkpoint metadata types
- package manifest types
- validation boundaries

Status:

- package boundary frozen to dedicated `src/package/`
- first package manifest, validation boundary, and checkpoint metadata models implemented on `2026-04-19`

### Phase 2 - Git-native materialization path

Implement:

- first-wave fixture corpus
- mock share registry
- mock checkpoint/blob backend
- mock topology activation interface

Why now:

- Freeze B should be exercised in controlled conditions before deeper substrate work
- fixture and mock lanes prove the contracts can actually carry representative corpus pressure

### Phase 3 - Real substrate implementation

Implement:

- package/export core in MoonBit
- deeper provenance/materialization path
- capture normalization core
- Git backend split

### Phase 4 - Thin local surface

Implement:

- simple management/inspection surface
- export/share trigger path

### Phase 5 - Hosted/local expansion planning

Plan but do not overbuild yet:

- hosted management API
- remote registry/share
- analysis/search layer

## Verification strategy

### Research verification

- extracted rules remain traceable to inspected sources
- corpus candidates remain representative and non-redundant

### Design verification

- package, provenance, and capture boundaries do not collapse into Hermes internals
- default external package remains free of raw runtime state
- the first-proof loop still includes visible sessions, channels, and projections
- the thin control surface still supports one human routing action without encoding Hermes-specific roles

### Code verification

When code changes begin, validate with:

- `moon check`
- `moon test`
- `moon fmt`
- `moon info`

### Integration verification

- at least one real Hermes-connected path exists
- at least one mocked boundary exists for each heavy external interface
- at least one execution channel and one derived projection are visible through the control-plane surface
- at least one human control input can be routed without losing inspectability

## Risks and mitigations

- Risk: plan expands into too much infrastructure
  Mitigation:
  - keep the local product surface thin
  - defer hosted expansion beyond the first coherent loop

- Risk: MoonBit gets pushed into host-runtime logic that Hermes already owns
  Mitigation:
  - keep the Hermes-facing shell thin and explicit

- Risk: package semantics get invented without real corpus pressure
  Mitigation:
  - make corpus stabilization an execution lane, not a side note

- Risk: provenance becomes elegant but disconnected from actual user-visible software
  Mitigation:
  - require a thin surface and export path in the first vertical loop

## Acceptance criteria

- A planning document exists that sequences all four centers without flattening them into one.
- The first execution loop is defined in terms of lanes and phases, not abstract aspirations.
- The plan identifies:
  - what to reuse
  - what to mock
  - what to implement in MoonBit
- The plan preserves the current product identity from the interview outputs.
- The next execution mode can start from this plan without reopening the same research questions.
- The canonical bundle and historical-preservation map are explicit.
- `CEP-1` is ratified as the execution authority, with blocker gates and freeze policy preserved.
- The first-proof loop still proves session/channel/projection visibility and one human routing path, not only package/provenance inspection.
