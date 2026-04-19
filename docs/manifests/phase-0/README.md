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

This layout closes the Phase 0 file-placement question for the first execution loop.

## Phase 2 conformance anchors

Freeze B keeps package and provenance contracts frozen while Phase 2 exercises them
through fixtures, mocks, and regression checks.

- package manifest shape: [src/package/manifest.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/package/manifest.mbt:1)
- package validation boundaries: [src/package/validation.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/package/validation.mbt:1)
- provenance metadata contract: [src/provenance/metadata.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/provenance/metadata.mbt:1)
- package regression coverage: [src/package/package_test.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/package/package_test.mbt:1)
- provenance regression coverage: [src/provenance/provenance_test.mbt](/Users/yetian/Desktop/finall-start-100-commits/src/provenance/provenance_test.mbt:1)
- lane D review note: [docs/plans/reviews/2026-04-19-lane-d-package-provenance-conformance.md](/Users/yetian/Desktop/finall-start-100-commits/docs/plans/reviews/2026-04-19-lane-d-package-provenance-conformance.md:1)
