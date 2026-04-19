# Per-Source Extraction Notes

## Purpose

This note makes the extraction plan concrete.

For each major source, it records:

- which files or directories to inspect first
- what should be extracted from them
- whether the result should go into:
  - the test asset corpus
  - the rules/reference layer
  - the mock-boundary input layer

## Output buckets

### Asset corpus

Use for:

- realistic files and objects we want to validate or process

### Rules/reference layer

Use for:

- invariants
- schemas
- compatibility rules
- architecture constraints

### Mock-boundary inputs

Use for:

- host/runtime/service interfaces that we want to simulate before binding to the real system

## 1. `agentskills/agentskills`

### Inspect first

- repository root documentation
- specification pages
- validation-related tooling or examples if present
- template or canonical example skill structure

### Extract

- required skill shape
- optional directories and their meaning
- compatibility and metadata expectations
- naming and packaging constraints

### Put results into

- Rules/reference layer: yes
- Asset corpus: minimal canonical examples only
- Mock-boundary inputs: no

### Why

- this source defines the public standard
- it is the anchor for all skill-related compatibility

## 2. `anthropics/skills`

### Inspect first

- `skills/`
- `template/`
- `spec/`
- any representative subfolders with:
  - `SKILL.md`
  - `scripts/`
  - `references/`
  - `assets/`

### Extract

- simple skill examples
- complex skill examples
- patterns for bundled resources
- patterns for helper scripts
- cases where repository layout adds engineering complexity

### Put results into

- Asset corpus: yes, curated subset
- Rules/reference layer: yes, for recurring patterns
- Mock-boundary inputs: limited, only if some skill implies a service interface we need to simulate

### Why

- this is one of the best sources of realistic high-quality skill examples
- it helps us avoid inventing toy packaging assumptions

## 3. `motiful/skill-forge`

### Inspect first

- root README and workflow docs
- validation scripts or workflow files
- publishing or registration-related files
- any directory that shows post-authoring engineering steps

### Extract

- validation stages
- publication stages
- safety/security checks
- registration/install/link patterns
- assumptions about repository-backed skill distribution

### Put results into

- Rules/reference layer: yes
- Asset corpus: usually no
- Mock-boundary inputs: yes, for validation and publish workflow simulation

### Why

- this is a workflow and methodology source more than a raw asset source

## 4. `entireio/cli`

### Inspect first

- checkpoint-related modules
- session metadata modules
- Git interaction modules
- any path mentioning:
  - `checkpoint`
  - `session`
  - `branch`
  - `trailer`
  - `rewind`
  - `resume`

### Extract

- checkpoint branch usage
- metadata layout concepts
- commit/checkpoint linkage rules
- local-vs-synced distinction
- replay/recovery assumptions

### Put results into

- Rules/reference layer: yes
- Asset corpus: yes, if reproducible metadata examples are available
- Mock-boundary inputs: yes, for checkpoint backend and capture metadata mocks

### Why

- this is the strongest open reference for Git-linked agent capture

## 5. Entire docs

### Inspect first

- core concepts
- introduction
- install/setup docs when they clarify storage or branch behavior

### Extract

- authoritative semantics
- vocabulary
- local temporary vs durable synced split

### Put results into

- Rules/reference layer: yes
- Asset corpus: no
- Mock-boundary inputs: yes, indirectly

### Why

- docs are often clearer than code for semantic intent

## 6. Hermes docs

### Inspect first

- skills system docs
- profile commands
- plugin guide
- messaging/gateway/session docs
- API/frontend docs if they shape product surfaces

### Extract

- real host responsibilities
- profile semantics
- plugin boundary
- channel/session/gateway assumptions
- what Hermes already owns vs what our software must own

### Put results into

- Rules/reference layer: yes
- Asset corpus: limited, only explicit exported/config-like examples
- Mock-boundary inputs: yes, heavily

### Why

- Hermes is the first runtime host, so its real boundary matters a lot

## 7. `go-gitea/gitea` + Gitea docs

### Inspect first

- installation/comparison docs
- database preparation docs
- repo/package/registry related docs
- architecture or API overview pages if available

### Extract

- hosted product responsibilities
- what belongs inside a Git host
- what belongs outside in our domain layer
- deployment/storage implications

### Put results into

- Rules/reference layer: yes
- Asset corpus: no
- Mock-boundary inputs: yes, for hosted management API expectations

### Why

- Gitea is a product-shape reference, not a raw asset corpus

## 8. GitHub Docs on agent skills

### Inspect first

- user-facing skill support docs
- install/use docs
- examples of how skills are surfaced in GitHub-hosted tools

### Extract

- client expectations
- install/distribution assumptions
- marketplace or repo-backed workflow hints

### Put results into

- Rules/reference layer: yes
- Asset corpus: no
- Mock-boundary inputs: yes, for share/registry/client-facing mocks

### Why

- this helps keep our package/share assumptions compatible with major client realities

## 9. MoonBit docs

### Inspect first

- packages
- virtual packages
- FFI
- component model
- package management

### Extract

- implementation constraints
- backend boundary patterns
- build-time interface substitution patterns
- what can credibly be MoonBit-native

### Put results into

- Rules/reference layer: yes
- Asset corpus: no
- Mock-boundary inputs: yes, for backend/interface design

### Why

- this defines what the implementation can honestly claim

## 10. MoonBit Git packages

### Inspect first

- `mizchi/git` repo persistence and pack/index paths
- object creation paths
- upload-pack/fetch-related modules
- `mizchi/libgit2` bindings

### Extract

- Git-native capability map
- what operations can be done in MoonBit directly
- where bindings remain more practical

### Put results into

- Rules/reference layer: yes
- Asset corpus: no
- Mock-boundary inputs: yes, for Git backend separation

### Why

- this directly informs one of the strongest MoonBit-native implementation candidates

## Immediate practical next step

The next revision of this note should turn each source into:

- exact paths to ingest
- exact sample items to copy or mirror
- exact rules to record
- exact mocks to seed
