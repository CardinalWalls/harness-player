# Architecture Research Report - MoonBit Competition Direction

## Goal

This report answers the practical question behind the current OMX discussion:

- what the real software-synthesis subject likely is
- what should be reused directly
- what should be implemented in MoonBit
- how to think about Git, provenance, hosting, extraction, and distribution
- how `Entire`, `skill-forge`, `Gitea`, `Hermes`, and the public `Agent Skills` standard should influence the design

This is an engineering report, not legal advice.

## Executive summary

### Best current judgment

The competition subject should **not** be framed as:

- "a Hermes plugin"
- "a skill format"
- "a clone of Entire"
- "a clone of Gitea"

The strongest framing is:

`a MoonBit-built substrate for capturing, structuring, sharing, and reproducing agent software assets around skill + profile + topology, with Hermes as the first host runtime and Git as the first provenance substrate`

### What to reuse directly

- `Agent Skills` as the public skill concept and compatibility surface
- `Hermes` as the first host runtime
- `GitHub` / `Gitea` as real Git hosting substrates
- existing open-source references such as `Entire` and `skill-forge` as design input

### What to implement ourselves

- provenance semantics and checkpoint metadata strategy as it applies to our product
- the shareable asset model around `skill + profile + topology`
- the hosted/local management software around those assets
- capture normalization and extraction flows from internal traces toward external assets
- the Git-native substrate where MoonBit makes the story materially better

### Main recommendation

Use a **hybrid build-vs-reuse strategy**:

- reuse existing standards and host runtimes where they are already strong
- implement the originality-critical substrate in MoonBit
- avoid producing a stitched-together demo that only works for the current narrow scenario

## Facts from authoritative sources

### 1. Agent Skills is a public open standard

Evidence:

- Agent Skills describes itself as "a simple, open format"
- skills are directories containing `SKILL.md` and optionally `scripts/`, `references/`, and `assets/`
- the format includes `compatibility`, `metadata`, and optional `allowed-tools`

Sources:

- [Agent Skills overview](https://agentskills.io/home)
- [Agent Skills specification](https://agentskills.io/specification)

Implication:

- we should not invent a conflicting definition of `skill`
- our originality should live around capture, packaging, topology, provenance, hosting, and extraction

### 2. Hermes already supports skills, profiles, plugins, gateway-style channels, and open skills

Evidence:

- Hermes skills follow the `agentskills.io` standard
- Hermes stores skills in `~/.hermes/skills/`
- Hermes has profile commands and profile import/export
- Hermes has an official plugin guide
- Hermes documentation frames itself as a host runtime with messaging gateway, skills, profiles, tools, memory, and sessions

Sources:

- [Hermes docs home](https://hermes-agent.nousresearch.com/docs/)
- [Skills System](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills)
- [Build a Hermes Plugin](https://hermes-agent.nousresearch.com/docs/guides/build-a-hermes-plugin/)
- [Profile Commands](https://hermes-agent.nousresearch.com/docs/reference/profile-commands/)

Implication:

- Hermes should be reused as the first host runtime
- the Hermes plugin matters, but should not become the product identity
- runtime orchestration itself is mostly Hermes territory, not the central competition artifact

### 2a. Hermes plugin reality is important

Evidence:

- Hermes plugins are documented as `plugin.yaml` + Python registration code such as `__init__.py`
- plugins register tools, hooks, and commands through the Hermes Python plugin API
- plugins can bundle and install skills into Hermes
- Hermes can also be used as a Python library directly

Sources:

- [Build a Hermes Plugin](https://hermes-agent.nousresearch.com/docs/guides/build-a-hermes-plugin/)
- [Using Hermes as a Python Library](https://hermes-agent.nousresearch.com/docs/guides/python-library)

Implication:

- a thin Python-facing Hermes adapter is the realistic path
- MoonBit should not be forced into pretending that Hermes has a MoonBit-native plugin ABI
- the elegant design move is to keep the Hermes-facing shell thin and move originality-critical logic behind that boundary

### 3. Entire contributes a capture/provenance strategy, not the whole product we want

Evidence:

- Entire captures AI agent sessions during work
- checkpoints are created when you or the agent make Git commits
- session metadata is stored on a separate `entire/checkpoints/v1` branch
- the CLI is open source and MIT licensed

Sources:

- [Entire Core Concepts](https://docs.entire.io/core-concepts)
- [Entire installation](https://docs.entire.io/cli/installation)
- [Entire CLI repository](https://github.com/entireio/cli)

Implication:

- Entire is a strong reference for `capture + checkpoint + commit linkage`
- we should borrow the strategy
- we should not treat "copy Entire" as the product plan because our target object is broader than code-session explainability

### 3a. Entire open-source scope appears narrower than the full hosted product

Evidence:

- the official messaging clearly calls out the `Entire CLI` as the open-source project
- docs and product pages separately describe the hosted web application

Sources:

- [Hello Entire World](https://entire.io/blog/hello-entire-world/)
- [Entire CLI repository](https://github.com/entireio/cli)
- [Entire web overview](https://docs.entire.io/web/overview)

Implication:

- we can confidently study and borrow from the CLI side
- we should not assume the full hosted/web product is available to reuse as open-source implementation
- this strengthens the case for building our own hosted/local product layer

### 4. Skill Forge contributes an engineering and publishing discipline for skills

Evidence:

- `motiful/skill-forge` describes itself as a skill engineering methodology and publishing pipeline
- it treats skills as engineered, publishable units
- it emphasizes validation, security scanning, registration correctness, discoverability, and GitHub publishing
- it is MIT licensed

Sources:

- [motiful/skill-forge](https://github.com/motiful/skill-forge)

Implication:

- `skill-forge` is a strong reference for post-authoring engineering and distribution discipline
- it does not replace the need for our own provenance/capture/hosting substrate

### 5. Gitea contributes a realistic Git-first hosted product shape

Evidence:

- Gitea presents itself as self-hosted Git software with repo management, pull requests, APIs, registry, and CI/CD
- it is MIT licensed at the repository level
- its docs compare it directly as a self-hosted Git platform

Sources:

- [Gitea repository](https://github.com/go-gitea/gitea)
- [Compared to other Git hosting](https://docs.gitea.com/next/installation/comparison)

Implication:

- Gitea is a strong reference for hosted/local product shape
- borrowing its product thinking is more realistic than copying large parts of its implementation

### 6. MoonBit has real features that matter here

Evidence:

- MoonBit supports packages/modules via `moon.mod.json` and `moon.pkg`
- MoonBit supports publishing and dependency management through mooncakes
- MoonBit supports FFI
- MoonBit supports a component-model path
- MoonBit supports async, but the runtime story is still backend-sensitive

Sources:

- [Package manager tutorial](https://docs.moonbitlang.com/en/stable/toolchain/moon/package-manage-tour.html)
- [Package configuration](https://docs.moonbitlang.com/en/latest/toolchain/moon/package.html)
- [FFI](https://docs.moonbitlang.com/en/latest/language/ffi.html)
- [MoonBit for Component Model](https://docs.moonbitlang.com/en/latest/toolchain/wasm/component-model-tutorial.html)
- [Async support](https://docs.moonbitlang.com/en/latest/language/async-experimental.html)

Implication:

- MoonBit is strong where typed modular structure, portable logic, and native/FFI boundaries matter
- MoonBit is not automatically the best place for all host integration logic

### 6a. MoonBit virtual packages are a notable architectural tool

Evidence:

- MoonBit supports `virtual` packages that act as interfaces
- implementations can be swapped at build time using `implement` and `overrides`

Sources:

- [Managing Projects with Packages - Virtual Packages](https://docs.moonbitlang.com/en/latest/language/packages.html)
- [Package Configuration - Virtual Package](https://docs.moonbitlang.com/en/latest/toolchain/moon/package.html)

Implication:

- MoonBit has a native mechanism for defining clean backend boundaries
- this is a strong candidate for separating:
  - Git-native backend vs `libgit2` backend
  - local blob storage vs remote blob storage
  - local-only control-plane storage vs hosted implementations
- this is one of the most "MoonBit-native" ways to tell a clear story without overclaiming

### 7. MoonBit Git ecosystem is real enough to matter

Evidence:

- `mizchi/git` exposes repo persistence, packfile generation, index writing, and repo materialization in MoonBit
- related `mizchi` MoonBit Git packages also show lower-level Git object and upload-pack/fetch machinery, including HTTP fetch and partial clone oriented code paths
- `mizchi/libgit2` exposes native libgit2 bindings in MoonBit

Sources:

- [mizchi/git repo_persist](https://mooncakes.io/assets/mizchi/git/repo_persist.mbt.html)
- [mizchi/git packfile](https://mooncakes.io/assets/mizchi/git/packfile.mbt.html)
- [mizchi object creation](https://mooncakes.io/assets/mizchi/bit/object/object.mbt.html)
- [mizchi upload-pack HTTP common](https://mooncakes.io/assets/mizchi/bit/upload_pack_http_common.mbt.html)
- [mizchi upload-pack common](https://mooncakes.io/assets/mizchi/git/upload_pack_common.mbt.html)
- [mizchi/libgit2](https://mooncakes.io/assets/mizchi/libgit2/libgit2.mbt.html)

Implication:

- Git should be treated as a live MoonBit design question, not as a fixed black box
- this is one of the most credible areas for MoonBit-native originality
- MoonBit-native Git is not just a toy opportunity here; it already appears capable of supporting serious provenance-oriented workflows

## What the project center most likely is

### Strongest current synthesis

The project center is not "skill authoring" and not "runtime orchestration".

It is the software layer that sits between:

- internal agent work
- durable capture and provenance
- engineered shareable assets
- hosted/local reproduction and management

That means the product center likely combines:

1. `capture + provenance`
2. `engineered shareable assets`
3. `hosted/local management software`

This is compatible with:

- Hermes as first runtime host
- Agent Skills as public skill standard
- Entire as provenance reference
- skill-forge as skill engineering reference
- Gitea/GitHub as Git-first hosting substrates

### What the shareable artifact currently converges on

From the OMX discussion so far, the default external shareable object converges on:

- `skill`
- `profile`
- `topology`

And does **not** default to sharing:

- raw trace
- tmux state
- in-flight runtime state
- checkpoint internals

Inference from discussion:

- another user should be able to reproduce the same core experience by running the same `skill/profile/topology`
- exact replay of the original process is not required

## What should be reused vs implemented

## Reuse directly

These should normally be reused rather than redefined:

- the `Agent Skills` standard
- Hermes runtime for actual agent/profile/session execution
- Git hosting from GitHub/Gitea
- general Git object model semantics

Why:

- these are already strong standards or substrates
- rebuilding them wholesale does not strengthen the software story enough

## Borrow strategically, but do not make them the product

These should be treated as references, not as the whole product:

- Entire
- skill-forge
- Gitea

Why:

- each solves an adjacent problem well
- none of them directly equals the target product

## Implement in MoonBit when it improves both software quality and the competition story

These are the best candidates for MoonBit-native implementation:

- provenance branch data model and checkpoint metadata writing
- asset package validation around `skill + profile + topology`
- topology normalization and structural checks
- capture normalization and extraction logic
- local/hosted substrate logic that makes the system coherent
- repo materialization / Git-native publishing logic where it expresses originality

## Recommendation on Git

### High-level decision

The best current recommendation is:

`Git should be a hybrid layer: reuse Git semantics and hosting, but implement originality-critical provenance and metadata flows in MoonBit.`

### Why not pure reuse

If we treat Git as completely external, then one of the best MoonBit story opportunities disappears:

- Git-native provenance
- checkpoint metadata
- materialized shareable asset repos
- structured lineage storage

### Why not pure reinvention

Reimplementing all Git behavior from scratch would be wasteful and risky.

### Recommended split

- use Git itself and Git hosting as the real substrate
- prefer MoonBit-native Git logic for provenance-specific flows where feasible
- use `libgit2` binding as a fallback for integration-heavy or host-sensitive tasks

### Concrete judgment on the MoonBit Git options

#### `mizchi/git`

Best fit when:

- the goal is to make Git/provenance part of the competition artifact
- we need repo materialization, pack/index writing, or metadata branch generation
- we want a stronger "MoonBit did real substrate work" story

#### `mizchi/libgit2`

Best fit when:

- we need immediate compatibility with mature Git repository operations
- host integration matters more than originality in that specific path
- MoonBit-native coverage is not yet enough for the needed workflow

### Bottom line

Recommended strategy:

- `main provenance path`: MoonBit-native where credible
- `compatibility path`: libgit2 binding when needed

This is the most defensible hybrid under current evidence.

## Recommendation on storage

### Blob store

Recommended judgment:

`yes, likely needed in phase 1`

Reason:

- internal capture will produce larger artifacts
- those should not all live in the default shareable package
- they still need durable storage

Phase 1 implementation can be modest:

- filesystem-backed blob storage is acceptable initially

### DuckDB

Recommended judgment:

`not mandatory in phase 1`

Reason:

- current primary need is durable capture, lineage, and export
- not analytical querying at scale
- the strongest references do not require DuckDB to establish the core product logic

Potential later use:

- search
- analytics
- attribution dashboards
- mining and batch extraction from stored traces

Additional evidence:

- DuckDB describes itself as an in-process analytical/OLAP database
- Gitea's production-oriented docs instead emphasize service databases such as PostgreSQL/MySQL and warn that SQLite does not scale

Sources:

- [DuckDB home](https://duckdb.org/)
- [DuckDB analytical DB paper index](https://duckdb.org/library/duckdb/)
- [Gitea database preparation](https://docs.gitea.com/1.26/installation/database-prep)

### Bottom line

- `blob store`: likely yes
- `DuckDB`: optional until query-heavy workflows become central

Inference:

- if the project needs a true multi-user hosted control plane with transactional state, DuckDB should not be the default first choice for the primary operational store
- DuckDB is better positioned as an analysis and mining layer than as the sole system-of-record for hosted coordination

## What "test assets generated at scale" means in this report

Important correction from the discussion:

`test assets generated at scale` is a working method, not the product center.

Interpretation:

- we should collect open-source test assets from relevant projects
- use those assets to synthesize and validate the software
- this improves product quality and evaluation coverage
- but it is not itself the software being entered

Implication:

- the product must still stand on its own as coherent software
- we should not confuse evaluation methodology with product identity

## Best-practice recommendation

If we apply the "common-sense heuristic" from the discussion:

- reuse standards and strong substrates when they are already good
- implement directly in MoonBit when MoonBit makes the result stronger and more explainable
- keep the system self-consistent rather than trimming it into a demo-shaped hack

Then the best-practice architecture direction is:

1. `Skill standard`
   Reuse Agent Skills

2. `Runtime host`
   Reuse Hermes

3. `Hermes integration`
   Write a thin plugin/adapter

4. `Provenance / capture / export substrate`
   Build this as our originality-heavy MoonBit layer

5. `Hosted/local product surface`
   Build this as our product identity layer, borrowing product ideas from Gitea but not reducing the project to "another Git host"

6. `Storage`
   Git for durable lineage and distribution
   Blob storage for larger internal artifacts
   Database only when query needs justify it

## Refined recommendation on MoonBit boundaries

The most credible "MoonBit-native but not forced" split is:

- `Hermes-facing adapter shell`
  - thin
  - Python plugin or library integration
  - runtime-specific

- `MoonBit substrate`
  - provenance metadata model
  - checkpoint/export lineage logic
  - asset/package validation
  - topology/profile normalization
  - capture normalization
  - repo materialization where originality matters

- `MoonBit implementation boundaries`
  - use virtual packages or equivalent package-level interfaces where practical
  - keep backend substitutions explicit instead of hidden in ad hoc FFI glue

This split is better than:

- pushing everything into the Hermes plugin
- treating MoonBit as a decorative side tool
- forcing full reimplementation of host/runtime concerns that are already solved elsewhere

## Final recommendation for the next phase

The next OMX phase should stop asking whether we need a vague "core".

Instead, it should answer this concrete design question:

`Which parts of the provenance/capture/export/hosting substrate must be MoonBit-native for the software to feel both original and self-consistent?`

The best candidates to evaluate first are:

- checkpoint metadata branch format
- lineage model between internal capture and external shareable assets
- asset export/import structure for `skill + profile + topology`
- Git-native materialization and publishing path
- minimum hosted/local management surface that makes the software a real product instead of a thin adapter
