# Seed Mock Boundaries

## Purpose

This note records the first mock boundaries suggested by the current CLI-based source inspection.

These mocks are not meant to replace reality.

They are meant to:

- isolate unstable or host-heavy integration points
- let the MoonBit substrate be designed cleanly
- preserve at least one real path to standards and host semantics

## Keep real early

The following should stay real early:

- Agent Skills format and baseline invariants
- Git semantics
- at least one Hermes integration path

## Mock boundary 1 - Share registry / package source

### Why mock

- package/share logic should not wait on final GitHub/Gitea integration

### What to simulate

- package discovery
- version listing
- manifest lookup
- package fetch

### Real source influence

- GitHub skill distribution patterns
- skill-forge publish/install flow
- GitHub Docs agent-skill client expectations

### Quality

- `A-`
- early mock is low-risk and high-value

## Mock boundary 2 - Runtime event stream

### Why mock

- real runtime event integration is host-coupled and likely noisy

### What to simulate

- skill activation
- profile selection
- topology activation
- channel events
- candidate checkpoint triggers

### Real source influence

- Hermes gateway/session/profile/plugin surfaces

### Quality

- `A`
- this is one of the most useful early mocks

## Mock boundary 3 - Checkpoint/blob backend

### Why mock

- we want to separate metadata semantics from final storage implementation

### What to simulate

- checkpoint payload references
- blob lookups
- trace storage handles
- lineage attachment

### Real source influence

- Entire checkpoint branch and session/checkpoint split

### Quality

- `A`
- central to the provenance story

## Mock boundary 4 - Hosted/local management API

### Why mock

- hosted product shape is important, but final architecture is still undecided

### What to simulate

- asset listing
- lineage inspection
- package inspection
- export/share actions

### Real source influence

- Gitea product shape
- GitHub client-facing skill distribution assumptions

### Quality

- `A-`
- strong for early interface work, but final hosted architecture still open

## Mock boundary 5 - Topology activation interface

### Why mock

- topology is the least standardized object in the current design

### What to simulate

- loading a `skill + profile + topology` bundle
- returning agent/channel graph info
- returning activation entrypoints
- returning visible interaction surfaces

### Real source influence

- multi-agent workflow proxies
- Hermes runtime semantics

### Quality

- `A-`
- very important, but source grounding is still less mature than skills or provenance

## Boundary split rule

The general split should be:

- keep standards real
- keep one host path real
- mock unstable service and integration boundaries

This gives us:

- honest semantics
- clean substrate design
- less coupling to unfinished product choices

## Immediate next action

The next iteration should define:

- one example request/response shape for each mock boundary
- what internal MoonBit layer each mock talks to
