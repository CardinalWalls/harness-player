# Ralplan: OMX Session Overlap And Keyword Routing

## Metadata

- Date: `2026-04-19`
- Context: [`omx-session-overlap-keyword-routing-20260419T103854Z.md`](/Users/yetian/Desktop/finall-start-100-commits/.omx/context/omx-session-overlap-keyword-routing-20260419T103854Z.md)
- Scope: repo-local OMX runtime behavior only
- Recommended execution lane: `$ralph`

## Problem

Multiple Codex/Desktop sessions share the same repo `.omx/state/` tree. Official OMX workflow activation and overlap checks read visible active workflow state from that shared tree. In practice this allows one thread's active `deep-interview` or `ralplan` state to block another thread, even when the second thread is trying to continue its own local flow.

There is a second friction point: workflow names mentioned in ordinary explanatory text can still be caught by keyword routing, which creates fresh mode state in contexts where the user was discussing the mode rather than intentionally activating it.

## Evidence

- The repo hook order in [.codex/hooks.json](/Users/yetian/Desktop/finall-start-100-commits/.codex/hooks.json) runs the official native OMX hook before any repo-local follow-through.
- Installed OMX keyword routing seeds tracked mode state in [`keyword-detector.js`](/opt/homebrew/lib/node_modules/oh-my-codex/dist/hooks/keyword-detector.js).
- Installed transition checks deny most tracked-mode overlaps and only allow specific auto-complete transitions in [`workflow-transition.js`](/opt/homebrew/lib/node_modules/oh-my-codex/dist/state/workflow-transition.js).
- Transition reconciliation reads both session-scoped and root-scoped state visibility in [`workflow-transition-reconcile.js`](/opt/homebrew/lib/node_modules/oh-my-codex/dist/state/workflow-transition-reconcile.js).
- Recent repo logs show this thread being blocked by mode state associated with other sessions under [.omx/logs/turns-2026-04-19.jsonl](/Users/yetian/Desktop/finall-start-100-commits/.omx/logs/turns-2026-04-19.jsonl).

## Principles

1. Session intent beats repo-global residue for planning modes.
2. Preserve official OMX mode names and handoff order.
3. Prefer repo-local interception over patching installed upstream code.
4. Keep execution modes durable, but keep planning-mode visibility narrow.
5. Make accidental activation harder than intentional activation.

## Decision Drivers

- Stop cross-session blocking for `deep-interview` and `ralplan`.
- Preserve the valid same-thread handoff `deep-interview -> ralplan`.
- Avoid breaking the current repo-local `autopilot` follow-through work.

## Viable Options

### Option A: Keep current behavior and rely on manual cleanup

Pros:
- No code changes.
- Stays closest to current upstream behavior.

Cons:
- Keeps the exact failure mode the user is hitting.
- Requires frequent `omx state clear` cleanup.
- Makes ordinary discussion about modes unsafe because keyword routing can still fire.

### Option B: Make all tracked workflow modes session-local in repo-local behavior

Pros:
- Strongest isolation.
- Simplest mental model for interactive threads.

Cons:
- Risks breaking the durability/visibility expectations of execution modes such as `team` and `ralph`.
- May diverge too far from upstream runtime assumptions.

### Option C: Session-first planning visibility, preserve durable execution visibility

Summary:
- Treat `deep-interview`, `ralplan`, and `autoresearch` as session-first planning modes.
- Continue allowing durable execution modes to retain broader visibility where needed.
- Add repo-local activation guards so plain mentions of workflow names do not create new mode state unless they look like an intentional command.

Pros:
- Solves the user-facing planning friction without rewriting the whole runtime model.
- Preserves the official operator flow and repo-local `autopilot` bridge work.
- Matches the actual difference between clarification/planning lanes and durable execution lanes.

Cons:
- Slightly more complex than a blanket rule.
- Requires careful repo-local interception and verification.

## Decision

Choose **Option C**.

## ADR

### Decision

Adopt a repo-local session-first policy for planning-like OMX modes while leaving durable execution modes compatible with broader runtime visibility.

### Drivers

- Planning modes are the ones currently causing unwanted cross-thread blockage.
- The repo already distinguishes planning and execution lanes in practice.
- A repo-local fix is safer than modifying installed upstream OMX files.

### Alternatives Considered

- Manual cleanup only: rejected because it does not remove the underlying friction.
- Full session-only isolation for every mode: rejected because it risks harming `team` / `ralph` durability semantics.

### Why Chosen

It is the smallest repo-local change set that directly addresses the observed failure while preserving the repository's preferred official workflow surface.

### Consequences

- Planning-mode activation logic becomes stricter and more intentional.
- Some repo-local wrapper logic will need to distinguish planning modes from execution modes.
- Verification must cover both accidental mention cases and valid same-thread handoff cases.

### Follow-Ups

- Patch repo-local prompt-routing guards.
- Add explicit verification cases and a short operator note.
- Only if repo-local guards prove insufficient, consider a deeper local shim around visible-mode reads.

## Execution Plan

1. Add a repo-local command-shape guard before honoring workflow-name mentions for planning modes.
2. Add a repo-local session-affinity guard so `deep-interview` and `ralplan` only block the current thread when their active state belongs to the same session/thread lineage.
3. Preserve same-thread auto-complete for `deep-interview -> ralplan`.
4. Leave `team`, `ralph`, and existing `autopilot` follow-through semantics unchanged unless verification shows they still inherit the same planning-state bug.
5. Document the new rule in tracked docs so future debugging does not regress into blind `state clear` cleanup.

## Concrete Touchpoints

- `.codex/hooks.json`
- `scripts/autopilot-userprompt-followthrough.mjs`
- repo-local OMX helper scripts under `scripts/`
- tracked docs in `docs/discussions/` or `docs/plans/`

## Acceptance Criteria

- A plain explanatory sentence mentioning `ralplan` or `deep-interview` does not activate a workflow unless it is command-shaped.
- A `deep-interview` active in thread A does not block a new planning action in thread B by default.
- A same-thread `deep-interview -> ralplan` handoff still succeeds without manual cleanup.
- Existing repo-local `autopilot` follow-through still works after the planning-mode guard is added.
- The fix is documented with a verification recipe.

## Verification

1. In one thread, activate `deep-interview`; in another thread, discuss the mode in plain text and confirm no unintended activation occurs.
2. In one thread, activate `deep-interview`; in another thread, intentionally activate `ralplan` and confirm it is not blocked by unrelated planning residue.
3. In the same thread, run the valid `deep-interview -> ralplan` handoff and confirm it still transitions.
4. Trigger repo-local `autopilot` follow-through and confirm no regression in its current bridge behavior.
5. Inspect `.omx/state/` and `.omx/logs/turns-*.jsonl` to confirm the visible state matches the intended thread/session.

## Risks

- Repo-local guards may mask real upstream bugs instead of fixing them at the source.
- If the guard is too aggressive, it may suppress legitimate intentional activations.
- If the guard is too weak, cross-session planning interference will remain.

## Staffing Guidance

- Preferred: `$ralph` with medium-high reasoning.
  Reason: this is a sequential runtime-behavior fix with careful verification and low benefit from parallel work.
- Optional: `$team` only if split into disjoint lanes:
  - Lane 1: hook/guard implementation
  - Lane 2: verification harness and docs
  - Lane 3: log/state observability review

## Suggested Next Step

Use `$ralph` to implement the repo-local planning-mode guard and verify it against the acceptance criteria above.
