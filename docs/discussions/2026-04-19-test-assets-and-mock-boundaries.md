# Test Assets and Mock Boundaries

## Purpose

This document records the research-side inputs for the project's software-synthesis workflow.

It exists because current OMX discussion clarified that:

- the product subject and the synthesis method are different
- the software should be synthesized from realistic test assets
- where direct integration is too unstable, expensive, or host-coupled, mock boundaries should be used

This document therefore focuses on:

- which test assets we should collect first
- which boundaries should be mocked first
- which boundaries should stay real early

## Relationship to OMX

This document is not a replacement for OMX planning.

It is a research input surface for OMX:

- `deep-interview` can use it to clarify scope and terminology
- later `ralplan` can use it to choose a coherent execution slice

## Section A - Test asset classes

### A1. Public skill assets

Collect:

- open-standard Agent Skills repositories
- single-skill repos
- multi-skill repos
- examples with `scripts/`, `references/`, and `assets/`

Why:

- these define realistic external shareable objects
- they stress packaging, compatibility, and validation logic

Initial sources:

- `agentskills/agentskills`
- `anthropics/skills`
- `motiful/skill-forge`
- high-quality public skill repos from GitHub/Copilot/Hermes ecosystems

### A2. Host/runtime-linked skill assets

Collect:

- Hermes-installed skills
- skills with explicit compatibility constraints
- skills that assume tool/runtime availability

Why:

- these reveal where pure open-standard skills end and runtime assumptions begin
- they help define what belongs in `profile` or `topology` rather than in `skill`

Initial sources:

- Hermes bundled and optional skills
- Hermes hub-compatible skill examples

### A3. Profile-like runtime assets

Collect:

- Hermes profile exports/imports
- config examples that reflect isolated agent runtime setups
- model/provider/gateway-specific profile patterns

Why:

- `profile` is part of the converged external shareable object
- profile semantics must be grounded in real host/runtime usage

Initial sources:

- Hermes profile docs
- exported profile examples if obtainable

### A4. Topology-like multi-agent assets

Collect:

- multi-agent workflow layouts
- role graphs
- task routing structures
- approval/review/commit style agent configurations

Why:

- topology is part of the planned shareable object
- this is currently the least standardized part and needs the strongest empirical grounding

Initial sources:

- open multi-agent repos
- public agent workflow patterns
- examples from coding-agent ecosystems where roles are explicit

### A5. Capture/provenance assets

Collect:

- Entire checkpoint branch examples
- commit trailers and linked metadata examples
- session metadata schemas
- trace logs and checkpoint payload references

Why:

- these define the strongest real-world reference for Git-native capture and lineage

Initial sources:

- `entireio/cli`
- Entire docs and example data layouts

### A6. Skill engineering / packaging assets

Collect:

- validation workflows
- skill publication workflows
- registration/symlink patterns
- safety/security scan rules

Why:

- this is the strongest reference for turning "skill as code" into an engineered artifact

Initial sources:

- `motiful/skill-forge`
- Agent Skills validation tooling

### A7. Hosted Git product assets

Collect:

- repo management features
- package/registry feature boundaries
- issue/PR/review semantics
- storage and deployment topology examples

Why:

- these ground the hosted/local management side of the product

Initial sources:

- Gitea docs
- Gitea deployment/database guidance

### A8. Synthetic workload assets

Collect or generate:

- representative fake skills
- fake profiles
- fake topology bundles
- fake checkpoints/traces
- large enough batches to stress export/import/search flows

Why:

- real assets are necessary but not sufficient
- synthetic assets are needed to test scale, edge cases, and incomplete data

## Section B - Mock boundaries

### B1. Mock share registry / package source

Mock:

- package discovery
- version listing
- package fetch
- manifest lookup

Why first:

- package/share logic can be synthesized without depending on final GitHub/Gitea integration

### B2. Mock runtime event stream

Mock:

- skill activation
- profile selection
- topology activation
- channel events
- candidate checkpoint events

Why first:

- lets us design capture normalization without being blocked by live runtime coupling

### B3. Mock checkpoint/blob backend

Mock:

- blob references
- checkpoint payload lookup
- internal trace persistence
- lineage attachment to durable metadata

Why first:

- lets us design metadata semantics separately from final storage implementation

### B4. Mock hosted management API

Mock:

- asset listing
- package inspection
- lineage inspection
- export actions
- share/publish actions

Why first:

- allows the product surface to exist before choosing final hosted architecture

### B5. Mock topology activation boundary

Mock:

- loading a `skill + profile + topology` bundle
- reporting available agents/channels
- reporting structure and entry points

Why first:

- topology is one of the least standardized parts and needs a stable synthetic interface while semantics settle

## Section C - Boundaries that should stay real early

These should remain real early, even if other parts are mocked:

### C1. Agent Skills format

Reason:

- this is already a public standard
- mocking it would only increase confusion

### C2. Git semantics

Reason:

- provenance and lineage depend on real Git branch/ref/commit meaning
- we can abstract implementations, but not the semantics

### C3. At least one Hermes integration path

Reason:

- otherwise the project risks drifting into a mock-only universe
- we need one real host/runtime connection early enough to keep the work honest

## Section D - Order of research collection

Recommended first-wave collection order:

1. public skill assets
2. capture/provenance assets
3. skill engineering / packaging assets
4. profile-like runtime assets
5. topology-like multi-agent assets
6. hosted Git product assets
7. synthetic workload assets

## Section E - Immediate outputs this research should support

This research should enable:

- a stable vocabulary for product vs synthesis
- a sharper MoonBit-native candidates matrix
- a future `ralplan` that is grounded in real asset classes
- a clearer split between:
  - what to reuse directly
  - what to wrap
  - what to synthesize ourselves

## Section F - Questions this document should answer next

The next revision of this document should aim to answer:

- which concrete repositories or datasets will be used as first-wave test assets
- which mock boundaries can be implemented with the least ambiguity
- which part of the hosted/local product surface is required first to make the software feel whole
