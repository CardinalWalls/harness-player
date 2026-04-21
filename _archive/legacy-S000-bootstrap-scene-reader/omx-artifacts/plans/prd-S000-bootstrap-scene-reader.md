# PRD Plan: S000 Bootstrap scene-reader signed-message chain

## Requirements Summary

Implement the frozen story `_mynot/3-plan/stories/S000-bootstrap-scene-reader.md` as a narrowly scoped MoonBit contract. The package must construct and validate a four-envelope bootstrap chain:

1. `scene_observation` signed by `scene-reader`
2. `action_decision` signed by `actor`
3. `action_effect` signed by `action-bridge`
4. next `scene_observation` signed by `scene-reader`

The accepted chain must be explainable through an audit projection containing channel, signer, and causal predecessor ids. Browser/server/relay/human/scripted shortcuts must not count as valid bootstrap progress.

## RALPLAN-DR Summary

### Principles

1. The signer is the authority: accepted envelopes are valid only when the channel is authored by its Layer-2 publisher.
2. Causality is explicit: each downstream envelope must cite its required predecessor id.
3. Browser and relay remain non-privileged: they may display or carry data, but cannot author agent channels.
4. Tests lock the anti-shortcuts first: every story failure-mode receives a direct rejection test.
5. Keep compatibility small: older relation/section helpers may remain, but the new story should use Layer-2 channel vocabulary directly.

### Decision Drivers

1. Story AC1-AC7 and six named failure modes must be machine-checkable.
2. `moon info && moon fmt && moon test` must pass inside `moonbit/cdda_native_contract`.
3. Implementation must avoid adding non-MoonBit runtime dependencies or widening into save/restore.

### Viable Options

- Option A — Add a new signed-envelope API alongside existing snapshot helpers.
  - Pros: Small, reversible, avoids breaking existing tests, maps directly to Layer 2 names.
  - Cons: Temporarily leaves old vocabulary in the package until later cleanup stories.
- Option B — Replace the old `ChannelSnapshot` API entirely.
  - Pros: Removes drift sooner.
  - Cons: Larger blast radius, risks breaking existing section/projection behavior unrelated to S000.

Decision: Choose Option A for this story. Reject Option B because S000 is one causal chain and does not authorize broad cleanup.

## Acceptance Criteria

- AC1: `scene_observation_from_raw` returns a `SignedEnvelope` with channel `scene_observation`, signer actor id `scene-reader`, raw screen evidence, and a non-empty signature.
- AC2: `action_decision_from_scene` accepts only a valid scene-reader observation and links causation to that observation id.
- AC3: browser, relay/server, human, bridge, and other wrong signers on `scene_observation` are rejected before any decision is produced.
- AC4: `action_effect_from_decision` accepts only an actor-signed decision and publishes an action-bridge-signed effect without changing the decision author.
- AC5: `next_scene_observation_from_effect` accepts only a valid bridge-signed effect and links to it.
- AC6: browser/human signers cannot author `scene_observation`, `action_decision`, or `action_effect`; no browser `/api/*` path is part of the success proof.
- AC7: `audit_chain` returns read-only rows for the accepted four-envelope chain, listing channel, signer, predecessor ids, and valid status.

## Implementation Steps

1. Add blackbox MoonBit tests in `moonbit/cdda_native_contract/cdda_native_contract_test.mbt` for the accepted chain and each named failure-mode.
2. Add public signed-envelope domain types and constructors in `moonbit/cdda_native_contract/cdda_native_contract.mbt`.
3. Add upstream validation helpers for channel, signer, raw evidence, scripted/parser authority, and required causation ids.
4. Add `audit_chain` projection that explains accepted envelopes without making invalid chains valid.
5. Regenerate interfaces and verify with `moon info && moon fmt && moon test`.

## Risks and Mitigations

- Risk: MoonBit syntax/type errors for arrays, structs, or Result matching. Mitigation: iterate using `moon test` output and keep changes localized.
- Risk: Over-scoping into web/server rewrites. Mitigation: satisfy AC6 with MoonBit rejection tests unless runtime files are already touched.
- Risk: Existing tests depend on older names. Mitigation: preserve existing public API and add new Layer-2 API alongside it.

## Verification Steps

Run from `moonbit/cdda_native_contract`:

```bash
moon info && moon fmt && moon test
```

Then inspect `git diff -- moonbit/cdda_native_contract/pkg.generated.mbti` to confirm generated public API changes match the story.

## ADR

- Decision: Add a new signed-envelope API beside the existing snapshot/section API.
- Drivers: Story scope, backward compatibility, direct Layer-2 vocabulary, anti-shortcut tests.
- Alternatives considered: Full replacement of old snapshot API; deferred because it is broader than S000.
- Why chosen: It proves the bootstrap chain without destabilizing unrelated existing tests.
- Consequences: A later cleanup story may remove or migrate old vocabulary once downstream stories no longer depend on it.
- Follow-ups: After S000, queue cleanup or runbook work only if PROGRESS opens that next story.

## Available-Agent-Types Roster and Follow-up Staffing Guidance

- `executor`: implement MoonBit contract and tests.
- `test-engineer`: verify failure-mode coverage and command evidence.
- `verifier`: final completion evidence and PROGRESS status.
- `architect`: review boundary compliance if code touches web/server or architecture-relevant paths.

For `$ralph`, use one sequential owner with optional verifier review because the write surface is small. For `$team`, split only if later stories add independent web/server lanes; S000 does not need team mode.

## Launch Hints

```bash
omx ralph --madmax "force: implement _mynot/3-plan/stories/S000-bootstrap-scene-reader.md using .omx/plans/prd-S000-bootstrap-scene-reader.md and .omx/plans/test-spec-S000-bootstrap-scene-reader.md; stop only after STORY-DONE or STORY-BLOCKED is appended to PROGRESS.md"
```

## Team Verification Path

Not recommended for this single-story implementation. If team mode is forced, final verifier must prove every failure-mode has a test and `moon info && moon fmt && moon test` passes.
