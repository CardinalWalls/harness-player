# Phase 0 Manifest Layout

This directory contains the frozen Phase 0 outputs for `CEP-1`.

## Format decision

All Phase 0 manifests use structured YAML with a shared top-level shape:

- `manifest_kind`
- `schema_version`
- `phase`
- `status`
- `derived_from`
- `decision_record`
- one typed entries collection

Why this format:

- it is machine-readable for later MoonBit fixture generation
- it remains readable during planning and review
- it avoids reopening prose parsing during Phase 1

## File layout

- [rules-manifest.yaml](/Users/yetian/Desktop/finall-start-100-commits/docs/manifests/phase-0/rules-manifest.yaml:1)
- [corpus-manifest.yaml](/Users/yetian/Desktop/finall-start-100-commits/docs/manifests/phase-0/corpus-manifest.yaml:1)
- [mock-contract-manifest.yaml](/Users/yetian/Desktop/finall-start-100-commits/docs/manifests/phase-0/mock-contract-manifest.yaml:1)
- [topology-manifest.yaml](/Users/yetian/Desktop/finall-start-100-commits/docs/manifests/phase-0/topology-manifest.yaml:1)

This layout closes the Phase 0 file-placement question for the first execution loop.

## Topology note

`topology-manifest.yaml` is now frozen for Phase 0 as a bounded six-fixture
test-asset lane.

Reason:

- the repository already materializes the six first-wave topology fixtures locally
- existing tests already prove the package and graph seams for this lane
- freezing the lane keeps topology in the content-and-fixture domain instead of reopening protocol design

What this freeze means:

- the six current topology items are the authoritative first-wave corpus
- the corpus is intentionally structural and keeps runtime/provider state outside topology objects
- the curated `custom-hybrid-composition` sample exists for coverage, not as a promise of live topology authoring in Phase 0

Use it to drive:

- first-wave topology fixture validation
- fixture generation and regression planning
- package-vs-profile-vs-runtime boundary review

## Phase 2 conformance anchors

Freeze B keeps package and provenance contracts frozen while Phase 2 exercises them
through fixtures, mocks, and regression checks.

- package manifest shape: [src/package/manifest.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/package/manifest.mbt:1)
- package validation boundaries: [src/package/validation.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/package/validation.mbt:1)
- provenance metadata contract: [src/provenance/metadata.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/provenance/metadata.mbt:1)
- package regression coverage: [src/package/package_test.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/package/package_test.mbt:1)
- provenance regression coverage: [src/provenance/provenance_test.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/provenance/provenance_test.mbt:1)
- lane D review note: [docs/plans/reviews/2026-04-19-lane-d-package-provenance-conformance.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/reviews/2026-04-19-lane-d-package-provenance-conformance.md:1)
