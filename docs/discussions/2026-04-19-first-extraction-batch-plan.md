# First Extraction Batch Plan

## Purpose

This note turns the research discussion into an automatically executable first batch.

It assumes:

- low-risk documentation and research work should continue without waiting for more user decisions
- the current workflow is still in clarification/interview mode
- the goal is to prepare strong inputs for later planning and implementation

## Batch goal

Produce the first concrete research outputs needed to start synthesizing the software from real assets and controlled boundaries.

This batch is not implementation yet.

It prepares:

- a seed test-asset corpus definition
- a seed rules/reference extraction set
- a seed mock-boundary slate

## Batch scope

### In scope

- identify first source priorities
- define what to extract from each source
- define intended output bucket for each extracted result
- define quality gates for source admission

### Out of scope

- copying large external repositories into this repo
- building the mocks
- implementing the product substrate
- choosing final hosted architecture

## First-batch source order

### 1. `agentskills/agentskills`

Reason:

- canonical public standard
- establishes the invariant base for all later extraction

Expected outputs:

- required skill fields checklist
- optional directory checklist
- compatibility rules summary

Output bucket:

- rules/reference layer

### 2. `anthropics/skills`

Reason:

- strongest high-quality public example corpus

Expected outputs:

- shortlist of representative skill examples
- example structure matrix:
  - minimal skill
  - skill with scripts
  - skill with references
  - skill with assets
  - more complex bundled skill

Output buckets:

- asset corpus candidates
- pattern/reference notes

### 3. `motiful/skill-forge`

Reason:

- strongest engineering/publishing workflow reference

Expected outputs:

- validation stages summary
- publish pipeline summary
- registration/install pattern notes
- candidate validation-service mock inputs

Output buckets:

- rules/reference layer
- mock-boundary inputs

### 4. `entireio/cli` + Entire docs

Reason:

- strongest open provenance/capture reference

Expected outputs:

- checkpoint metadata branch summary
- local-vs-synced split summary
- commit/checkpoint linkage notes
- candidate checkpoint/blob mock inputs

Output buckets:

- rules/reference layer
- mock-boundary inputs
- possible metadata corpus samples

### 5. Hermes docs

Reason:

- authoritative first-host boundary

Expected outputs:

- host responsibility checklist
- profile semantics summary
- plugin boundary summary
- runtime event mock candidate list

Output buckets:

- rules/reference layer
- mock-boundary inputs

## Deferred but queued for next batch

- Gitea hosted/local product-shape extraction
- GitHub client expectations for agent skills
- topology proxy sources
- MoonBit Git/backend capability validation notes

## Output artifacts to create from this batch

This batch should eventually produce or prepare:

1. `seed-rules-reference.md`
2. `seed-asset-corpus-candidates.md`
3. `seed-mock-boundaries.md`

These can be separate notes or sections in a single aggregated note.

## Admission rules for extracted material

A source item should enter the first batch only if it is:

- authoritative or clearly representative
- structurally relevant to our product subject
- concrete enough to be extracted into a stable rule, sample, or boundary

Exclude for now:

- low-quality community noise
- redundant examples that add volume without new structure
- highly vendor-specific details with no clear transfer value

## Quality gates

Each extracted result should satisfy:

### Clarity

- it is obvious why this item matters

### Bucket fit

- it is obvious whether the item belongs to:
  - asset corpus
  - rules/reference
  - mock-boundary inputs

### Transfer value

- it teaches something reusable about:
  - packaging
  - provenance
  - runtime boundary
  - hosted/local product shape

### Non-noise

- it does not merely duplicate what is already captured elsewhere in the batch

## Why this is the right automatic next step

This batch is safe to advance automatically because:

- it does not lock final architecture prematurely
- it improves the quality of later OMX planning
- it preserves optionality
- it turns broad discussion into reusable research structure

## Next step after this batch

Once the first batch outputs exist, the next best-practice step is:

- compare the extracted rules, corpus candidates, and mock boundaries
- identify the smallest coherent synthesis loop that uses them
- then hand that into `ralplan`
