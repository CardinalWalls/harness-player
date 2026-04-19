# Seed Asset Corpus Candidates

## Purpose

This note records the first realistic asset candidates to include in a future test asset corpus.

The goal is not to mirror entire upstream repositories.

The goal is to curate representative examples that stress:

- skill packaging
- compatibility
- references/assets usage
- profile-linked expectations
- provenance metadata handling

## Admission rule

An item should enter the corpus if it is:

- concrete
- structurally representative
- useful for validation or packaging stress
- not redundant with stronger examples already selected

## Candidate set A - Canonical skill shape

### A1. Minimal skill example

Candidate source:

- `/tmp/omx-research/skills/template/SKILL.md`

Why include:

- clean baseline for standard-conforming minimal skill packaging

What it tests:

- minimum accepted shape
- frontmatter parsing
- name/description validation

## Candidate set B - Real public example skills

### B1. Minimal real skill

Candidate source:

- `/tmp/omx-research/skills/skills/algorithmic-art/SKILL.md`

Why include:

- real public example with low structural complexity

What it tests:

- realistic but lightweight skill body

### B2. Skill with reference files

Candidate sources:

- `/tmp/omx-research/skills/skills/pdf/SKILL.md`
- `/tmp/omx-research/skills/skills/pdf/forms.md`
- `/tmp/omx-research/skills/skills/pdf/reference.md`

Why include:

- demonstrates multi-file skill structure

What it tests:

- progressive disclosure
- references handling
- package integrity across multiple text files

### B3. Skill with extra runtime dependency hints

Candidate sources:

- `/tmp/omx-research/skills/skills/slack-gif-creator/SKILL.md`
- `/tmp/omx-research/skills/skills/slack-gif-creator/requirements.txt`

Why include:

- shows that real skills may imply dependency handling beyond `SKILL.md`

What it tests:

- dependency metadata interpretation
- package validation under nontrivial skill folders

### B4. Skill with bundled static asset

Candidate sources:

- `/tmp/omx-research/skills/skills/theme-factory/SKILL.md`
- `/tmp/omx-research/skills/skills/theme-factory/theme-showcase.pdf`

Why include:

- proves that some skills have large or binary side assets

What it tests:

- asset packaging
- asset reference integrity
- package size assumptions

## Candidate set C - Large corpus stress

### C1. Large community skill collection

Candidate source:

- `mukul975/Anthropic-Cybersecurity-Skills`

Why include:

- one of the clearest large-scale skill corpora

What it tests:

- scale assumptions
- corpus indexing
- large-batch validation

Initial use mode:

- sample-driven, not full mirror yet

## Candidate set D - Provenance metadata samples

### D1. Entire checkpoint metadata examples

Candidate sources:

- `/tmp/omx-research/cli/docs/architecture/sessions-and-checkpoints.md`
- any reproducible checkpoint metadata fixtures or outputs derived from:
  - `/tmp/omx-research/cli/e2e/tests/checkpoint_metadata_test.go`
  - `/tmp/omx-research/cli/e2e/testutil/metadata.go`

Why include:

- strongest current reference for durable metadata linked to commits

What it tests:

- checkpoint summary structure
- lineage rules
- local-vs-durable split

Initial use mode:

- metadata-shape extraction first
- raw copied fixtures only if clearly reusable

## Candidate set E - Profile-like assets

### E1. Hermes profile export examples

Candidate source:

- profile export examples if captured from docs or runtime later

Why include:

- `profile` is part of our planned external shareable object

What it tests:

- host-linked profile assumptions
- what should remain host-specific vs package-level

Current status:

- not yet harvested

## Candidate set F - Topology proxy assets

### F1. Role/workflow examples from multi-agent repos

Candidate sources:

- workflow-style skill repositories
- role-lane examples from agentic coding/workflow repos

Why include:

- topology is currently the least standardized external object in the system

What it tests:

- relationship modeling
- static structure representation
- activation entrypoints

Current status:

- not yet curated into a stable set

## Initial quality judgment

- A-set candidates: `A`
- B-set candidates: `A-`
- C-set candidates: `A-`
- D-set candidates: `A`
- E-set candidates: pending
- F-set candidates: pending

## Immediate next action

The next iteration should turn these candidates into:

- exact files to mirror or snapshot
- exact metadata to record for each sample
- exact reasons for inclusion in the corpus
