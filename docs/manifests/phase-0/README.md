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
