# Phase Ordering When We Need All Four Centers

## Premise

The current conclusion is not:

- choose only one center

The current conclusion is:

- we need all four

Those four are:

1. `Git-native provenance substrate`
2. `shareable asset/package system`
3. `capture/extraction pipeline`
4. `hosted/local product surface`

So the real design question becomes:

- what depends on what
- what must exist first
- what can stay thin in phase 1 without breaking the product story

## Best-practice interpretation

If all four are required, phase planning should not force an artificial winner.

Instead:

- identify the deepest dependency layer
- identify the smallest credible vertical slice
- ensure the slice already demonstrates the full product direction

That means phase 1 should **include all four**, but not at equal depth.

## Dependency view

### 1. Git-native provenance substrate

This is the deepest durable layer.

It provides:

- identity
- lineage
- checkpoint metadata
- branch/ref semantics
- durable linkage between internal capture and external artifacts

Without it:

- the project risks becoming a loose toolchain
- hosted/local surfaces lose durable meaning
- extraction outputs lack trustworthy provenance

### 2. Shareable asset/package system

This sits directly on top of provenance.

It provides:

- the external object users share
- the reproducible package around `skill + profile + topology`
- validation and compatibility boundaries

Without it:

- the product has nothing stable to share
- hosted/local surfaces become only dashboards around runtime state

### 3. Capture/extraction pipeline

This links internal work to future assets.

It provides:

- structured internal records
- normalization from runtime/session activity
- future `trace/checkpoint -> asset` paths

Without it:

- the project becomes a static package manager
- the `Entire`-inspired and synthesis-heavy part disappears

### 4. Hosted/local product surface

This is the human-facing software identity layer.

It provides:

- management
- browsing
- review
- export/share actions
- local/self-hosted/cloud growth path

Without it:

- the project risks collapsing into infrastructure only
- the software-synthesis story becomes much weaker

## Ordering recommendation

### Phase 1 depth priority

All four should exist in phase 1, but with different depth:

1. `Git-native provenance substrate` — deepest
2. `shareable asset/package system` — deep
3. `capture/extraction pipeline` — thin but real
4. `hosted/local product surface` — thin but real

## Why this order

### Why provenance first

Because it anchors:

- internal capture
- exported packages
- future hosting semantics

It is also one of the strongest MoonBit-native story opportunities.

### Why package system second

Because the product must have a stable external object early.

If `skill + profile + topology` is not concretely packaged, then:

- sharing is vague
- reproduction is vague
- hosted/local UX becomes fake

### Why capture/extraction third

Because it must exist for the product to feel alive, but phase 1 only needs:

- one real normalized capture path
- one real lineage link into provenance
- one real path toward future extracted assets

It does not need full-scale autonomous `trace2skill` optimization yet.

### Why surface fourth

Because it must exist for product identity, but phase 1 only needs a credible thin slice:

- list or inspect assets
- show topology/relations
- trigger capture/export/share actions

It does not need a polished full hosted suite yet.

## Recommended phase-1 slice

The smallest credible phase-1 slice should prove:

1. Hermes runs the real runtime
2. our thin Hermes adapter can observe or connect the relevant path
3. internal activity creates normalized capture records
4. those records attach to a MoonBit-native provenance model
5. a shareable package for `skill + profile + topology` can be materialized
6. a thin local or hosted surface can inspect and export it

## What phase 1 does not need

- full cloud-native deployment system
- full registry/marketplace
- full analytics database
- complete autonomous extraction quality loop
- general-purpose replacement for Gitea
- complete replacement for Hermes runtime orchestration

## Suggested implementation lanes

### Lane A — Provenance + package core

Primary MoonBit lane.

Includes:

- lineage model
- checkpoint metadata model
- package manifest for `skill + profile + topology`
- validation
- Git-native persistence/materialization path

### Lane B — Thin capture path

Bridges runtime events into normalized internal records.

Includes:

- one Hermes-connected event path
- one checkpoint/capture linkage path
- one extraction-ready internal representation

### Lane C — Thin local/hosted surface

Provides product identity early.

Includes:

- inspect package
- inspect topology
- inspect lineage
- trigger export/share

### Lane D — Hermes adapter shell

Host-specific, intentionally thin.

Includes:

- plugin/library connection to Hermes
- minimal translation into our internal substrate

## Main judgment

If we truly need all four, then phase 1 should not be framed as "pick one center".

It should be framed as:

`build one coherent vertical slice where provenance is deepest, packaging is real, capture exists, and the surface is thin but undeniable`

## Next OMX question

The next decision should therefore be:

- what is the exact minimum proof path for that vertical slice?

More concretely:

- what is the first concrete event that enters capture,
- gets lineage,
- becomes packageable,
- and is visible in the local/hosted surface?
