# Topology Defaults and Test-Asset Priority

## Status

- `working-default`
- intended as a practical interview conclusion for later planning

## Purpose

This note records a default decision that reduces interview uncertainty without pretending every topology question is fully settled.

It exists because the project already has stronger concrete material for:

- `skill` assets
- provenance / checkpoint metadata assets

but still has a weaker and more ambiguous story for:

- `topology`
- profile-like runtime binding assets

The goal is to give later planning and test-asset collection a usable default.

## Input that motivated this note

Recent clarification established two important constraints:

- the project should not force one fixed topology for all users
- the system should allow built-in coordination patterns, parameterized variants, and fully custom or hybrid graphs

Anthropic's `2026-04-10` article `Multi-agent coordination patterns: Five approaches and when to use them` is useful here as a pattern vocabulary rather than a product law.

The five pattern families are:

- `generator-verifier`
- `orchestrator-subagent`
- `agent teams`
- `message bus`
- `shared state`

The article's practical guidance also fits this repo well:

- start with the simplest coordination shape that works
- treat patterns as composable building blocks
- evolve only when the simpler shape becomes a real bottleneck

## Working default

For this repository, `topology` should default to a structural coordination object.

That means:

- it describes how roles/agents relate
- it describes how work or findings move
- it describes how a run begins and ends
- it does **not** default to carrying host-runtime, session, or provider details

This default preserves user flexibility without collapsing all concerns into one file or type.

## Three supported topology sources

The project should assume all three are legitimate:

### 1. Built-in pattern templates

Examples:

- a stock `generator-verifier` layout
- a stock `orchestrator-subagent` layout
- a stock `shared-state` layout

### 2. Parameterized pattern instances

Examples:

- a verifier loop with custom acceptance criteria
- an orchestrator pattern with user-defined specialist roles
- a message-bus pattern with custom topics and trigger rules

### 3. Custom or hybrid topologies

Examples:

- `orchestrator-subagent` plus a shared scratchpad
- `message bus` for event routing plus `generator-verifier` for quality gates
- a graph that does not fit any single named pattern cleanly

## Layer split

### Topology

Owns:

- structural roles or nodes
- edges or coordination links
- entrypoints
- termination conditions
- shared artifact/state surfaces in abstract form
- coordination invariants such as review or approval requirements

### Profile

Owns:

- model/provider/runtime binding
- tool availability
- environment assumptions
- host-specific execution preferences

### Runtime state

Owns:

- live session ids
- transient channels
- trace logs
- checkpoints
- in-flight working context

### Provenance

Owns:

- durable lineage
- commit/checkpoint linkage
- exported history and materialization references

## Minimum common structure for topology

The first useful common shape should stay small and structural.

Recommended minimum fields:

- `topology_id`
- `version`
- `pattern_kind`
- `nodes`
- `edges`
- `entrypoints`
- `termination_conditions`
- `shared_surfaces`
- `invariants`

### Recommended node meaning

Each node should be able to express at least:

- stable id
- role or responsibility
- optional capability label

### Recommended edge meaning

Edges should be able to express at least:

- handoff
- review/approve
- publish/subscribe
- read/write shared surface

### Recommended termination meaning

Termination must be first-class, especially for `shared-state` and `message-bus` shapes.

Examples:

- verifier accepted output
- queue drained
- no new findings for `N` cycles
- coordinator emitted final artifact
- human approval reached

## What should stay outside topology by default

Do not put these in topology unless later planning proves they truly belong there:

- model names
- provider credentials
- sandbox or machine details
- host install locations
- live session ids
- raw trace payloads
- checkpoint blobs
- UI view state
- user-specific ephemeral preferences

These belong more naturally to:

- `profile`
- `runtime state`
- `provenance`
- control-plane UI logic

## Consequence for test-asset collection

The next test-asset gap is not generic "more assets."

The next gap is:

- a topology corpus with enough range to stress the structure layer

That corpus should treat Anthropic's five coordination patterns as the first mother set, then add one explicit custom/hybrid class.

## First-wave topology corpus classes

### A. `generator-verifier`

Why collect:

- exercises explicit evaluation loops
- forces acceptance criteria and retry termination to be modeled cleanly

### B. `orchestrator-subagent`

Why collect:

- best default baseline for many practical systems
- likely the first useful shape for this repo's later execution planning

### C. `agent teams`

Why collect:

- stresses persistent workers, work partitioning, and conflict boundaries

### D. `message bus`

Why collect:

- stresses event topics, routing, and decoupled flow

### E. `shared state`

Why collect:

- stresses collaboration through shared findings rather than explicit routing
- especially relevant when synthesis work accumulates knowledge over time

### F. `custom/hybrid`

Why collect:

- prevents the product from assuming the five named patterns are exhaustive
- captures the user-customization requirement directly

## What to record for each topology asset

Each first-wave topology sample should record:

- source or inspiration
- pattern family
- why it is included
- node list
- edge types
- entrypoint shape
- termination rule
- shared surface assumptions
- what was intentionally left to `profile`
- what was intentionally left to runtime state

## Collection priority

Recommended first collection order:

1. `orchestrator-subagent`
2. `generator-verifier`
3. `shared state`
4. `message bus`
5. `agent teams`
6. `custom/hybrid`

Reasoning:

- `orchestrator-subagent` is the most reusable practical baseline
- `generator-verifier` is small and crisp, which makes it a good schema-stress sample
- `shared state` exposes the hardest termination and collaboration questions early
- `message bus` and `agent teams` matter, but they can follow after the baseline structure is proven
- `custom/hybrid` should be collected once the primitive vocabulary is stable enough to combine

## Immediate planning consequence

Later `ralplan` should treat the following as a safe working assumption:

- freeze `topology` as a structure layer first
- keep runtime/provider detail in `profile`
- keep traces/checkpoints out of the external shareable package by default
- collect topology samples as pattern-shaped assets before trying to finalize the package manifest

## Deferred questions

This note does **not** settle:

- the final serialized manifest format
- whether topology is stored as a graph schema, declarative workflow, or both
- the exact profile schema
- the exact runtime activation API
- the exact checkpoint metadata branch format

Those are still planning questions.

## Main judgment

The most useful interview conclusion is not "decide one topology."

It is:

- treat topology as the structure layer
- allow template, parameterized, and custom/hybrid forms
- use the five Anthropic coordination patterns as the first topology corpus baseline
- continue keeping runtime binding and ephemeral execution state outside topology by default
