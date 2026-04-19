# RALPLAN - Topology Test Fixture Freeze

- Status: `approved-draft`
- Source: `ralplan` handoff from `deep-interview`
- Last-Mirrored-From: `2026-04-19`

## Requirements Summary

- Treat `topology` as a first-phase **test asset**, not as a user-customizable protocol surface.
- Preserve the repo's current "no complex protocol" boundary.
- Freeze the first-wave topology fixtures around Anthropic's five coordination pattern families, plus one curated custom/hybrid fixture included for corpus coverage.
- Convert the current `working-default` topology slate into a phase-0 execution package with explicit acceptance criteria, documentation authority, and MoonBit validation.

## Grounded Context

Current repository evidence:

- [docs/discussions/2026-04-19-interview-handoff-note.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-interview-handoff-note.md:1) confirms the interview stage is complete for this slice and ready for planning handoff; its earlier "topology representation unresolved" language should not be treated as the current authority for this narrowed phase-0 lane.
- [docs/discussions/2026-04-19-topology-defaults-and-test-asset-priority.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-topology-defaults-and-test-asset-priority.md:1) contributed the six-fixture corpus seed and the structural-boundary rationale, but its broader template/parameterized/custom framing is narrowed by this plan to a bounded test-fixture scope.
- [docs/manifests/phase-0/topology-manifest.yaml](/Users/yetian/Desktop/finall-start-100-commits/docs/manifests/phase-0/topology-manifest.yaml:1) already defines six first-wave topology entries and marks the slate as `working-default`.
- [src/fixture/corpus.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/fixture/corpus.mbt:1) already materializes six topology fixtures in code alongside the skill and provenance fixtures.
- [src/fixture/fixture_test.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/fixture/fixture_test.mbt:1) already expects 12 total fixtures and validates topology fixture materialization, package compatibility, and graph-key derivation.
- [src/package/manifest.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/package/manifest.mbt:1) already supports `Topology(String)` as a first-class package subject while keeping runtime payload state outside the manifest.
- [src/package/package_test.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/package/package_test.mbt:1) already asserts topology subjects remain representable and shareable without runtime payload state.

## Scope

### In Scope

- freeze the current topology fixture lane as a first-class phase-0 test-asset package
- align discussion note, phase-0 topology manifest, fixture materialization, and tests
- add the minimum remaining MoonBit assertions needed to prove the lane is intentionally bounded
- make the `topology-manifest.yaml` transition from `working-default` to a reviewed frozen state when evidence is complete

### Out of Scope

- user-configurable topology authoring
- parameterized topology variants
- a general topology protocol or DSL
- UI editors for topology content
- live host/runtime topology import/export
- expanding beyond the six current first-wave topology examples

## RALPLAN-DR Summary

### Principles

- Keep topology as content and test assets first, not as protocol design work.
- Preserve the repo's runtime-agnostic, low-protocol posture.
- Reuse the current implemented MoonBit fixture/test baseline instead of reopening broad architecture.
- Freeze documentation and code together so planning truth and validation truth do not drift.

### Decision Drivers

- avoid reopening complex protocol scope
- capitalize on the fact that topology fixtures and tests already exist in code
- produce a narrow execution slice with clear MoonBit verification

### Viable Options

#### Option A - Freeze the current topology fixture lane with mandatory code/test tightening

Approach:

- treat the existing six topology fixtures as the official first-wave corpus
- align docs/manifests/tests around that narrow goal
- add explicit boundary assertions even if the current audit already passes
- stop short of new protocol or runtime integration work

Pros:

- smallest plan that matches the user's clarified intent
- grounded in code that already exists
- easy to validate with MoonBit commands
- avoids speculative topology product work

Cons:

- does not advance topology authoring capability
- leaves final topology schema intentionally incomplete
- may spend effort on code churn even if the current fixture lane is already aligned

#### Option B - Recast topology into a richer package/protocol design lane

Approach:

- deepen topology fields, package rules, and additional topology schema/protocol surface area now

Pros:

- moves toward a fuller long-term topology story

Cons:

- directly conflicts with the user's clarified "no complex protocol" boundary
- would reopen interview scope we just closed
- would add design churn without immediate validation payoff

#### Option C - Freeze docs and manifest authority first, with drift-only code changes

Approach:

- freeze the docs/manifests around the six-fixture topology corpus immediately
- audit the existing MoonBit fixtures and tests against the frozen manifest
- make code changes only if the audit finds drift or a missing boundary assertion

Pros:

- best fit for the current codebase, which already materializes and tests the six topology fixtures
- minimizes unnecessary code churn
- keeps the execution slice narrow and verification-focused

Cons:

- depends on the audit being precise about what counts as drift
- yields a smaller visible code diff if the lane is already aligned

### Recommendation

Choose Option C.

Freeze topology as a first-wave test-fixture lane using the current six examples, freeze docs/manifests first, then make code changes only if the fixture audit finds drift or a missing boundary assertion.

### Alternative Invalidation Rationale

- Option A is viable, but it assumes extra code/test tightening is needed before the audit proves drift.
- Option B is invalid for this slice because the user explicitly redirected away from topology customization and complex protocol design.

## ADR

### Decision

Adopt a docs-freeze-plus-drift-only topology-fixture plan: topology remains a phase-0 content/test-asset lane represented by six curated fixtures, with runtime/profile concerns intentionally kept outside the topology asset itself, and code changes occur only when the audit finds drift or one missing boundary assertion.

### Drivers

- The user clarified that topology should be treated as content and test assets first.
- The repository already has concrete topology fixtures and tests, so a freeze plan can be validated immediately.
- The repo's existing policy prefers lightweight contracts over speculative protocol complexity.

### Alternatives Considered

- freeze docs/manifests first, then apply drift-only code changes if needed
- freeze and validate the current topology fixture lane with mandatory extra code tightening
- expand topology into a broader schema/protocol lane now

### Why Chosen

- It matches the clarified scope.
- It uses current code and tests instead of inventing new surface area.
- It avoids unnecessary code churn if the existing fixture lane is already aligned.
- It creates a clean handoff for later execution without reopening architecture.

### Consequences

- The six topology fixtures become the authoritative first-wave topology corpus.
- `topology-manifest.yaml` becomes a `frozen` collection slate rather than a provisional note.
- [docs/discussions/2026-04-19-topology-defaults-and-test-asset-priority.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-topology-defaults-and-test-asset-priority.md:1) is rewritten, not merely superseded, so its wording matches the frozen six-fixture scope.
- Any future topology design/schema expansion must be reopened explicitly in a later planning cycle.

### Follow-ups

- finalize the topology fixture acceptance rules in docs and tests
- freeze the topology manifest status after validation
- keep future topology expansion behind a new planning gate

## Acceptance Criteria

- [docs/manifests/phase-0/topology-manifest.yaml](/Users/yetian/Desktop/finall-start-100-commits/docs/manifests/phase-0/topology-manifest.yaml:1) is updated from `working-default` to `frozen` with rationale that matches the current scope.
- [docs/manifests/phase-0/README.md](/Users/yetian/Desktop/finall-start-100-commits/docs/manifests/phase-0/README.md:1) explains topology as a frozen test-asset lane rather than an unfinished protocol project.
- [docs/discussions/2026-04-19-topology-defaults-and-test-asset-priority.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-topology-defaults-and-test-asset-priority.md:1) is rewritten so it no longer presents topology as unresolved, parameterized, or user-customizable in phase 0.
- [src/fixture/corpus.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/fixture/corpus.mbt:1) continues to materialize exactly the six topology fixtures already defined in the manifest.
- [src/fixture/fixture_test.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/fixture/fixture_test.mbt:1) verifies the six topology fixtures as first-wave approved assets and asserts their package and graph compatibility.
- [src/package/package_test.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/package/package_test.mbt:1) explicitly verifies that topology package objects remain free of embedded runtime payload state.
- `moon check`, `moon test`, `moon fmt`, and `moon info` all pass.

## Implementation Steps

1. Freeze the authority docs for topology-as-test-assets.
   Files:
   - [docs/discussions/2026-04-19-topology-defaults-and-test-asset-priority.md](/Users/yetian/Desktop/finall-start-100-commits/docs/discussions/2026-04-19-topology-defaults-and-test-asset-priority.md:1)
   - [docs/manifests/phase-0/topology-manifest.yaml](/Users/yetian/Desktop/finall-start-100-commits/docs/manifests/phase-0/topology-manifest.yaml:1)
   - [docs/manifests/phase-0/README.md](/Users/yetian/Desktop/finall-start-100-commits/docs/manifests/phase-0/README.md:1)
   Deliverable:
   - one coherent written position: topology is frozen as a six-item first-wave test corpus, not a customization/protocol lane

2. Audit the implemented topology fixtures against the frozen manifest.
   Files:
   - [src/fixture/corpus.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/fixture/corpus.mbt:1)
   - [src/fixture/fixture_test.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/fixture/fixture_test.mbt:1)
   Deliverable:
   - each manifest entry maps 1:1 to one local fixture and one stable assertion path

3. Apply drift-only code/test changes, and keep `src/topology/session.mbt` out of scope unless the audit proves a direct mismatch.
   Files:
   - [src/fixture/corpus.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/fixture/corpus.mbt:1)
   - [src/fixture/fixture_test.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/fixture/fixture_test.mbt:1)
   - [src/package/package_test.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/package/package_test.mbt:1)
   Deliverable:
   - no code changes if the audit finds full alignment
   - otherwise, only these narrow changes are allowed:
   - one explicit package-level assertion in [src/package/package_test.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/package/package_test.mbt:1) that topology fixture manifests keep `profile_ref=""` and `topology_ref=""` while remaining valid
   - one explicit topology-fixture assertion in [src/fixture/fixture_test.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/fixture/fixture_test.mbt:1) that graph-key output excludes profile/provider/runtime identifiers from the visible key and uses fixture ids/pattern families only as internal structural test labels
   - if that graph-boundary tightening requires helper adjustment, change [src/fixture/corpus.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/fixture/corpus.mbt:1) rather than broadening the shared topology/session contract
   - no changes to [src/package/manifest.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/package/manifest.mbt:1); the package contract file remains unchanged in this slice
   - no changes to [src/topology/session.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/topology/session.mbt:1) unless an existing test fails and the failure traces directly to session descriptor shape

4. Run MoonBit validation and freeze the lane.
   Commands:
   - `moon check`
   - `moon test`
   - `moon fmt`
   - `moon info`
   Deliverable:
   - a locally verified phase-0 topology fixture package ready for later execution handoff

## Risks and Mitigations

- Risk: the plan accidentally reopens topology customization scope.
  Mitigation:
  - keep all acceptance criteria attached to fixture materialization, boundary validation, and docs freezing only.

- Risk: docs and code disagree about whether topology is provisional or frozen.
  Mitigation:
  - freeze the manifest status and README wording in the same change as any final test updates.

- Risk: package tests still allow runtime-state leakage by implication.
  Mitigation:
  - if the audit finds the current assertions too implicit, add one explicit package-level assertion around empty `profile_ref` and `topology_ref` fields for topology fixture manifests.

## Verification Steps

1. Read the topology discussion note and manifest together and confirm both now state the same bounded phase-0 position: topology is a frozen six-fixture test-asset lane and is not presented as unresolved, parameterized, or user-customizable.
2. Verify the six topology fixture ids in [src/fixture/corpus.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/fixture/corpus.mbt:1) match the six entries in [topology-manifest.yaml](/Users/yetian/Desktop/finall-start-100-commits/docs/manifests/phase-0/topology-manifest.yaml:1).
3. If drift is found, verify the added package assertion lives in [src/package/package_test.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/package/package_test.mbt:1), the graph-boundary assertion lives in [src/fixture/fixture_test.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/fixture/fixture_test.mbt:1), and any helper adjustment was confined to [src/fixture/corpus.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/fixture/corpus.mbt:1).
4. Verify that [src/package/manifest.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/package/manifest.mbt:1) remains untouched, and that [src/topology/session.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/topology/session.mbt:1) stays untouched unless a failing test proved it was the direct cause.
5. Run `moon check`.
6. Run `moon test`.
7. Run `moon fmt`.
8. Run `moon info`.

## Available-Agent-Types Roster

- `planner`
- `architect`
- `critic`
- `executor`
- `test-engineer`
- `verifier`
- `writer`

## Follow-up Staffing Guidance

### Ralph Path

- `executor` x1, reasoning `high`
  Reason:
  - freeze docs/manifests and apply any narrow code/test updates in one lane
- `test-engineer` x1, reasoning `medium`
  Reason:
  - tighten boundary tests and run MoonBit verification
- `verifier` x1, reasoning `high`
  Reason:
  - confirm the final state matches the narrow no-protocol scope

### Team Path

- lane 1: `writer` x1, reasoning `medium`
  Reason:
  - freeze discussion + manifest + README wording
- lane 2: `executor` x1, reasoning `high`
  Reason:
  - align fixture and package code with the frozen manifest if any drift remains
- lane 3: `test-engineer` x1, reasoning `medium`
  Reason:
  - finalize tests and run MoonBit verification

## Launch Hints

- `$ralph "Freeze the phase-0 topology fixture lane according to docs/plans/ralplan-topology-test-fixture-freeze.md and verify with moon check/test/fmt/info."`
- `$team 3:executor "Freeze the phase-0 topology fixture lane according to docs/plans/ralplan-topology-test-fixture-freeze.md, keeping topology as test assets only and validating with MoonBit commands."`

## Team Verification Path

- Team proves:
  - docs/manifests agree on topology as six frozen first-wave test fixtures
  - fixtures and tests are aligned to the manifest
  - MoonBit validation passes
- Ralph verifies after handoff:
  - no customization/protocol scope leaked back in
  - the frozen topology lane is locally green and ready for the next bounded execution step
