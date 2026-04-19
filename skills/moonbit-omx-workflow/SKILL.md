---
name: moonbit-omx-workflow
description: Guide for using MoonBit inside an OMX-managed repository when MoonBit-owned product code, package boundaries, or MoonBit-backed CLI behavior are actually in scope. Do not use this skill for pure OMX/runtime/hook/transport work that leaves MoonBit-owned surfaces untouched.
---

# MoonBit + OMX Workflow

Use this skill when the task genuinely spans OMX orchestration and MoonBit-owned product work.

## Purpose

This skill keeps the two layers separate and compatible:
- OMX handles planning, orchestration, persistence, parallelism, and recovery.
- MoonBit owns the structured product substrate where it materially helps:
  provenance, package/share semantics, capture normalization, topology/profile validation,
  extraction, and MoonBit-backed CLI behavior.

## When To Use

- The task mentions MoonBit or `moon`
- The task mentions OMX plus MoonBit together **and** MoonBit-owned product code is actually in scope
- The task needs `moon check`, `moon test`, `moon fmt --check`, or `moon info`
- The task changes MoonBit packages, MoonBit-backed CLI behavior, or MoonBit-owned substrate modules

Do **not** use this skill for:

- pure OMX/runtime/hook/tmux/transport bugs
- pure docs/config work about OMX routing
- thin GitHub wrapper changes that do not alter MoonBit-owned product surfaces

## Core Rule

Do not let OMX workflow success replace MoonBit tool success when MoonBit-owned product surfaces changed.

A MoonBit-scoped task is only complete when the relevant MoonBit commands have actually passed.

## Default Validation Sequence

Run and read this sequence when MoonBit-owned product surfaces changed or the task explicitly asks for MoonBit proof/preflight:

```bash
moon check
moon test
moon fmt --check
moon info
```

Add `moon run` only when the task has a runnable target.
Add `moon coverage` when coverage is requested or helpful.
Add `moon prove` only when proof is explicitly in scope.

## Workflow Mapping

- `deep-interview`: clarify the task and desired MoonBit outcome
- `ralplan`: plan the MoonBit implementation and verification path
- `team`: parallelize implementation/testing lanes, but converge on shared MoonBit validation
- `ralph`: keep iterating until MoonBit validation is green

If the issue is purely in OMX/runtime/hook/tmux/transport behavior, stay in the OMX/runtime lane first instead of forcing MoonBit validation.

## Completion Rules

These do **not** count as completion:
- only editing files
- only passing an OMX plan/review stage
- only running `moon test --build-only`
- saying the code "should work"

These may complete without rerunning MoonBit:

- pure OMX/runtime/hook/tmux/state fixes
- pure docs/config changes about orchestration
- GitHub wrapper/debug work that leaves MoonBit-owned product surfaces unchanged

These usually **do** count as completion:
- `moon check` passes
- `moon test` passes
- `moon fmt --check` passes
- `moon info` executed
- the result matches the user-requested scope

## Repo-local Notes

- Treat `skills/` as the source-of-truth for local custom skills.
- Treat any `.codex/skills/` mirror as local runtime setup, not tracked source.
- Do not modify `1 raw discussion about the scope/` unless the user explicitly asks.
