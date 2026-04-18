# Test Spec - Asset-Centric Control Plane

- Status: `approved-draft`
- Source: `.omx/plans/test-spec-asset-centric-control-plane.md`
- Last-Mirrored-From: `2026-04-19`

## Goal

Verify that the first release proves the architectural claim: the system can turn content interaction into durable, inspectable assets without collapsing into runtime-specific or protocol-heavy design.

## Acceptance tests

### 1. Runtime attachment

- Given a reference runtime integration
- When it is attached to the control plane
- Then the kernel represents it through generic primitives rather than runtime-specific role names

### 2. Content-source wrapping

- Given a reference content source
- When it is wrapped by the system
- Then at least one execution channel is exposed
- And at least one derived projection can be produced from it

### 3. Human control routing

- Given a running wrapped content flow
- When a human submits a targeted control input
- Then the input reaches the intended control path
- And is not lost in the main content feed

### 4. Skill as asset

- Given a skill used or updated during operation
- When it is committed as an artifact
- Then it is represented as a versionable, shareable asset
- And has inspectable provenance to the relevant context

### 5. Checkpoint lineage

- Given an in-progress session state
- When a checkpoint is created
- Then the system records lineage to the relevant session, channel, or projection state
- And preserves references to external snapshot material as needed

### 6. Story and asset separation

- Given a meaningful interaction event
- When a story-facing artifact is produced
- Then it is distinct from raw transcript or log storage
- And remains linkable to underlying provenance

### 7. Provenance substrate flexibility

- Given the first proof uses Git as the default provenance substrate
- When the architecture is reviewed
- Then the invariants are stated in terms of commit, branch, and history semantics
- And not in terms of Git being irreplaceable

### 8. Example-removal resilience

- Given the CDDA example is removed from documentation
- When the architecture docs are read
- Then the kernel/control-plane model still stands on its own

### 9. Runtime-specific leakage check

- Given kernel tests run without Hermes-specific adapter code
- When the kernel modules are exercised
- Then no kernel invariant should require Hermes-only role names, payload schemas, or control semantics
- And the kernel-only package paths `src/topology`, `src/control`, `src/asset`, and `src/provenance` should pass without importing `src/adapter/hermes`

### 10. Provenance semantic check

- Given provenance tests run against the default Git-backed substrate
- When lineage assertions are evaluated
- Then the tests should assert commit, branch, fork, and lineage meaning
- And should not depend on Git CLI implementation details as the semantic contract

## Concrete verification targets

- `src/topology/topology_test.mbt`
- `src/control/control_test.mbt`
- `src/asset/asset_test.mbt`
- `src/provenance/provenance_test.mbt`
- `src/adapter/hermes/adapter_hermes_test.mbt`

## Verification modes

- Design verification via architecture documents
- Lightweight integration verification via one reference runtime plus one reference content source
- Provenance verification via persisted artifacts and lineage inspection
- Package verification via MoonBit package boundaries and tests

## Known test gaps for planning

- Exact adapter contract for external snapshots
- Exact blob storage backend behind the provenance layer
- Exact rendering details for the thin control surface
