# OMX Interview Summary - 2026-04-19

## Current OMX status

- We are still inside the OMX clarification loop.
- Current phase is effectively `deep-interview`, not `ralplan`.
- The discussion is still about product identity, system boundaries, and what should count as the software-synthesis subject.

## Stable conclusions so far

- The project is not about proving that agents can play the game well.
- Hermes is the first practical runtime host, but not the product identity.
- Hermes loads and runs skills/profiles/agents; that runtime orchestration is not the center of the product.
- The Hermes plugin is important, and we must write it, but it is an adapter/integration surface rather than the product center.
- The external shareable package should default to:
  - `skill`
  - `profile`
  - `topology`
- The default shareable package should not include:
  - `trace`
  - `checkpoint`
  - `tmux` runtime state
  - in-flight runtime context
- Internal capture remains valuable, especially for future extraction such as `trace -> skill` or other derived assets.
- External sharing success means another person can run the same `skill/profile/topology` and reproduce the core experience, not necessarily the exact process.

## Important corrections made during discussion

- `skill` is not a Hermes-only concept and not something invented here.
- `skill` should be treated closer to portable code/content capability, consistent with the open Agent Skills ecosystem.
- We should stop speaking as if MoonBit "defines skill itself". A better framing is that our software may define how `skill`, `profile`, and `topology` are packaged, linked, validated, captured, and shared.

## What still needs work

- We still need a clean statement of the real product center.
- We still need to decide how much of the storage/provenance/hosting substrate is part of the competition artifact versus reused infrastructure.
- We still need to decide how much Git capability should be implemented directly in MoonBit.
- We still need to study `skill-forge` more carefully before locking the product framing.
- We still need to decide whether `DuckDB` is required, optional, or premature.

## External reference notes gathered so far

- `Entire` is useful as a capture/provenance reference:
  - capture full sessions during work
  - keep temporary checkpoints locally
  - permanently store checkpoint metadata when commits happen
  - link checkpoints to commits via Git trailers
- `skill-forge` is useful as a skill-engineering and publishing reference:
  - treats skills as engineered, publishable units
  - validates structure, packaging, security, registration, and publishing
  - assumes Git/GitHub as a real distribution substrate
- `Agent Skills` is an open standard:
  - a skill is a directory with `SKILL.md`
  - optional `scripts/`, `references/`, and `assets/`
  - compatibility and metadata are explicit parts of the format

## Open questions for next discussion turn

- What is the real software-synthesis subject:
  - the hosting/sharing/provenance software
  - the capture/extraction system
  - the Git-native substrate
  - or a combination of these
- Should Git/provenance in the competition artifact rely mainly on:
  - MoonBit-native Git implementation
  - libgit2 bindings
  - or a staged hybrid
- Does the product require:
  - blob storage
  - an embedded query/analytics database such as DuckDB
  - both
  - or only one in phase 1
- How does `skill-forge` change the understanding of the product center if the goal includes generating test assets at scale?
