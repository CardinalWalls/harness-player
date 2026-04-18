# PRD - Asset-Centric Control Plane

- Status: `approved-draft`
- Source: `.omx/plans/prd-asset-centric-control-plane.md`
- Last-Mirrored-From: `2026-04-19`

## Problem

Current agentic content-play setups overload one live context with execution, observation, narration, human input, and reflection. The result is noisy interaction, weak asset capture, and poor reuse.

## Product thesis

Build a MoonBit-centered, runtime-agnostic control plane that wraps content sources into sessions, channels, and projections, while treating durable assets, especially `skill`, as the true first-class product.

## Primary user

- A human operator working with their own agent runtime
- Hermes is the first runnable reference, not the exclusive target

## Core value

- Turn messy live interaction into reusable, shareable, inspectable assets
- Keep runtime and protocol assumptions light
- Preserve provenance across skills, checkpoints, stories, and related artifacts

## First release goal

Prove one end-to-end loop where a content source is wrapped, information flows are observable and routable, a human can intervene, and at least one durable asset event is captured with inspectable provenance.

## First release defaults

- Reference runtime: Hermes
- First proof content source: a simpler skill-corpus or document-derived content source before CDDA
- Persistence split:
  - Git stores docs, skill artifacts, commit metadata, and provenance-facing refs
  - blob storage stores large snapshots or replay payloads
  - adapters own live external runtime state and publish snapshot references into provenance
- Thin control surface:
  - local web-first surface
  - projection list
  - targeted input box
  - commit and checkpoint actions

## In scope

- Kernel/control-plane primitives for session-based content flows
- Asset-centric lifecycle with `skill` as a first-class durable unit
- One runnable reference integration path
- One reference content source path
- Thin human control surface
- Provenance and history for asset creation

## Out of scope

- Solving high-quality autonomous gameplay
- Polished final frontend
- Heavy A2A or IRC-style core protocol
- Hermes-only architecture
- Fixed kernel roles or fixed planes

## Release proof checklist

1. Attach a reference runtime without hardcoding runtime-specific roles into kernel concepts.
2. Wrap one content source and expose at least one execution channel plus one derived projection.
3. Allow a human to route at least one control input cleanly.
4. Produce at least one durable asset event:
   - checkpoint
   - story commit
   - skill commit
5. Persist it with inspectable lineage.

## Deferred implementation decisions

- Exact document-to-skill ingestion pipeline for the first proof content source
- Exact blob storage backend behind the provenance layer
- Exact rendering details of the thin local web surface
