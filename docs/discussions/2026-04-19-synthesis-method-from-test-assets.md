# Synthesis Method from Test Assets

## Why this note exists

The recent discussion exposed an important correction:

- the project should not be framed around a "minimum proof path"
- the team wants to synthesize the software from collected test assets and controlled mocks

So this note separates two things that were getting mixed together:

1. `the product subject`
2. `the synthesis method`

## 1. Product subject

The product subject is still the software we are building:

- capture
- provenance
- shareable asset/package system
- hosted/local management surface

This is the thing the competition entry will be judged as software.

## 2. Synthesis method

The synthesis method is how we build and validate that software:

- collect test assets from open-source projects
- study strong adjacent systems such as Entire, skill-forge, Gitea, Hermes, and Agent Skills adopters
- build mock servers and mock runtimes where direct integration is too costly or unstable
- use those assets and mocks to force the software into a complete, self-consistent design

This is not the product itself.

It is the way we derive and pressure-test the product.

## Core correction

The phrase "minimum proof path" is misleading for this project.

A better phrase is:

`minimum synthesis loop`

That loop is not about proving a philosophy.
It is about making the software emerge from realistic assets and interfaces.

## Best-practice synthesis loop

### Step 1: Collect test assets

Collect representative assets from real open-source ecosystems:

- skills
- profile-like runtime configs
- topology-like multi-agent or workflow structures
- checkpoints / traces / session records where available
- Git-native metadata and publishing examples

The point is not just inspiration.
The point is to get realistic inputs that will stress the software.

### Step 2: Classify assets

Classify them into:

- directly reusable standards
- host/runtime-specific artifacts
- internal-only artifacts
- external shareable artifacts
- derived artifacts

This prevents the design from collapsing into one format that tries to hold everything.

### Step 3: Build mock servers and controlled adapters

Where real integration is unstable, expensive, incomplete, or host-coupled:

- create mock servers
- create mock registry responses
- create mock checkpoint stores
- create mock topology activation endpoints
- create fake or replayable Hermes-facing surfaces

The purpose is not to avoid reality.
The purpose is to isolate the software we are synthesizing from moving host dependencies.

### Step 4: Synthesize substrate from those assets

Use the collected assets plus the mocks to derive:

- provenance model
- package/export model
- capture model
- extraction model
- hosted/local management model

This is where MoonBit should likely do the real work.

### Step 5: Rebind to real host/runtime surfaces

After the substrate is coherent:

- reconnect it to Hermes
- reconnect it to GitHub/Gitea
- reconnect it to real storage backends

This ensures the final software is not just a mock-only toy.

## What should be mocked first

Based on the discussion so far, the most reasonable early mocks are:

### Mock registry / share source

Simulate:

- GitHub-hosted share objects
- package discovery
- versioned package fetch

Why:

- lets us test package/export and management logic before full hosted integration

### Mock runtime event source

Simulate:

- skill activation
- profile selection
- topology activation
- channel events
- checkpoint-worthy events

Why:

- lets us design capture and provenance cleanly without being blocked on live Hermes behavior

### Mock checkpoint / blob backend

Simulate:

- internal trace storage
- checkpoint payload references
- lineage attachment

Why:

- lets us separate metadata semantics from storage implementation details

## What should still stay real early

Even in a synthesis-heavy workflow, some things should stay real early:

- the public Agent Skills format
- Git semantics
- at least one real Hermes integration path

Otherwise the software risks drifting into an artificial mock universe.

## MoonBit implications

This synthesis method actually strengthens the case for MoonBit.

Why:

- MoonBit can implement the structured substrate while mocks stabilize the boundary
- MoonBit does not need to own every volatile host detail on day one
- MoonBit-native provenance, packaging, validation, and extraction become easier to isolate and test

## Main judgment

The project should be discussed using two parallel tracks:

### Product track

What software are we building?

- provenance
- package/share
- capture/extraction
- hosted/local management

### Synthesis track

How are we building it?

- collect test assets from real open-source projects
- use mock servers and controlled runtime mocks
- derive substrate semantics from those assets
- reconnect to real systems later

## Next OMX focus

The next useful discussion is therefore not:

- "what is the minimum proof path?"

It is:

- `which asset classes must we collect first, and which boundaries should be mocked first, so the software can be synthesized coherently?`
