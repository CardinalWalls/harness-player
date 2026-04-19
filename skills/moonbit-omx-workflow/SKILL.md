---
name: moonbit-omx-workflow
description: Guide for using MoonBit inside an OMX-managed repository. Use when implementing MoonBit code, validating with `moon check`, `moon test`, `moon fmt`, or `moon info`, wiring MoonBit work into OMX workflows like deep-interview, ralplan, team, and ralph, or when a task explicitly asks for OMX and MoonBit compatibility.
---

# MoonBit + OMX Workflow

Use this skill whenever the repository is using both OMX and the MoonBit toolchain.

## Purpose

This skill keeps the two layers separate and compatible:
- OMX handles planning, orchestration, persistence, parallelism, and recovery.
- MoonBit commands provide the real implementation and validation signal.

## When To Use

- The task mentions MoonBit or `moon`
- The task mentions OMX plus MoonBit together
- The task needs `moon check`, `moon test`, `moon fmt`, or `moon info`
- The task wants to run `ralph`, `team`, or `autopilot` against MoonBit code

## Core Rule

Do not let OMX workflow success replace MoonBit tool success.

A task is only complete when the relevant MoonBit commands have actually passed.

## Default Validation Sequence

Run and read:

```bash
moon check
moon test
moon fmt
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

## Completion Rules

These do **not** count as completion:
- only editing files
- only passing an OMX plan/review stage
- only running `moon test --build-only`
- saying the code "should work"

These usually **do** count as completion:
- `moon check` passes
- `moon test` passes
- `moon fmt` executed cleanly
- `moon info` executed
- the result matches the user-requested scope

## Repo-local Notes

- Treat `skills/` as the source-of-truth for local custom skills.
- Treat any `.codex/skills/` mirror as local runtime setup, not tracked source.
- Do not modify `1 raw discussion about the scope/` unless the user explicitly asks.
