---
name: moonbit-omx-github-workflow
description: Guide for repositories that combine MoonBit development, OMX orchestration, and GitHub PR/CI workflows. Use when implementing MoonBit code, validating with `moon check` or `moon test`, wiring MoonBit work into OMX workflows like deep-interview, ralplan, team, or ralph, or maintaining GitHub Actions for MoonBit CI and Codex PR review.
---

# MoonBit + OMX + GitHub Workflow

Use this skill whenever the task spans any two or more of:
- MoonBit code or package structure
- OMX workflows and runtime setup
- GitHub Actions, PR automation, or CI work

## Layer Model

- MoonBit is the implementation and validation layer.
- OMX is the orchestration layer.
- GitHub Actions is the platform automation layer.

Do not collapse these layers into one another.

## Required Validation

For code changes, run and read:

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

## GitHub Workflow Expectations

This repo uses two workflow surfaces:

- `moonbit-ci.yml`
  - installs MoonBit
  - runs MoonBit validation commands

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

Do not use OMX success alone as a completion signal. Always return to MoonBit validation.

## Completion Standard

A task is ready for PR validation when:
- OMX project readiness is green
- MoonBit commands pass locally
- coverage report generation succeeds locally
- GitHub workflow files are present and internally coherent
- any non-local portion is clearly labeled as locally validated rather than executed live
