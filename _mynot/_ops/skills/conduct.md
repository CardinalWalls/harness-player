# Conduct — Ralph-Loop Playbook for the 5-Layer Pipeline (this repo)

> This file is **not a skill you invoke**. It is the **playbook `$ralph` reads
> every iteration** when driving a story through the five-layer pipeline.
>
> Installed to `~/.codex/skills/conduct/SKILL.md` via `_mynot/_ops/install-skillset.sh`.
> Edit **this file** (in the repo) and reinstall; never edit the installed copy.

## Prime contract (read first, every iteration)

One iteration = **one phase**. Full stop.

1. Read `PROGRESS.md` at the repo root.
2. If `STORY-DONE: <id>` already present at the file's bottom for the
   selected story → exit immediately; ralph treats this as the completion
   promise and stops the loop.
3. Before anything else: scan `Upstream Gaps` in `PROGRESS.md`. If any row has
   status ≠ `routed`, **this iteration's only job** is to route that lesson
   upstream (see §Rewind), then exit. Do not touch the current phase.
4. Otherwise, identify the **first unchecked `[ ]` phase** in the selected
   story's `Phase Progress` list. That is this iteration's phase.
5. Do that phase per the table below. Produce exactly the artifact listed. Do
   not produce artifacts for any other phase.
6. Run the §3 freeze checklist for that phase (from `_mynot/AGENTS.md §3`).
   - All items satisfied → mark phase `[x]`, update `Last Updated`,
     append a one-line note to the story's `Notes:` segment, exit iteration.
   - Any item failing → rewrite the artifact to fix, re-run checklist.
     Up to **3 attempts per iteration**. After 3 failed attempts, move the
     story to `Blocked` with the failure reason, append
     `STORY-BLOCKED: <id>` at the file's bottom, exit. Ralph will stop.
7. If the story's last phase just became `[x]`, move the story from
   `Current Work` to `Completed`, append `STORY-DONE: <id>` at the bottom of
   `PROGRESS.md`, exit.

**The Stop hook of `$ralph` restarts this whole prompt on the next turn.**
Each restart is a fresh iteration that picks up at the next unchecked phase.

## Story selection

- Exactly one entry under `Current Work` → that's the story.
- Zero or multiple → this is a user-level error. Write a one-line note to
  `PROGRESS.md` → `Notes:` on the first entry (or create a blocker if zero) →
  exit with `STORY-BLOCKED: user-setup` at the bottom. Do not try to pick.

## Phase table (what each phase produces, and how you know it's done)

Phase | Artifact (exact path) | Source of content | Freeze gate (§3) | Failure → Blocked reason
---|---|---|---|---
**Design** | `_mynot/1-intent/PRD.md` **and** `_mynot/1-intent/MOCK-EXPECTED-RESULT.md` (both required) | The story's `Details` in `PROGRESS.md` + `_mynot/0-bigger-project-context.md` + `_mynot/1-intent/README.md` guardrails | `_mynot/AGENTS.md §3 Layer 1` — 8 mechanical items; all green → auto `[x]`, **no human-confirm step** | "PRD/MOCK missing N of 8 freeze items: <list>"
**Architecture** | `_mynot/2-architecture/ARCHITECTURE.md` | `_mynot/1-intent/PRD.md` **only**. Do not peek at `_mynot/1.md` or Layer 0. | `_mynot/AGENTS.md §3 Layer 2` (channel table, trust chain per channel, bootstrap path, browser role, commit/restore semantics, every conclusion cites a Layer-1 principle) | "Arch missing N of 7 freeze items: <list>"
**Story** | `_mynot/3-plan/stories/S<NUM>-<slug>.md` | PRD + ARCHITECTURE. **Only one story at a time.** | `_mynot/AGENTS.md §3 Layer 3` (AC machine-testable, Layer-2 refs, upstream-dependency list, failure-mode list) | "Story missing N of 5 freeze items: <list>"
**Setup** | `.omx/plans/prd-<slug>.md` + `.omx/plans/test-spec-<slug>.md` (both) + `git worktree add` branch `S<NUM>-<slug>` off `main` | Mechanical conversion of the story: `prd-*.md` = story's Design + AC section; `test-spec-*.md` = story's test-plan + failure-mode section. | Both files exist and are non-empty; branch exists in `git worktree list`. | "Setup could not produce plans or branch: <git/fs error>"
**Testing** + **Implementation** (one combined phase in this repo) | Code + tests under the branch, committed. All tests green. | The two `.omx/plans/*.md` files. This phase runs TDD inline: for each AC write failing test, commit, implement minimum code to pass, commit, iterate. **Do not** write code before the test for that AC exists and fails. | `make test` (or equivalent) passes; every AC in the story has ≥1 test; no `TODO` / `NotImplemented` / `placeholder` in new code; every `failure-mode` listed in the story has ≥1 test. | "Test+Impl blocked after 3 failed TDD cycles on AC #<n>: <last test output tail>"
**Quality Check** | A QC report appended to the story's `Notes:` in `PROGRESS.md` | Run the `qc` skill's checklist against the branch HEAD. Plus repo-specific anti-patterns: no server-side channel-jsonl writes, no browser `/api/*`, no `reach_playable()`-style bootstrap shortcuts (see `_mynot/_debug/error_MCP.md` for the full anti-pattern list). | QC says pass. | "QC failed: <category>: <first offending file:line>"
**Dev Testing** | none | — | skip | — (auto-mark `[x]` with note `n/a (local demo)`)
**CI/CD** | A PR opened via `gh pr create --base main --head S<NUM>-<slug>`. | The branch HEAD. | PR is open and not in error state. Do **not** merge; user merges. | "gh pr create failed: <output>"

## Freeze gate execution (mechanical, not "ask user")

Each `_mynot/AGENTS.md §3 Layer N` checklist is a list of checkbox items. For
each item, you either:

- Can verify mechanically (e.g., "contains 5 use cases" → count `### 用例 \d+`
  headings) → run the check. Item passes or fails deterministically.
- Cannot verify mechanically (e.g., "uses only allowed vocabulary") → scan
  the artifact for the disallowed terms listed in the §3 bullet (e.g.,
  "writer", "tmux session", "MoonBit constructor" are Layer-1 disallowed).
  If any hit → item fails. If none → item passes.

**There is no "ask the human to confirm freeze" step.** If you want a human
to have veto power, the human adds a row to `Upstream Gaps` in `PROGRESS.md`
before the next iteration — which the prime contract step 3 honors.

### Root-AGENTS Intent-Freeze carve-out (authoritative)

Root `/AGENTS.md §Intent Freeze & Mock-First Contract` step 3 requires
"explicit user confirmation". For this layered workspace, that confirmation
is **discharged mechanically** by passing the §3 Layer-N checklist in
`_mynot/AGENTS.md`. Human approval is summoned only when a story ends with
`STORY-BLOCKED: <id>` — i.e., the human is pulled in only when machine checks
have already failed and there is a concrete, named thing to fix.

If you (the iteration agent) catch yourself adding a "Waiting on: user
confirmation" line to `PROGRESS.md`, or a "please confirm Design freeze"
prompt anywhere — **stop**. That means one of the §3 items is genuinely
vague and you're papering over it with a human. Fix the §3 item, do not
re-introduce the human gate.

## Rewind (when `Upstream Gaps` has an unrouted row)

Unrouted row looks like:
```
| # | Found-in | Missing-upstream-item | Target-location | routed? |
| 1 | Layer-3 story | "消息必须由真正发出者签名" not in PRD | `_mynot/1-intent/PRD.md §Trust` | no |
```

This iteration:

1. Open the `Target-location` file.
2. Add the missing item verbatim (one sentence, no re-argumentation).
3. Mark the row `routed: yes` in `PROGRESS.md`.
4. Uncheck `[x]` on the downstream phase named in `Found-in` (so next
   iteration re-does it against the now-patched upstream).
5. Exit.

If three iterations in a row are consumed by rewinds on the same gap, move
the story to `Blocked` with that gap's text as the reason and write
`STORY-BLOCKED: <id>` — the gap is structural and needs a human.

## What you never do inside a single iteration

- Work on more than one phase.
- Modify an artifact that belongs to a layer other than this iteration's.
- "Freeze" the phase without running the §3 checklist.
- Merge the PR.
- Write to `_mynot/PROGRESS.md` (that path is deprecated; the real one is at
  repo root).
- Touch `_mynot/0-bigger-project-context.md` or `_mynot/1.md`
  (both are read-only; `_mynot/1.md` is pending archive to `_mynot/_legacy/`).

## Completion marker (the thing ralph watches for)

At the very bottom of `PROGRESS.md`, after the `Usage Guidelines` section,
there's a single line that is the completion promise. Normally absent.
When a story finishes successfully, append:

```
STORY-DONE: <story-id>
```

When a story is blocked past recovery, append:

```
STORY-BLOCKED: <story-id>
```

The `$ralph` task the user starts this with has its `completion-promise`
match either of those prefixes, so the outer loop stops as soon as one
appears. Do **not** write these prefixes anywhere else in the file (no
historical "previous story done" bookkeeping there — move completed stories
into the `Completed` section instead).

## Tie-in with root `/AGENTS.md` keyword gates

Root `/AGENTS.md` `<keyword_detection>` has a **Ralph / Ralplan execution gate**
requiring `.omx/plans/prd-*.md` + `.omx/plans/test-spec-*.md` to exist before
implementation. This repo's Setup phase **produces** those files (row 4 of
the phase table above), so by the time Testing+Implementation phase runs,
the gate is satisfied. If the gate blocks anyway, the root AGENTS gate and
this playbook disagree — treat root AGENTS as authoritative and mark
Testing+Implementation as `Blocked` with reason `"plans produced but ralph
runtime still blocks gate; see root AGENTS <keyword_detection>"`.
