# RALPLAN Input - Synthesis From Assets

- Status: `ratified-execution-authority`
- Source: `docs/discussions/2026-04-19-*`
- Last-Mirrored-From: `2026-04-19`

## Authority chain

This document is part of the active synthesis planning package.
Until a full `planner -> architect -> critic` pass completes, it must be read together with:

- [docs/plans/ralplan-planning-integrity-note.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-planning-integrity-note.md:1)
- [docs/specs/asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/specs/asset-centric-control-plane.md:1)
- the named research inputs under `docs/discussions/`

It is not yet a standalone execution authority.

## Canonical bundle declaration

The current canonical execution package is:

- `CEP-1` = Canonical Execution Package 1

`CEP-1` contains:

1. [docs/plans/ralplan-planning-integrity-note.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-planning-integrity-note.md:1)
2. [docs/specs/asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/specs/asset-centric-control-plane.md:1)
3. this document
4. [docs/plans/ralplan-synthesis-execution-plan.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-synthesis-execution-plan.md:1)
5. [docs/plans/ralplan-task-breakdown-synthesis-from-assets.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-task-breakdown-synthesis-from-assets.md:1)
6. preserved named research inputs from `docs/discussions/`

`CEP-1` is ratified for execution handoff, subject to its blocker gates and freeze policy.

## Historical but preserved branch

The earlier `test-asset-first` branch remains preserved for constraints, PRD framing, and verification language:

- [docs/plans/ralplan-input-test-asset-first.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-input-test-asset-first.md:1)
- [docs/plans/prd-asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/prd-asset-centric-control-plane.md:1)
- [docs/plans/test-spec-asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/test-spec-asset-centric-control-plane.md:1)

They are historical-but-preserved, not deleted and not the sole authority for the active synthesis branch.

## Unresolved-question register

| ID | Question | Status | Blocker level | Owner | Closure condition |
|---|---|---|---|---|---|
| U1 | Whether `CEP-1` should later collapse into one canonical index doc | open | non-blocking | planner | keep `CEP-1` bundle stable through first execution loop before reconsidering |
| U2 | Exact structured format for the first `rules manifest`, `corpus manifest`, and `mock contract manifest` | open | blocking-before-Task-1.1 | lane A + planner | format chosen and recorded in Phase 0 outputs |
| U3 | Required thin-surface scope beyond inspection and one export/share trigger | open | blocking-before-Task-4.2 | lane E + planner | Task 4.2 verification is frozen and ratified |

## Requirements Summary

- Treat the current interview stage as complete and use its outputs directly as planning input.
- Preserve the current project identity:
  - not just a Hermes plugin
  - not just a skill format
  - not a clone of Entire
  - not a clone of Gitea
- Plan around a product subject that combines:
  - capture/provenance
  - shareable package/share system
  - hosted/local management software
- Keep the synthesis method explicit:
  - collect open-source test assets
  - extract rules and representative samples
  - mock unstable host/service boundaries
  - reconnect to real systems later

## Grounded Context

The current repo now contains a tracked discussion corpus under [docs/discussions](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/README.md:1), including:

- architecture research
- software subject comparison
- MoonBit-native candidate matrix
- phase ordering across the four centers
- synthesis method from test assets
- test asset and mock-boundary strategy
- per-source extraction notes
- seed rules/reference
- seed asset corpus candidates
- seed mock boundaries
- interview handoff note
- research coverage manifest

The codebase still remains early-stage MoonBit scaffold plus thin architecture slices under:

- [src/topology](/Users/yetian/Desktop/finall-start-100-commits/src/topology/moon.pkg:1)
- [src/control](/Users/yetian/Desktop/finall-start-100-commits/src/control/moon.pkg:1)
- [src/asset](/Users/yetian/Desktop/finall-start-100-commits/src/asset/moon.pkg:1)
- [src/provenance](/Users/yetian/Desktop/finall-start-100-commits/src/provenance/moon.pkg:1)
- [src/adapter/hermes](/Users/yetian/Desktop/finall-start-100-commits/src/adapter/hermes/moon.pkg:1)

## Stable conclusions from interview

- Hermes is the first runtime host, not the product identity.
- Agent Skills should be reused as the public skill concept and compatibility surface.
- External shareable objects currently converge on:
  - `skill`
  - `profile`
  - `topology`
- Default external packages should not include:
  - raw trace
  - tmux/runtime state
  - in-flight session state
  - checkpoint internals by default
- MoonBit-native originality is strongest in:
  - provenance metadata and checkpoint lineage
  - capture normalization
  - package/export logic
  - topology/profile validation
  - Git-native materialization/publishing path
- Strong references are:
  - Entire for capture/provenance strategy
  - skill-forge for skill engineering/publishing discipline
  - Gitea for hosted/local Git-first product shape

## RALPLAN-DR Summary

### Principles

- Reuse strong standards and substrates directly when they are already good.
- Use MoonBit where it makes the software more original, more coherent, and easier to defend.
- Keep Hermes-facing integration thin.
- Separate product subject from synthesis method.
- Keep the final software self-consistent rather than cutting it into a narrow demo.

### Decision Drivers

- Build a competition artifact with a clear MoonBit-heavy center.
- Preserve compatibility with existing skill and host ecosystems.
- Use realistic test assets and mocks to pressure-test the architecture.
- Ensure the resulting software still feels like a product, not just a research note.

### Viable Options

#### Option A - Provenance-first substrate planning

Approach:

- Treat Git-native provenance and checkpoint lineage as the deepest layer
- plan package/export and hosted/local product surface on top of it

Pros:

- strongest MoonBit-native story
- tightly aligned with Entire-inspired capture strategy
- gives durable meaning to later package and hosting work

Cons:

- may under-specify the user-facing package and topology object if taken too narrowly

#### Option B - Package/share-first planning

Approach:

- Treat `skill + profile + topology` shareable packaging as the center
- plan provenance and capture as supporting layers

Pros:

- directly aligned with external reproducibility
- easy to explain from a product viewpoint

Cons:

- higher risk of elegant package shape without enough capture/provenance depth

#### Option C - Synthesis-loop-first planning

Approach:

- treat the first planning target as a complete synthesis loop:
  - rules/reference
  - asset corpus
  - mock boundaries
  - provenance
  - packaging
  - thin product surface

Pros:

- fits the "software synthesis from assets" methodology
- keeps capture, packaging, and hosted/local concerns connected
- best respects the user's insistence that all four centers matter

Cons:

- requires more careful scoping
- easier to produce an over-broad plan if not disciplined

### Recommendation

Choose Option C, with provenance deepest and packaging explicit.

The next plan should treat the software as a synthesis-driven substrate:

- collect and curate test assets
- define rules and invariants
- define mock boundaries
- build the MoonBit-native provenance/package/capture center
- keep hosted/local surface thin but real

## ADR

### Decision

Move from interview into planning using a synthesis-loop-first approach, grounded in the tracked research corpus under `docs/discussions/`.

### Drivers

- The interview has produced enough stable conclusions.
- The user wants best-practice autonomous continuation.
- The product needs all four centers, not a fake single-center simplification.

### Alternatives considered

- Stay in interview and keep clarifying.
- Plan only around provenance.
- Plan only around package/share.

### Why chosen

- Continuing interview would mostly re-open already-stable questions.
- Single-center planning would distort the product shape.
- The synthesis-loop framing best matches the user's stated workflow and competition strategy.

### Consequences

- Planning must explicitly include both product and synthesis-method work.
- Asset corpus and mock-boundary tasks become first-class planning inputs.
- Hosted/local surface must remain in scope even if initially thin.

### Follow-ups

- Produce a plan that sequences:
  - rules/reference stabilization
  - asset corpus curation
  - mock boundary definition
  - MoonBit-native provenance/package/capture implementation
  - thin hosted/local surface
- Keep interview docs as canonical research input for that plan.

## Planning Inputs To Consume Directly

- [architecture-research-report.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-architecture-research-report.md:1)
- [moonbit-native-candidates-matrix.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-moonbit-native-candidates-matrix.md:1)
- [synthesis-method-from-test-assets.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-synthesis-method-from-test-assets.md:1)
- [test-assets-and-mock-boundaries.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-test-assets-and-mock-boundaries.md:1)
- [per-source-extraction-notes.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-per-source-extraction-notes.md:1)
- [seed-rules-reference.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-seed-rules-reference.md:1)
- [seed-asset-corpus-candidates.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-seed-asset-corpus-candidates.md:1)
- [seed-mock-boundaries.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-seed-mock-boundaries.md:1)
- [interview-handoff-note.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-interview-handoff-note.md:1)
- [research-coverage-manifest.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-research-coverage-manifest.md:1)

## Acceptance Criteria For The Next Plan

- It does not reopen the product-identity question from scratch.
- It identifies a coherent synthesis loop instead of a vague implementation wishlist.
- It treats provenance, packaging, capture, and hosted/local product surface as one connected system.
- It distinguishes:
  - what to reuse directly
  - what to wrap
  - what must be MoonBit-native
- It identifies first execution lanes that are grounded in the seed rules, seed asset corpus, and seed mock boundaries.
- It names `CEP-1`, the historical-but-preserved branch, and the unresolved questions that remain intentionally open.
