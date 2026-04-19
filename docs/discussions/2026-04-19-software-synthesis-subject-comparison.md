# Software Synthesis Subject Comparison

## Why this exists

This note tries to answer one question more directly:

What is the real software-synthesis subject of this project?

The discussion so far established that the answer is **not** "Hermes runtime orchestration by itself".
Hermes remains the first runtime host, but the competition artifact must center on the software we build around:

- capture
- provenance
- asset extraction
- sharing
- hosting
- reproducibility

## Reference systems and what they actually contribute

## License snapshot

This section is only a first-pass compatibility note, not legal advice.

### Entire CLI

- Repository: `entireio/cli`
- Observed license: `MIT`
- Practical implication:
  - the CLI code appears reusable under MIT terms
  - preserve copyright and license notice if copying substantial code
  - borrowing the strategy is lower-risk than copying implementation wholesale

### Skill Forge

- Repository: `motiful/skill-forge`
- Observed license: `MIT`
- Practical implication:
  - the repository appears reusable under MIT terms
  - preserve copyright and license notice if copying substantial code
  - methodology and workflow ideas are easy to borrow
  - direct code reuse is possible in principle, but product scope still differs

### Gitea

- Repository: `go-gitea/gitea`
- Observed repository license: `MIT`
- Practical implication:
  - the project is open source and broadly reusable
  - direct code reuse is legally possible in principle, but technically heavy
  - for this project, borrowing product shape and deployment model is likely more realistic than copying large code sections

### Agent Skills standard

- `Agent Skills` is presented as an open standard
- Practical implication:
  - we should align with the standard rather than invent a conflicting skill concept
  - our originality should be in capture, packaging, topology, provenance, hosting, and extraction around skills

### Entire

What Entire contributes conceptually:

- full-session capture during work
- temporary local checkpoints during active sessions
- permanent checkpoint metadata only when commits happen
- explicit Git linkage between commits and checkpoints

What to borrow:

- capture/provenance strategy
- clean separation between local temporary state and durable synced metadata
- Git-native lineage thinking

What not to copy blindly:

- Entire is centered on code-session explainability
- our project is centered on shareable agent assets and reproducible multi-agent work shapes

### Skill Forge

What Skill Forge contributes conceptually:

- skills are engineered artifacts, not just ad hoc prompt files
- structure validation matters
- security scanning matters
- registration/installability matters
- publishing/distribution matters
- GitHub is a real substrate for skill distribution

What to borrow:

- post-authoring engineering pipeline
- packaging, validation, security, and publishing discipline
- the stance that "skills are code"

What not to copy blindly:

- Skill Forge focuses on engineering and publishing skills
- our project must also manage runtime-linked structure, capture, extraction, and hosted sharing

### Gitea

What Gitea contributes conceptually:

- self-hosted Git collaboration surface
- repository management and pull/merge workflow
- API-first service model
- low-resource, practical Git hosting
- a realistic path for self-hosted sharing infrastructure

What to borrow:

- hosted repo/registry mindset
- Git-first sharing and management surface
- local/self-hosted/cloud-deployable product framing

What not to copy blindly:

- Gitea is a general Git hosting system
- our project needs domain-specific capture, extraction, and agent-asset semantics

## Current best understanding of the project center

The product center is most likely a combination of these three concerns:

1. Git-native capture and provenance for agent work
2. engineered, shareable agent assets
3. hosted or local software for managing and reproducing those assets

In other words:

- Hermes runs agents
- the Hermes plugin connects our system to Hermes
- our software is the substrate that captures, structures, extracts, stores, shares, and reproduces agent assets

## What seems to be the competition artifact

The strongest current candidate is:

`a MoonBit-built Git-native substrate for capture, provenance, engineered agent assets, and hosted/local reproduction`

This is stronger than:

- "just a Hermes plugin"
- "just a skill publisher"
- "just a checkpoint viewer"

because it combines:

- internal capture
- asset extraction
- external shareability
- hosted/local product surface

## Asset model currently implied by discussion

### Internal layer

Internal artifacts may include:

- session
- trace
- checkpoint
- commit-linked metadata
- intermediate derived assets

These are valuable even when not shared externally, especially for:

- attribution
- replay
- debugging
- future `trace -> skill` or related extraction flows

### External shareable layer

The default external shareable package currently converges on:

- `skill`
- `profile`
- `topology`

The default external package should not include:

- raw trace
- tmux state
- in-flight runtime context
- checkpoint internals by default

Success of sharing means another person can reproduce the core experience by running the same `skill/profile/topology`, not replaying the exact original process.

## Implications for MoonBit

MoonBit should matter in the part that is truly ours.

The most promising places for MoonBit to be central are:

- provenance and Git-native metadata logic
- asset packaging and validation
- topology/profile/shareability checks
- capture normalization
- extraction pipelines from internal traces toward external assets
- local/hosted substrate logic

MoonBit is less likely to be the best place for:

- the Hermes host plugin shell itself, if Hermes expects a different plugin runtime

That integration shell can stay thin.

## Reuse vs implement heuristic

The discussion now converges on a practical rule instead of an ideological one.

### Reuse directly when

- an existing open standard already models the thing well
- an existing open-source substrate is already strong and appropriate
- reimplementing it would mostly duplicate solved infrastructure
- the reused component does not weaken the coherence of the final software

Examples likely in this category:

- the public `Agent Skills` concept itself
- Hermes as the first runtime host
- GitHub/Gitea as real Git hosting substrates

### Implement ourselves when

- MoonBit gives a real advantage in implementation quality, portability, or explainability
- MoonBit-native implementation makes the software story clearly stronger
- the part is central to the originality of the competition artifact
- direct reuse would leave the system feeling stitched together rather than self-consistent

Examples likely in this category:

- Git-native provenance logic if it is central to the product
- capture normalization and asset extraction logic
- topology/profile/shareability validation
- the hosted/local substrate logic that gives the project its own identity

### Important guardrail

The goal is not to trim the system down until it only fits our immediate scenario.

The software should remain complete and self-consistent:

- not a thin demo hack
- not a pile of borrowed tools with weak integration
- not a special-case workflow that only works for one narrow path

The strongest competition path is therefore:

- reuse what is already genuinely standard or infrastructural
- implement what becomes better, clearer, and more defensible under MoonBit
- keep the final software whole enough to stand as a real product direction

## Git decision

If Git/provenance is part of the competition subject, Git should not be treated as a black box.

Current recommendation:

- prefer MoonBit-native Git capability for the product's real provenance path
- keep C/libgit2 binding as a fallback or compatibility path

More concretely:

- `mizchi/git` looks promising for packfile, index, metadata writing, and repo materialization
- `mizchi/libgit2` looks promising as an integration fallback when direct native Git coverage is missing

Recommended stance:

- main path: MoonBit-native Git where it expresses the product's originality
- fallback path: `libgit2` binding where pragmatic host integration is needed

## Storage decision

### Blob store

Blob/object storage looks necessary.

Reason:

- internal capture will include larger artifacts and runtime-linked material
- those should not all live inside the default shareable package
- they still need durable storage

Phase 1 can use local filesystem-backed blob storage if needed.

### DuckDB

DuckDB does not currently look mandatory for phase 1.

Reason:

- the first need is durable capture + linkage + export
- not analytical querying at scale
- query/analytics requirements may emerge later

Current stance:

- blob storage: likely yes
- DuckDB: optional unless query-heavy workflows become central

## Critical unresolved question

The biggest unresolved issue is no longer "do we need a core?"

It is:

`Which part of the substrate is the actual primary artifact we want to win the competition with?`

The best current candidates are:

1. capture + provenance substrate
2. engineered shareable asset system
3. hosted/local management and sharing software
4. all three together, if a coherent first slice can show them at once

## Next discussion focus

The next discussion should compare these candidate centers explicitly:

- If the main subject is capture/provenance, what must be implemented in MoonBit?
- If the main subject is shareable assets, what must go beyond Skill Forge?
- If the main subject is hosted/local software, what must go beyond Gitea-like hosting?
- If the main subject is "test assets can be generated at scale", which layer owns that pipeline?
