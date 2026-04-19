# Extraction Rules and Quality Grading

## Purpose

This note explains:

- what has been found so far
- what should be extracted from each source
- what should enter the test asset corpus
- what should remain design reference only
- what should be mocked first
- how source quality should be judged

## What "extract" means here

Extraction does not always mean copying files into our repository.

It can mean one of four things:

1. `spec extraction`
   - extract vocabulary, invariants, schemas, and compatibility rules

2. `asset extraction`
   - copy or mirror representative test assets into a local corpus

3. `pattern extraction`
   - extract recurring structural patterns from repos or docs

4. `boundary extraction`
   - identify an interface that should be mocked, wrapped, or kept real

## What has been found so far

### A. Public skill standard and examples

Found:

- `agentskills/agentskills`
- `anthropics/skills`
- community skill corpora such as large open skill collections

Why they matter:

- they define what a real skill looks like
- they provide examples of scale and variation

### B. Skill engineering / publishing pipeline

Found:

- `motiful/skill-forge`

Why it matters:

- it is the strongest current reference for "skill as code" engineering discipline

### C. Runtime host reality

Found:

- Hermes skills, profiles, plugins, gateway/session surfaces

Why it matters:

- this tells us what the first host runtime already owns
- it prevents us from putting Hermes responsibilities into our own substrate by mistake

### D. Capture / provenance strategy

Found:

- `entireio/cli`
- Entire docs about sessions, checkpoints, and Git-linked metadata

Why it matters:

- this is the strongest open reference for AI session capture tied to Git lineage

### E. Hosted Git product shape

Found:

- `go-gitea/gitea`
- GitHub skills integration docs

Why it matters:

- these ground the hosted/local management side of the product

### F. MoonBit implementation opportunities

Found:

- MoonBit package/module system
- virtual packages
- FFI / component model docs
- MoonBit Git packages such as `mizchi/git` and `mizchi/libgit2`

Why it matters:

- this tells us what can be credibly implemented in MoonBit rather than merely wrapped

## Per-source extraction rules

## 1. `agentskills/agentskills`

Extract:

- specification sections
- canonical required fields
- optional directory conventions
- compatibility and metadata rules

Put into test asset corpus:

- yes, but mainly as minimal canonical skill examples

Keep as design reference only:

- explanatory prose that does not affect format or compatibility

Do not mock:

- the standard itself

Quality:

- `A`
- reason: authoritative standard source

## 2. `anthropics/skills`

Extract:

- representative skill folders
- examples with `scripts/`, `references/`, and `assets/`
- examples of simple vs complex skill structure

Put into test asset corpus:

- yes
- sample a curated subset, not the whole repo blindly

Keep as design reference only:

- Claude-specific marketplace/plugin instructions that do not transfer directly

Mock boundary implications:

- helps define package parsing and validation mocks

Quality:

- `A-`
- reason: high-quality official examples, but partly vendor-specific in usage context

## 3. `motiful/skill-forge`

Extract:

- validation stages
- publication pipeline steps
- registration/symlink patterns
- safety/security checks

Put into test asset corpus:

- mostly no
- use it more as engineering workflow reference than as raw asset corpus

Keep as design reference only:

- yes, for most of it

Mock boundary implications:

- informs validation service and publish pipeline mocks

Quality:

- `A-`
- reason: strong methodology and workflow reference, but not the full product we are building

## 4. `entireio/cli` + Entire docs

Extract:

- checkpoint branch conventions
- commit/checkpoint linkage rules
- session/checkpoint vocabulary
- local-vs-synced split

Put into test asset corpus:

- yes, for metadata patterns and any reproducible checkpoint examples

Keep as design reference only:

- product wording and web-app-specific behavior not present in the CLI

Mock boundary implications:

- directly informs checkpoint backend and capture metadata mocks

Quality:

- `A`
- reason: best current open reference for Git-linked AI capture

## 5. Hermes docs and examples

Extract:

- profile semantics
- plugin boundary
- skill install/load assumptions
- gateway/session/channel-related runtime expectations

Put into test asset corpus:

- only selected exported/config-like examples

Keep as design reference only:

- most runtime and host operational detail

Mock boundary implications:

- defines which runtime events and profile surfaces should be mocked first

Quality:

- `A`
- reason: authoritative for the first host runtime

## 6. Gitea docs / repo

Extract:

- hosted product responsibilities
- service boundaries
- storage/deployment implications
- what belongs to a Git host vs what belongs to our domain layer

Put into test asset corpus:

- no, mostly design reference

Keep as design reference only:

- yes

Mock boundary implications:

- informs hosted management API mocks

Quality:

- `A-`
- reason: strong product-shape reference, but not domain-specific enough to become asset corpus

## 7. MoonBit docs and MoonBit Git packages

Extract:

- implementation constraints
- virtual package patterns
- Git-native capability map
- FFI/component-model options

Put into test asset corpus:

- no, this is implementation/reference input rather than domain data

Keep as design reference only:

- yes

Mock boundary implications:

- defines how we separate backend implementations cleanly

Quality:

- `A`
- reason: authoritative for implementation feasibility

## What goes into the test asset corpus

Put in when:

- it is a realistic example of a shareable or capturable object
- it stresses our package/provenance/topology logic
- it is concrete enough to run validation against

Examples:

- representative skills
- large skill collections
- profile-like exports/configs
- checkpoint metadata samples
- trace/checkpoint payload examples
- topology-like workflow examples

## What stays as design reference only

Keep as reference only when:

- it mostly teaches product shape or methodology
- it is authoritative but not itself a reusable asset
- copying it would add noise to the corpus

Examples:

- most Gitea docs
- most skill-forge workflow prose
- most MoonBit implementation docs
- most Hermes operational docs

## What should be mocked first

Mock first when:

- the boundary is host-coupled
- real integration is unstable or heavy
- we need semantic clarity before final infra choice

First mock set:

1. package/share registry boundary
2. runtime event stream
3. checkpoint/blob backend
4. hosted management API
5. topology activation boundary

## Quality grading rubric

### Grade A

- authoritative or primary source
- structurally representative
- directly useful for design or corpus
- low ambiguity

### Grade A-

- high quality and very useful
- but either vendor-specific, partial, or not exactly our target domain

### Grade B

- useful secondary source
- should not drive core decisions alone

### Grade C

- anecdotal, partial, or too noisy
- okay for inspiration, weak for architectural decisions

## Current quality summary

- `agentskills/agentskills`: `A`
- `anthropics/skills`: `A-`
- `motiful/skill-forge`: `A-`
- `entireio/cli` + Entire docs: `A`
- Hermes docs: `A`
- Gitea docs/repo: `A-`
- MoonBit docs: `A`
- MoonBit Git packages: `A-` as feasibility evidence, pending hands-on repo validation

## Main practical interpretation

The extraction strategy should be:

- use standards and official docs to define invariants
- use curated real examples to build a test asset corpus
- use methodology/product references to shape design
- use mocks to isolate unstable host-specific boundaries
