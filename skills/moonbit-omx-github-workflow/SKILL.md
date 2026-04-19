---
name: moonbit-omx-github-workflow
description: Guide for repositories that combine MoonBit development, OMX orchestration, and GitHub PR/CI workflows when MoonBit-owned product surfaces are actually in scope. Do not force this skill for pure OMX/runtime or thin workflow-wrapper work that leaves MoonBit-owned product code unchanged.
---

# MoonBit + OMX + GitHub Workflow

Use this skill whenever the task spans any two or more of:
- MoonBit code or package structure
- OMX workflows and runtime setup
- GitHub Actions, PR automation, or CI work

If the task is only about OMX/runtime routing or only about a thin workflow wrapper, and MoonBit-owned product surfaces are unchanged, use the narrower lane instead.

## Layer Model

- MoonBit is the implementation and validation layer for the structured product substrate and MoonBit-backed CLI/product behavior, not every runtime boundary.
- OMX is the orchestration layer.
- GitHub Actions is the platform automation layer.

Do not collapse these layers into one another.

## Required Validation

For MoonBit-scoped code changes, or when the task explicitly asks for release/preflight proof, run and read:

```bash
moon check
moon test
moon fmt
moon info
```

Use `omx doctor` when validating OMX project readiness.
Use `CODEX_HOME=.codex codex login status` when validating repo-local Codex readiness.
Use `moon coverage analyze -- -f html -o coverage.html` when running the full preflight.

For GitHub workflows, validate locally as far as practical by:
- reading the workflow YAML
- ensuring referenced tools/actions exist and are spelled correctly
- confirming the local repo actually contains the files and commands the workflow expects

For pure workflow-wrapper changes that do not alter MoonBit-owned product surfaces, this local workflow validation may be sufficient without rerunning the full MoonBit lane.

## GitHub Workflow Expectations

This repo uses two workflow surfaces:

- `moonbit-ci.yml`
  - installs MoonBit
  - runs MoonBit validation commands for MoonBit-owned product surfaces and release/preflight readiness

- `codex-pr-review.yml`
  - runs Codex from GitHub Actions on PR events
  - posts feedback back to the PR

When editing PR-review workflows:
- keep permissions narrow
- avoid broad write access in the analysis job
- keep the prompt task-specific

This repo also uses:

- `.github/pull_request_template.md`
- `.github/ISSUE_TEMPLATE/development-task.md`

## OMX Expectations

Use OMX for:
- clarification
- planning
- parallel execution
- persistence and verification loops

Do not use OMX success alone as a completion signal when MoonBit-owned product surfaces are in scope.

Do not use MoonBit validation as the reflexive completion signal for pure OMX/runtime/hook/tmux/auth/wrapper issues that never touched MoonBit-owned product surfaces.

## Completion Standard

A task is ready for PR validation when:
- OMX project readiness is green
- MoonBit commands pass locally when MoonBit-owned product surfaces are in scope
- coverage report generation succeeds locally
- GitHub workflow files are present and internally coherent
- any non-local portion is clearly labeled as locally validated rather than executed live
