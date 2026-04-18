# RALPLAN Input - Test Asset First

- Status: `approved-draft`
- Source: deep-interview outputs under `.omx/specs/` and `.omx/plans/`
- Last-Mirrored-From: `2026-04-19`

## Requirements Summary

- Mirror the formal project spec and planning artifacts into a Git-tracked directory.
- Keep `.omx/` as workflow state, not the only source of planning truth.
- Preserve the current product thesis:
  - asset-centric control plane
  - `skill` as the most important first-class asset
  - Hermes as first runnable reference, not exclusive target
  - Git as first default provenance substrate, but replaceable if semantics survive
- Continue planning according to `$ralplan` best practices rather than jumping into implementation.

## Grounded Context

Current repository evidence:

- [README.mbt.md](/Users/yetian/Desktop/finall-start-100-commits/README.mbt.md) defines this repo as a minimal MoonBit project intended for OMX workflow.
- [finall_start_100_commits.mbt](/Users/yetian/Desktop/finall-start-100-commits/finall_start_100_commits.mbt) currently contains only a tiny runtime contract stub, so the codebase is still at scaffold stage.
- [.gitignore](/Users/yetian/Desktop/finall-start-100-commits/.gitignore) ignores `.omx/`, so formal planning artifacts must live elsewhere to be committed.
- Existing working artifacts already live under `.omx/specs/` and `.omx/plans/`, but they are not yet mirrored into tracked docs.

## Authority and Sync Contract

- `docs/specs/asset-centric-control-plane.md` is the canonical tracked spec for humans and code review.
- `docs/plans/prd-asset-centric-control-plane.md` and `docs/plans/test-spec-asset-centric-control-plane.md` are the canonical tracked planning companions.
- `.omx/` remains the workflow surface for iterative interview, draft, and agent-run planning state.
- Mirroring happens when an artifact reaches an approved-draft or better state.
- Tracked docs must carry:
  - `Status`
  - `Source`
  - `Last-Mirrored-From`
- `.omx` copies may be pointer stubs if the tracked document is already authoritative.
- When a material planning decision changes, update the tracked docs first, then refresh any `.omx` mirrors that execution workflows depend on.

## RALPLAN-DR Summary

### Principles

- Make assets, especially `skill`, first-class in the product model before polishing runtime UX.
- Keep the kernel runtime-agnostic and the protocol layer lightweight.
- Use Git-tracked docs as the canonical human-readable planning surface.
- Separate workflow state from durable project documentation.
- Plan around a proof loop that is small enough to verify but large enough to prove the architecture.

### Decision Drivers

- Preserve asset provenance and future shareability.
- Avoid locking the architecture to Hermes, CDDA, or local-only storage.
- Create a planning surface that can guide incremental implementation in this minimal MoonBit repo.

### Viable Options

#### Option A - Docs-first mirror plus proof-slice-first sequencing

Approach:

- Treat `docs/specs/` and `docs/plans/` as the canonical tracked planning surface.
- Prove a thin topology and control slice before deepening the asset and provenance model.

Pros:

- Clean Git history
- Easy review and sharing
- Matches the repository's current early-stage shape
- Decouples durable docs from OMX internals
- Exercises the proof loop early
- Reduces the risk of over-modeling assets before routing semantics exist

Cons:

- Requires intentional duplication or mirroring from `.omx/`
- Needs discipline to keep copies in sync

#### Option B - Docs-first mirror plus strict asset-first sequencing

Approach:

- Keep `docs/` canonical, but fully model asset and provenance types before implementing thin topology and control routing.

Pros:

- Keeps the product center obvious
- Makes skill, checkpoint, and story semantics explicit early

Cons:

- Higher risk of elegant but unexercised type models
- Delays proof that humans and channels can actually route interactions
- Makes it easier to encode provenance assumptions before the control loop is proven

#### Option C - `.omx/` remains source of truth plus generated export

Approach:

- Keep `.omx/` as the main planning source and periodically export tracked docs into `docs/`.

Pros:

- Minimizes manual divergence during heavy workflow use
- Keeps OMX-native flow central

Cons:

- Formal docs feel secondary
- Higher risk of stale Git-tracked docs
- Worse default ergonomics for collaborators who read the repo without OMX context

### Recommendation

Choose Option A.

Keep `.omx/` for workflow state, promote Git-tracked docs to the canonical human-facing spec and plan surface, and prove a thin topology/control slice before deepening asset and provenance models.

### Alternative invalidation rationale

- Option B is viable, but it front-loads durable asset modeling before the project has proven that sessions, projections, and human control routing actually work in this repo.
- Option C is viable during intense OMX-only work, but it makes durable repository documentation feel derivative and easier to neglect.

## ADR

### Decision

Adopt a docs-first canonical mirror for formal spec and planning artifacts, anchored by an asset-centric model with proof-slice-first execution sequencing.

### Drivers

- The repo needs commit-visible planning artifacts.
- The architecture is still fluid and needs reviewable design docs.
- The implementation surface is still mostly greenfield.

### Alternatives considered

- Keep `.omx/` as the only true plan source and export tracked docs secondarily.
- Skip the mirror and move directly into code scaffolding.

### Why chosen

- A tracked docs surface gives the repo a stable narrative and review path.
- It supports future agent execution without forcing contributors to inspect `.omx/`.
- It keeps the current planning work from remaining effectively hidden.

### Consequences

- The repo now needs light discipline around spec and plan updates.
- Future implementation plans should update both workflow copies and tracked docs when material changes happen.

### Follow-ups

- Create a formal docs layout for specs and plans.
- Keep the first implementation plan aligned to asset-first architecture boundaries.
- Use this plan as the handoff input for the next execution planning pass.
- Lock the first proof defaults so execution does not reopen foundational scoping questions.

## Locked defaults for execution

- Reference runtime: Hermes
- First proof content source: a simpler skill-corpus or document-derived source before CDDA
- Persistence split:
  - Git for docs, skill artifacts, commit metadata, and provenance-facing refs
  - blob storage for large snapshots or replay payloads
  - adapter-owned runtime state exposed through snapshot references
- Thin control surface:
  - local web-first
  - projection list
  - targeted input box
  - commit and checkpoint actions

## Acceptance Criteria

- Formal spec exists in a Git-tracked location.
- Formal PRD exists in a Git-tracked location.
- Formal test spec exists in a Git-tracked location.
- A Git-tracked `ralplan` handoff file exists and reflects the current asset-first direction.
- The mirrored docs remain consistent with the current `.omx/` planning artifacts.
- The plan identifies concrete next implementation slices for this MoonBit repo.

## Implementation Steps

1. Formalize tracked planning docs
   Files:
   - [docs/specs/asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/specs/asset-centric-control-plane.md)
   - [docs/plans/prd-asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/prd-asset-centric-control-plane.md)
   - [docs/plans/test-spec-asset-centric-control-plane.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/test-spec-asset-centric-control-plane.md)
   - [docs/plans/ralplan-input-test-asset-first.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/ralplan-input-test-asset-first.md)
   Deliverable:
   - Canonical tracked planning surface for the repo.

2. Stabilize the implementation package map
   Current files:
   - [finall_start_100_commits.mbt](/Users/yetian/Desktop/finall-start-100-commits/finall_start_100_commits.mbt)
   - [finall_start_100_commits_test.mbt](/Users/yetian/Desktop/finall-start-100-commits/finall_start_100_commits_test.mbt)
   Planned targets:
   - `/Users/yetian/Desktop/finall-start-100-commits/src/topology/moon.pkg`
   - `/Users/yetian/Desktop/finall-start-100-commits/src/control/moon.pkg`
   - `/Users/yetian/Desktop/finall-start-100-commits/src/asset/moon.pkg`
   - `/Users/yetian/Desktop/finall-start-100-commits/src/provenance/moon.pkg`
   - `/Users/yetian/Desktop/finall-start-100-commits/src/adapter/hermes/moon.pkg`
   Deliverable:
   - A MoonBit package layout that reflects topology, control, asset, provenance, and adapter concerns.
   Public symbols to define:
   - `src/topology`: `SessionId`, `ChannelId`, `ProjectionId`, `Subscription`
   - `src/control`: `ControlTarget`, `ControlCommand`, `route_input`
   - `src/asset`: `SkillAsset`, `AssetCommit`, `CommitKind`
   - `src/provenance`: `LineageRef`, `LineageNode`, `HistoryGraph`
   - `src/adapter/hermes`: `HermesDescriptor`, `to_topology_event`
   Tests to add:
   - `src/topology/topology_test.mbt`
   - `src/control/control_test.mbt`
   - `src/asset/asset_test.mbt`
   - `src/provenance/provenance_test.mbt`
   - `src/adapter/hermes/adapter_hermes_test.mbt`

3. Prove a thin topology and control slice first
   Planned targets:
   - `/Users/yetian/Desktop/finall-start-100-commits/src/topology/session.mbt`
   - `/Users/yetian/Desktop/finall-start-100-commits/src/topology/channel.mbt`
   - `/Users/yetian/Desktop/finall-start-100-commits/src/topology/projection.mbt`
   - `/Users/yetian/Desktop/finall-start-100-commits/src/topology/subscription.mbt`
   - `/Users/yetian/Desktop/finall-start-100-commits/src/control/router.mbt`
   Deliverable:
   - A minimal session/channel/projection/control path that can exercise the proof loop without runtime-specific roles.

4. Implement asset and provenance primitives on top of the proven topology slice
   Planned targets:
   - `/Users/yetian/Desktop/finall-start-100-commits/src/asset/skill.mbt`
   - `/Users/yetian/Desktop/finall-start-100-commits/src/asset/commit.mbt`
   - `/Users/yetian/Desktop/finall-start-100-commits/src/provenance/history.mbt`
   - `/Users/yetian/Desktop/finall-start-100-commits/src/provenance/ref.mbt`
   Deliverable:
   - Core data models for skill, checkpoint, story commit, and provenance semantics.

5. Prove the first integration loop with a thin reference adapter path
   Planned targets:
   - `/Users/yetian/Desktop/finall-start-100-commits/src/adapter/hermes/`
   - `/Users/yetian/Desktop/finall-start-100-commits/scripts/verify-moon-omx.sh`
   Deliverable:
   - One runnable reference path and one proof-oriented verification script.

Implementation note:

- Asset-first describes the product center and durable model, not the rule that every implementation step must start inside `src/asset/`.
- Proof-slice-first sequencing is intentional: prove the thin topology/control loop early, then deepen asset and provenance modeling on top of that working slice.

## Risks and Mitigations

- Risk: formal docs drift away from `.omx` state
  Mitigation:
  - treat tracked docs as the canonical human-facing surface and update `.omx` mirrors when decisions change

- Risk: architecture gets trapped in reference-runtime assumptions
  Mitigation:
  - keep planned modules runtime-agnostic and isolate adapters under explicit adapter paths

- Risk: Git becomes over-specialized in the core data model
  Mitigation:
  - encode provenance semantics in MoonBit types, not Git commands alone

- Risk: proof scope expands into full product ambition too early
  Mitigation:
  - keep the first implementation loop focused on one content source, one adapter path, and one durable asset event

## Verification Steps

- Verify tracked docs exist:
  - `git ls-files --error-unmatch docs/specs/asset-centric-control-plane.md`
  - `git ls-files --error-unmatch docs/plans/prd-asset-centric-control-plane.md`
  - `git ls-files --error-unmatch docs/plans/test-spec-asset-centric-control-plane.md`
  - `git ls-files --error-unmatch docs/plans/ralplan-input-test-asset-first.md`
- Verify canonical planning files are present:
  - `test -f docs/specs/asset-centric-control-plane.md`
  - `test -f docs/plans/prd-asset-centric-control-plane.md`
  - `test -f docs/plans/test-spec-asset-centric-control-plane.md`
  - `test -f docs/plans/ralplan-input-test-asset-first.md`
- Verify mirror and pointer-stub contract:
  - `rg -n -F -- '- Source: `.omx/specs/deep-interview-game-kernel-control-plane.md`' docs/specs/asset-centric-control-plane.md`
  - `rg -n -F -- '- Source: `.omx/plans/prd-asset-centric-control-plane.md`' docs/plans/prd-asset-centric-control-plane.md`
  - `rg -n -F -- '- Source: `.omx/plans/test-spec-asset-centric-control-plane.md`' docs/plans/test-spec-asset-centric-control-plane.md`
  - `test -f .omx/plans/ralplan-input-test-asset-first.md`
  - `test -f .omx/plans/prd-asset-centric-control-plane.md`
  - `test -f .omx/plans/test-spec-asset-centric-control-plane.md`
  - `rg -n '/docs/plans/ralplan-input-test-asset-first.md' .omx/plans/ralplan-input-test-asset-first.md`
  - `rg -n '/docs/plans/prd-asset-centric-control-plane.md' .omx/plans/prd-asset-centric-control-plane.md`
  - `rg -n '/docs/plans/test-spec-asset-centric-control-plane.md' .omx/plans/test-spec-asset-centric-control-plane.md`
- Verify invariant parity between tracked docs and `.omx` interview source:
  - `rg -n 'Hermes.*first runnable reference' docs/specs/asset-centric-control-plane.md .omx/specs/deep-interview-game-kernel-control-plane.md`
  - `rg -n 'git.*first default provenance substrate' docs/specs/asset-centric-control-plane.md .omx/specs/deep-interview-game-kernel-control-plane.md`
  - `rg -n 'heavy.*A2A.*IRC' docs/specs/asset-centric-control-plane.md .omx/specs/deep-interview-game-kernel-control-plane.md`
  - expected result:
    - all three commands return matches in both files
    - if any invariant is missing from either file, the mirror is out of parity
- Verify MoonBit package structure once scaffolding lands:
  - `moon check`
  - `moon test`
  - `moon test --outline`
  - `bash scripts/verify-moon-omx.sh`
- Verify kernel-only boundary once scaffolding lands:
  - `moon test src/topology src/control src/asset src/provenance`
  - expected evidence:
    - `src/topology/topology_test.mbt` passes without imports from `src/adapter/hermes`
    - `src/control/control_test.mbt` proves `route_input` handles targeted control commands without Hermes role names
    - `src/asset/asset_test.mbt` proves `SkillAsset` and `AssetCommit` creation
    - `src/provenance/provenance_test.mbt` proves lineage and branch semantics without Git CLI coupling
- Verify proof artifacts after the first runnable slice:
  - `moon test src/adapter/hermes`
  - expected evidence:
    - `src/adapter/hermes/adapter_hermes_test.mbt` emits at least one `HermesDescriptor` or equivalent adapter descriptor
    - `src/topology/topology_test.mbt` or an adjacent integration test proves at least one projection relationship
    - `src/asset/asset_test.mbt` plus `src/provenance/provenance_test.mbt` prove one durable asset record with lineage metadata

## Available Agent Types Roster

- `planner`
- `architect`
- `critic`
- `executor`
- `verifier`
- `writer`
- `test-engineer`
- `debugger`
- `explore`

## Follow-up Staffing Guidance

### Ralph path

- `executor` with `high` reasoning for core MoonBit modeling
- `writer` with `high` reasoning for docs synchronization
- `verifier` with `high` reasoning for proof-loop validation

### Team path

- 1 `architect` lane for package boundaries and invariants
- 1 `executor` lane for asset/provenance primitives
- 1 `executor` or `test-engineer` lane for topology and verification harness
- 1 `writer` lane for tracked docs and examples

## Launch Hints

- `$ralph "Implement docs/plans/ralplan-input-test-asset-first.md with asset-first priorities"`
- `$team "Execute docs/plans/ralplan-input-test-asset-first.md with one architecture lane, two implementation lanes, and one verification/docs lane"`

## Team Verification Path

- Team proves:
  - asset and provenance primitives compile
  - topology primitives compile
  - one thin reference adapter path is scaffolded
  - docs remain aligned with the implementation
- Ralph then verifies:
  - the proof loop is coherent end-to-end
  - acceptance criteria remain satisfied
  - no kernel concept has drifted into runtime-specific roles

## Changelog

- Initial tracked `ralplan` plan created from deep-interview outputs and repository inspection.
- Added authority and sync contract, explicit boundary invariants handoff, and proof-loop-first implementation ordering after architect review.
- Locked first-proof defaults, concrete MoonBit package boundaries, and exact verification commands after critic review.
