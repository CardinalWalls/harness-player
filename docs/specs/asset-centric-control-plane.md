# Asset-Centric Control Plane Spec

- Status: `approved-draft`
- Source: `.omx/specs/deep-interview-game-kernel-control-plane.md`
- Last-Mirrored-From: `2026-04-19`

## Intent

Build a MoonBit-centered, runtime-agnostic control plane for content-driven agent systems where the primary product is not the live interaction itself, but the durable assets produced from it, especially `skill`.

## Product definition

This project is an asset-centric control plane.

Its job is to:

- wrap a content source behind sessions and channels
- let humans and agents observe, route, filter, and intervene
- capture meaningful moments as durable assets
- version, reuse, and share those assets

The center is the asset lifecycle, especially `skill`.

## Primary user

- A human operator working with their own agent runtime
- Hermes is the first runnable reference, not the exclusive target

## First-class entities

- `skill`
- `commit`
- `checkpoint / snapshot`
- `story commit`
- `session`
- `channel`
- `projection`
- `subscription`
- `rule / trigger / hook`
- `asset / blob`

## In scope

- Define the kernel/control-plane primitives needed to model session-based content flows
- Make `skill` and related assets first-class, versionable, and shareable
- Support one runnable reference integration path, with Hermes as the most practical first target
- Support one reference content-source path, which may be CDDA or a simpler source if it proves the same architecture faster
- Provide a thin human-facing control surface that can inspect projections, route input, and invoke commits/checkpoints
- Support durable provenance for assets, branches, and meaningful events

## Out of scope

- Solving high-quality autonomous gameplay
- Optimizing the game loop, game strategy, or agent game competence
- Building a polished final frontend in the first version
- Building a heavy general A2A protocol or IRC-style protocol substrate as the core architecture
- Collapsing the kernel into Hermes-specific runtime assumptions
- Defining fixed planes or fixed agent roles as kernel concepts

## Decision boundaries

The first implementation may decide without reopening scope on:

- using Hermes as the first runnable reference implementation
- using a simpler content source than CDDA for the first proof
- using local-first persistence for the first proof path
- keeping the human surface thin in the first proof
- keeping the protocol layer lightweight

The project should not quietly drift into:

- a Hermes-only architecture
- a permanently local-only architecture
- a generic chat/transcript product where `skill` is secondary
- opaque storage that loses branch, commit, or provenance meaning

## Provenance stance

- `git` is the first default provenance substrate
- `git` is replaceable if a better substrate preserves:
  - commit-like checkpoints
  - branch/fork lineage
  - reproducible provenance
  - inspectable history
  - asset linkage between code, skill, checkpoint, and story artifacts

## Boundary invariants

- Kernel must not encode runtime-specific roles such as executor, coach, narrator, or Hermes-only control semantics.
- Kernel must not depend on adapter-specific payload schemas beyond generic descriptors and opaque snapshot references.
- Adapters may produce rich runtime-specific payloads, but the kernel only owns:
  - session and channel topology
  - projection relationships
  - provenance and lineage semantics
  - references to external snapshots
- Provenance owns lineage semantics, not blob bytes or runtime-owned process state.
- Asset types own the durable business objects such as `skill`, `checkpoint`, and `story commit`.
- Provenance types own identity, lineage, branch, and commit relationships between those asset records.
- External snapshot storage remains adapter-owned; kernel records stable references and relationships.

## Constraints

- Kernel must remain runtime-agnostic
- Hermes is a reference adapter path, not the system identity
- Protocol layer should stay light
- Architecture should support growth toward a Gitea-like shared or deployable asset system
- MoonBit should own the kernel/control-plane core

## First-proof loop

1. Prepare a content source plus one or more agent profiles/skills.
2. Stand up sessions and channels through the wrapper/control plane.
3. Prove information flows and projections are visible and routable.
4. Allow a human to intervene through the control surface.
5. Produce at least one durable asset event:
   - checkpoint
   - story commit
   - skill commit
6. Persist the result with inspectable provenance.

## Acceptance criteria

- A reference runtime can attach without the kernel encoding runtime-specific roles
- A content source can be wrapped so that at least one execution channel and one derived projection are visible
- A human can route at least one control input without being buried by the content feed
- The system can create at least one durable asset record with lineage to the relevant session, channel, or projection state
- `skill` can be represented as a versionable, shareable asset rather than only a transient prompt blob
- The provenance layer can show how a resulting asset was produced
- The architecture remains valid even if the CDDA-specific example is removed

## Inspirations

- `motiful/skill-forge`
- Entire
- Gitea
- `entire.io`
- `newtype-ai/nit` as non-blocking inspiration only
