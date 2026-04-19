# Seed Rules Reference

## Purpose

This note captures the first batch of extracted rules and invariants from CLI-inspected sources.

It is intentionally small and only records rules that already look stable enough to guide later synthesis.

## 1. Skill format invariants

Source confidence:

- `agentskills/agentskills`: `A`
- `anthropics/skills`: `A-`

CLI-inspected files:

- `/tmp/omx-research/agentskills/docs/specification.mdx`
- `/tmp/omx-research/skills/README.md`
- `/tmp/omx-research/skills/spec/agent-skills-spec.md`

Extracted rules:

- A skill is a directory with at least `SKILL.md`.
- Optional directories include:
  - `scripts/`
  - `references/`
  - `assets/`
- `SKILL.md` uses YAML frontmatter plus Markdown body.
- Required fields:
  - `name`
  - `description`
- Important optional fields:
  - `license`
  - `compatibility`
  - `metadata`
  - `allowed-tools`
- The parent directory name should match the skill name.
- The standard explicitly encourages progressive disclosure:
  - metadata always loaded
  - `SKILL.md` body loaded on activation
  - extra resources loaded on demand

Interpretation for our project:

- `skill` should remain aligned to the public standard
- our software should not redefine skill format fundamentals
- our originality should be around packaging, lineage, topology, capture, and hosting

## 2. Real-world skill packaging patterns

Source confidence:

- `anthropics/skills`: `A-`

CLI-inspected paths:

- `/tmp/omx-research/skills/skills/algorithmic-art/SKILL.md`
- `/tmp/omx-research/skills/skills/pdf/SKILL.md`
- `/tmp/omx-research/skills/skills/pdf/forms.md`
- `/tmp/omx-research/skills/skills/pdf/reference.md`
- `/tmp/omx-research/skills/skills/slack-gif-creator/requirements.txt`
- `/tmp/omx-research/skills/skills/theme-factory/theme-showcase.pdf`
- `/tmp/omx-research/skills/template/SKILL.md`

Extracted rules:

- Real skill repos vary significantly in complexity.
- Some skills are near-minimal `SKILL.md` only.
- Some include reference docs beside the main skill file.
- Some include executable dependencies or runtime hints outside `SKILL.md`.
- Some include binary/static assets.

Interpretation for our project:

- our asset corpus must include both minimal and heavy skills
- our package model cannot assume every skill is text-only
- validation should distinguish between:
  - canonical standard shape
  - richer real-world packaging patterns

## 3. Skill engineering workflow rules

Source confidence:

- `motiful/skill-forge`: `A-`

CLI-inspected files:

- `/tmp/omx-research/skill-forge/README.md`
- `/tmp/omx-research/skill-forge/references/skill-format.md`

Extracted rules:

- Skills should be treated as engineered, publishable artifacts.
- Post-authoring steps matter:
  - validation
  - security scan
  - README/install honesty
  - registration/link correctness
  - publish workflow
- The README strongly distinguishes:
  - authoring
  - post-authoring engineering
- skill-forge introduces extra internal structure beyond the public standard:
  - execution procedures
  - internal conventions for reference modules

Interpretation for our project:

- we should borrow engineering discipline, not blindly inherit all internal conventions
- our rules layer should separate:
  - public standard requirements
  - our internal packaging and provenance rules

## 4. Capture and checkpoint lineage rules

Source confidence:

- `entireio/cli`: `A`
- Entire docs: `A`

CLI-inspected files:

- `/tmp/omx-research/cli/docs/architecture/sessions-and-checkpoints.md`
- `/tmp/omx-research/cli/e2e/tests/checkpoint_metadata_test.go`

Extracted rules:

- Session and checkpoint are separate concepts.
- Temporary checkpoints and committed checkpoints should be distinguished.
- Full state does not have to be stored in the same place as durable metadata.
- Durable checkpoint metadata can live on a dedicated Git branch.
- Checkpoint records can be validated through real end-to-end tests, not only architecture prose.
- Multi-session and multi-checkpoint behavior matters in realistic systems.

Interpretation for our project:

- we should explicitly separate:
  - internal capture state
  - durable lineage metadata
  - external shareable package
- this strengthens the current discussion conclusion that default shareable packages should not include raw runtime state

## 5. Runtime host boundary rules

Source confidence:

- Hermes docs: `A`
- Hermes repository structure: `A-`

CLI-inspected paths:

- `/tmp/omx-research/hermes-agent/gateway/`
- `/tmp/omx-research/hermes-agent/agent/skill_commands.py`
- `/tmp/omx-research/hermes-agent/cli-config.yaml.example`
- `/tmp/omx-research/hermes-agent/docs/`

Extracted rules:

- Hermes already owns substantial runtime concerns:
  - skills
  - profiles
  - gateway/platforms
  - sessions
  - API/server-like surfaces
- Hermes is large and operationally rich.
- A Hermes-facing integration should not pretend it owns the runtime itself.

Interpretation for our project:

- keep Hermes integration thin
- do not relocate runtime orchestration into our substrate
- focus our software on what Hermes does not already provide:
  - capture/provenance semantics
  - shareable package model
  - hosted/local product layer around those objects

## 6. Hosted/local product-shape rules

Source confidence:

- Gitea repo/docs: `A-`

CLI-inspected paths:

- `/tmp/omx-research/gitea/custom/conf/app.example.ini`
- `/tmp/omx-research/gitea/cmd/`
- `/tmp/omx-research/gitea/docs/`

Extracted rules:

- Hosted Git products have broad operational scope.
- Database, deployment, service, and CLI/admin boundaries are real and cannot be hand-waved.
- A hosted/local management layer is a serious product, not a minor wrapper.

Interpretation for our project:

- if hosted/local management is part of the product identity, we must treat it as first-class software
- but we should still avoid rebuilding a general-purpose Git host

## 7. MoonBit implementation rules

Source confidence:

- MoonBit docs: `A`
- MoonBit Git packages: `A-`

Already gathered from prior research:

- packages and virtual packages are real architectural tools
- FFI and component boundaries are available
- MoonBit-native Git packages are credible enough to matter

Interpretation for our project:

- MoonBit should own the structured substrate
- host/runtime-specific shells can stay thin
- backend substitution should be explicit and principled
