# First-Wave Concrete Asset Sources

## Purpose

This note turns the earlier asset classes into a concrete first-wave source list.

It is intended to answer:

- which repositories, docs, and artifacts should be collected first
- what each source is useful for
- which product questions each source helps clarify

## Selection criteria

A source is first-wave if it is at least one of:

- authoritative
- widely adopted
- structurally representative
- useful for stressing packaging/provenance/hosting boundaries

## 1. Skill asset sources

### 1.1 `agentskills/agentskills`

Use for:

- the public skill specification
- reference validator/tooling direction
- canonical directory and metadata expectations

Why first-wave:

- this is the public standard itself

Primary questions:

- what must a skill package contain
- what belongs in metadata vs compatibility vs body vs resources

Source:

- [agentskills/agentskills](https://github.com/agentskills/agentskills)

### 1.2 `anthropics/skills`

Use for:

- high-quality example skills
- diverse patterns inside one repository
- examples of skill folders with scripts/references/assets

Why first-wave:

- official and widely referenced
- exposes both simple and complex skill engineering patterns

Primary questions:

- what real high-quality skills look like
- what should be treated as exemplary package structure

Source:

- [anthropics/skills](https://github.com/anthropics/skills)

### 1.3 `motiful/skill-forge`

Use for:

- skill validation
- skill publishing
- registration/symlink workflows
- security scanning and engineering discipline

Why first-wave:

- strongest current reference for "skills are code"

Primary questions:

- what engineering steps sit around a skill
- what parts of that pipeline we should borrow vs build

Source:

- [motiful/skill-forge](https://github.com/motiful/skill-forge)

### 1.4 A large community skill corpus

Recommended example:

- [mukul975/Anthropic-Cybersecurity-Skills](https://github.com/mukul975/Anthropic-Cybersecurity-Skills)

Use for:

- scale stress
- repeated skill structure
- large-batch validation assumptions

Why first-wave:

- we need at least one "many-skill" corpus to test scale assumptions

Primary questions:

- how packaging and validation behave at larger scale
- what breaks when moving beyond hand-curated examples

## 2. Capture / provenance sources

### 2.1 `entireio/cli`

Use for:

- capture strategy
- checkpoint metadata branch usage
- commit/checkpoint linkage
- rewind/resume assumptions

Why first-wave:

- strongest open-source reference for Git-native AI session capture

Primary questions:

- what metadata belongs on a durable Git branch
- what should stay local vs synced

Source:

- [entireio/cli](https://github.com/entireio/cli)

### 2.2 Entire docs - core concepts

Use for:

- branch format expectations
- temporary vs committed checkpoint split
- session/checkpoint vocabulary

Why first-wave:

- docs clarify semantics more cleanly than code alone

Primary questions:

- which parts of Entire's strategy transfer directly
- which parts are code-centric and not asset-centric enough for our project

Sources:

- [Entire Core Concepts](https://docs.entire.io/core-concepts)
- [Entire Introduction](https://docs.entire.io/introduction)

## 3. Profile / runtime-linked sources

### 3.1 Hermes profile docs

Use for:

- profile semantics
- profile import/export expectations
- profile-scoped skills, sessions, and gateway behavior

Why first-wave:

- `profile` is part of our converged external shareable object

Primary questions:

- what belongs in a host/runtime profile
- what should be mirrored into our package model vs left host-specific

Sources:

- [Hermes Profile Commands](https://hermes-agent.nousresearch.com/docs/reference/profile-commands/)
- [Hermes FAQ on profiles](https://hermes-agent.nousresearch.com/docs/reference/faq)

### 3.2 Hermes config examples and runtime docs

Use for:

- real host assumptions
- gateway/session/runtime boundaries
- environment and skill directory behavior

Why first-wave:

- we need real runtime grounding, not only abstract packaging

Sources:

- [Hermes docs home](https://hermes-agent.nousresearch.com/docs/)
- [Hermes installation](https://hermes-agent.nousresearch.com/docs/getting-started/installation/)

## 4. Topology-like sources

### 4.1 GitHub agentic workflow examples

Use for:

- role graph patterns
- review/commit/approval lane structures
- multi-agent workflow framing

Why first-wave:

- topology has the weakest explicit standard today
- workflow-style public artifacts are one of the best empirical proxies

Source:

- [GitHub Agentic Workflows slides](https://github.github.com/gh-aw/slides/github-agentic-workflows.pdf)

### 4.2 Public multi-skill / workflow repos

Recommended examples:

- [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)
- [WordPress/agent-skills](https://github.com/WordPress/agent-skills)

Use for:

- workflow layering
- quality-gate patterns
- structured engineering lanes encoded as skills

Why first-wave:

- these are realistic sources of role/task topology hints even when they do not call themselves "topology repos"

## 5. Hosted/local product surface sources

### 5.1 `go-gitea/gitea`

Use for:

- self-hosted Git product shape
- repo-centric sharing and management semantics
- practical service boundaries

Why first-wave:

- strongest lightweight open-source Git-hosting reference

Primary questions:

- what belongs in our hosted/local management layer
- what should stay delegated to general Git hosting

Sources:

- [go-gitea/gitea](https://github.com/go-gitea/gitea)
- [Gitea comparison docs](https://docs.gitea.com/next/installation/comparison)
- [Gitea database preparation](https://docs.gitea.com/1.26/installation/database-prep)

### 5.2 GitHub agent skills client support docs

Use for:

- how another major host/tool surface supports agent skills
- install paths
- user-facing integration expectations

Why first-wave:

- helps avoid designing a packaging model that ignores major client realities

Source:

- [GitHub Docs - About agent skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)

## 6. MoonBit-specific implementation substrate sources

### 6.1 MoonBit package / FFI / component model docs

Use for:

- deciding what should be MoonBit-native
- deciding where runtime boundaries should be
- understanding realistic integration patterns

Sources:

- [MoonBit package manager tutorial](https://docs.moonbitlang.com/en/stable/toolchain/moon/package-manage-tour.html)
- [MoonBit package configuration](https://docs.moonbitlang.com/en/latest/toolchain/moon/package.html)
- [MoonBit FFI](https://docs.moonbitlang.com/en/latest/language/ffi.html)
- [MoonBit component model tutorial](https://docs.moonbitlang.com/en/latest/toolchain/wasm/component-model-tutorial.html)
- [MoonBit virtual packages](https://docs.moonbitlang.com/en/latest/language/packages.html)

### 6.2 MoonBit Git ecosystem

Use for:

- deciding the MoonBit-native Git/provenance path
- understanding how much can be genuinely implemented in MoonBit

Sources:

- [mizchi/git repo_persist](https://mooncakes.io/assets/mizchi/git/repo_persist.mbt.html)
- [mizchi/git packfile](https://mooncakes.io/assets/mizchi/git/packfile.mbt.html)
- [mizchi object creation](https://mooncakes.io/assets/mizchi/bit/object/object.mbt.html)
- [mizchi upload-pack HTTP common](https://mooncakes.io/assets/mizchi/bit/upload_pack_http_common.mbt.html)
- [mizchi/libgit2](https://mooncakes.io/assets/mizchi/libgit2/libgit2.mbt.html)

## 7. First-wave collection order

Recommended order:

1. `agentskills/agentskills`
2. `anthropics/skills`
3. `motiful/skill-forge`
4. `entireio/cli` + Entire docs
5. Hermes profile/runtime docs
6. Gitea docs/repo
7. workflow/topology proxy repos
8. MoonBit substrate docs and Git packages

## 8. Immediate deliverables this source set should enable

This first-wave source set should be enough to derive:

- a grounded vocabulary
- a first reusable test-asset corpus
- a first mock-boundary slate
- a stronger MoonBit-native implementation map

## 9. What should happen next

The next revision should add:

- per-source extraction notes
- exact files or folders to ingest from each source
- what each source contributes to:
  - capture
  - provenance
  - package/share
  - hosting
  - topology
