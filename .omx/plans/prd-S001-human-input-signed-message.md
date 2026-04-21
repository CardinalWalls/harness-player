# PRD Plan — S001-human-input-signed-message

Source story: `_mynot/3-plan/stories/S001-human-input-signed-message.md`

This file is the current Setup/Ralplan handoff artifact for S001. The story remains the authoritative scope. Implementation is intentionally out of scope for this artifact.

## Requirements Summary

Implement one signed-message input path:

`human text in browser/input surface` → signed `human_input` → actor consumes accepted human input

The story proves PRD Use case 2 and Architecture `human_input` boundaries: human-originated text must be signed by the human signer; browser/server/relay transport must not become the author; `/api/*` command payloads are not a valid success path.

## RALPLAN-DR Summary

### Principles

1. **Sender authority**: `human_input` is valid only when signed by the human signer.
2. **Browser non-authority**: browser/display may carry text but cannot author human or actor envelopes.
3. **One-way actor processing**: actor consumes accepted input and emits its own signed next envelope; it does not rewrite the human payload.
4. **Red-before-green evidence**: tester-agent contract must create failing tests and red evidence before coder-agent contract implementation.
5. **S000 preservation**: S001 must not weaken existing scene/action/effect validation.

### Decision Drivers

1. Story AC1-AC7 and all seven named failure modes must be machine-checkable.
2. `moon info && moon fmt --check && moon test` must pass in `moonbit/cdda_native_contract`.
3. Setup/Ralplan must leave explicit phase contracts for `tester-agent`, `auto_qc/qc`, `coder-agent`, and final QC.

### Viable Options

- Option A — Add MoonBit contract helpers only (`human_input_from_text`, actor consumption helper, audit projection) and no runtime/browser files.
  - Pros: smallest slice; directly tests signed-message boundary; avoids reintroducing `/api/*` or browser authority.
  - Cons: browser UI remains unimplemented until a later story.
- Option B — Add minimal browser/input adapter now plus MoonBit contract helpers.
  - Pros: closer to PRD user-facing path.
  - Cons: larger scope; risks mixing input transport/UI with domain contract; increases shortcut-regression surface.

Decision: choose Option A for S001. Defer browser/input adapter to a later story unless tester phase proves a static adapter check is necessary. This keeps S001 to one signed-message causal path.

## Acceptance Criteria

- AC1: `human_input_from_text` or equivalent returns a `SignedEnvelope` on channel `human_input`, signed by the human signer, preserving text and optional visible context reference.
- AC2: actor-side consumption helper accepts only valid human-signed `human_input` and emits an actor-signed response/decision causally linked to the input id.
- AC3: browser transport metadata cannot replace the human signer or author an agent envelope.
- AC4: `/api/*` command payloads or browser-authored progress messages are rejected or absent from success.
- AC5: server, relay, browser, scene-reader, bridge, and actor signers claiming `human_input` are rejected before actor response.
- AC6: audit projection for accepted input/actor response exposes channel, signer, text/context, and causal ids.
- AC7: all existing S000 bootstrap tests remain green.

## Implementation Steps

1. **Tester phase (contract: `tester-agent`)**
   - Add blackbox MoonBit tests for accepted human input, actor consumption, audit provenance, and all failure modes.
   - Save failing run to `.omx/evidence/S001-red-tests.log`.
   - Report tester claims and run `auto_qc/qc` before implementation.
2. **Coder phase (contract: `coder-agent`)**
   - Add minimal public contract API in `moonbit/cdda_native_contract/cdda_native_contract.mbt`.
   - Reuse S000 signed envelope patterns and validation helpers.
   - Regenerate `pkg.generated.mbti` with `moon info`.
   - Save green run to `.omx/evidence/S001-green-tests.log`.
   - Report coder claims and run `auto_qc/qc`.
3. **Final verification**
   - Run `moon info && moon fmt --check && moon test`.
   - If `scripts/` or `web/` are touched, run a static shortcut scan for `/api/*` progress and server-authored message paths.

## Risks and Mitigations

- Risk: over-scoping into UI/browser work. Mitigation: keep S001 contract-only unless tests require a static transport artifact.
- Risk: actor response helper becomes a full strategy engine. Mitigation: implement minimal actor acknowledgement/decision with required causation only.
- Risk: fake tests pass against existing generic `signed_envelope`. Mitigation: tester QC must verify tests fail before implementation because named helper/validation behavior is missing.
- Risk: weakening S000 validation while adding shared helpers. Mitigation: keep existing S000 tests and AC7 regression explicit.

## Verification Steps

```bash
cd moonbit/cdda_native_contract
moon info && moon fmt --check && moon test
```

Required evidence files:

- `.omx/evidence/S001-red-tests.log`
- `.omx/evidence/S001-tester-qc.md` or equivalent PROGRESS note
- `.omx/evidence/S001-green-tests.log`
- `.omx/evidence/S001-coder-qc.md` or equivalent PROGRESS note

## ADR

- Decision: implement S001 as a MoonBit contract slice for signed `human_input` plus actor consumption.
- Drivers: PRD Use case 2, Architecture `human_input` channel, anti-`/api/*` shortcut requirements, explicit conduct phase evidence.
- Alternatives considered: include browser/input adapter now; rejected as broader than the single causal path.
- Why chosen: smallest testable slice after S000 that proves a new independent signed-message channel.
- Consequences: later story must add user-facing browser input if needed; S001 only proves the domain boundary.
- Follow-ups: after S001, choose between browser input adapter, live scene-reader runtime, or save/restore based on PROGRESS.

## Available-Agent-Types Roster and Follow-up Staffing Guidance

- `test-engineer`: execute tester-agent contract and red-test evidence.
- `verifier`: run tester QC/coder QC claim-vs-reality checks.
- `executor`: execute coder-agent contract after tester QC passes.
- `architect`: review boundary compliance if implementation touches browser/server/runtime files.

Recommended execution path: sequential `tester-agent` -> `auto_qc/qc` -> `coder-agent` -> `auto_qc/qc`. Do not use `$team` unless future scope adds independent runtime/browser lanes.

## Launch Hints

Testing phase prompt shape:

```text
tester-agent contract for _mynot/3-plan/stories/S001-human-input-signed-message.md; write failing tests only; save .omx/evidence/S001-red-tests.log; stop before implementation.
```

Implementation phase prompt shape:

```text
coder-agent contract for _mynot/3-plan/stories/S001-human-input-signed-message.md after tester QC passes; implement only enough to make S001 + S000 tests green; save .omx/evidence/S001-green-tests.log.
```

## Team Verification Path

Team mode is not recommended for S001. If forced, one lane owns tests, one lane owns implementation, and verifier must prove tester red evidence predates implementation before merge.
