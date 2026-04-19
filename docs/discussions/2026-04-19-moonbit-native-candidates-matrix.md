# MoonBit-Native Candidates Matrix

## Purpose

This note turns the architecture research into a practical OMX decision slate.

The question is not:

- should everything be implemented in MoonBit?

The question is:

- which parts should be reused directly
- which parts should be hybrid
- which parts should be MoonBit-native to make the software both stronger and more convincing as a competition artifact

## Decision heuristic

Use an existing substrate directly when:

- it is already a good open standard or mature runtime
- reimplementation would mostly duplicate infrastructure
- direct reuse does not weaken the coherence of the final software

Prefer MoonBit-native implementation when:

- MoonBit gives a real implementation advantage
- MoonBit makes the story stronger and clearer
- the part is central to the originality of the software
- leaving it external would make the project feel stitched together

Avoid:

- forcing MoonBit into host/runtime boundaries it does not naturally own
- trimming the system down into a narrow demo that only fits the current scenario

## Matrix

| Component | Role in system | Reuse / Hybrid / MoonBit-native | Current best judgment | Why |
| --- | --- | --- | --- | --- |
| `Agent Skills` standard | public definition of skill directory shape and metadata | Reuse | Reuse directly | already an open standard; inventing a conflicting concept weakens the project |
| `Hermes runtime` | actual agent/profile/session execution host | Reuse | Reuse directly | Hermes already owns runtime orchestration, profiles, skills, gateway/session machinery |
| `Hermes plugin shell` | integration surface into Hermes | Hybrid | Thin host-specific shell | must be written by us, but should stay thin and runtime-specific |
| `skill + profile + topology` shareable package model | external reproducible artifact | MoonBit-native | Strong MoonBit candidate | this is close to product identity and needs strong typed structure and validation |
| provenance metadata model | links internal capture to durable lineage | MoonBit-native | Strong MoonBit candidate | one of the clearest originality surfaces |
| checkpoint branch format | durable Git-native metadata storage | MoonBit-native | Strong MoonBit candidate | directly supports the provenance story |
| capture normalization | convert runtime events into structured internal records | MoonBit-native | Strong MoonBit candidate | central to extraction and durable replay/analysis |
| `trace/checkpoint -> asset` extraction | derive reusable assets from internal work | MoonBit-native | Strong MoonBit candidate | one of the most product-defining capabilities |
| topology normalization and validation | keep multi-agent structure shareable and reproducible | MoonBit-native | Strong MoonBit candidate | well-suited to typed package boundaries and validation |
| Git hosting | remote repo distribution and collaboration | Reuse | Reuse directly | GitHub/Gitea already solve this well |
| Git object semantics | commits, refs, branches, pack semantics | Reuse | Reuse as standard semantics | not a place to invent a new model |
| Git provenance implementation | metadata branch writing, repo materialization, export publishing | Hybrid | MoonBit-native main path + compatibility fallback | very strong MoonBit story, but pragmatic fallback should exist |
| `mizchi/git` path | MoonBit-native Git substrate | MoonBit-native | preferred main path where feasible | maximizes originality and competition story |
| `mizchi/libgit2` path | native Git integration fallback | Hybrid | compatibility lane | good fallback for operations not yet covered cleanly in MoonBit-native Git |
| blob/object store | store large internal artifacts not meant for default sharing | Hybrid | likely needed in phase 1 | internal capture needs durable storage separate from default shareable package |
| analytical/query DB | search, mining, dashboards, analytics | Hybrid | optional later | useful, but not core to phase-1 product identity |
| DuckDB specifically | local analytical engine | Hybrid | not primary operational store | strong analysis layer, weak default fit for multi-user operational control plane |
| local product surface | local management/consumption software | MoonBit-native or Hybrid | likely part of product identity | if omitted, the software risks collapsing into infrastructure only |
| hosted product surface | self-hosted/cloud management and sharing software | MoonBit-native or Hybrid | likely part of product identity | this is where the software stops being “just a library” |

## Top-tier MoonBit-native candidates

These are the strongest current candidates for "must feel MoonBit-native":

1. `provenance + checkpoint metadata substrate`
2. `shareable package model around skill + profile + topology`
3. `capture normalization + extraction pipeline`
4. `Git-native materialization/publishing path`
5. `topology/profile validation and normalization`

## Top-tier reuse candidates

These are the strongest current candidates for direct reuse:

1. `Agent Skills` public standard
2. `Hermes` runtime host
3. `GitHub/Gitea` remote Git hosting

## Top-tier hybrid candidates

These are the strongest current candidates for hybrid treatment:

1. `Hermes plugin shell`
2. `Git implementation details`
3. `blob/object storage`
4. `hosted/local surface if some infrastructure is borrowed`

## Current best overall split

### Reuse

- `Agent Skills`
- `Hermes`
- `GitHub/Gitea`

### Hybrid

- Hermes-facing integration shell
- Git implementation fallback path
- object storage implementation details

### MoonBit-native center

- provenance
- checkpoint lineage
- shareable asset/package model
- topology/profile structure
- capture normalization
- extraction from internal traces toward external assets

## Main unresolved decision

The most important unresolved question is now narrow enough to ask directly:

If the competition story can only emphasize one MoonBit-heavy center first, should it be:

1. `Git-native provenance substrate`
2. `shareable asset/package system`
3. `capture/extraction pipeline`
4. `hosted/local software built on top of the above`

The answer should be chosen based on:

- originality
- technical credibility
- relevance to the actual software subject
- how complete and self-consistent the resulting product can feel
