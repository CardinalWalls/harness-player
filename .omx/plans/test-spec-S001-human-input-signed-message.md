# Test Spec — S001-human-input-signed-message

Source story: `_mynot/3-plan/stories/S001-human-input-signed-message.md`

This file is the current test handoff artifact. Tests must be written red-first under the `tester-agent` contract before any implementation changes.

## Test Scope

Primary verification is MoonBit blackbox contract testing in `moonbit/cdda_native_contract/cdda_native_contract_test.mbt`.

Runtime/browser files should remain untouched unless the tester proves a static adapter check is necessary. If touched, they must be display/input transport only.

## Required Red Tests

1. `human input: text creates human-signed envelope`
   - Input: non-empty text and optional visible context ref.
   - Expected: `human_input` envelope, human signer, payload preserves text/context, non-empty signature.

2. `human input: actor consumes accepted input`
   - Input: valid human-signed `human_input`.
   - Expected: actor-signed response/decision causally linked to input id.

3. `human input: browser signer is rejected`
   - Input: browser signer claiming channel `human_input`.
   - Expected: `ContractError` before actor response.

4. `human input: api command is not success path`
   - Input: payload containing `/api/progress`, `/api/human-instruction`, or equivalent privileged command marker.
   - Expected: rejected/absent as accepted human input.

5. `human input: wrong signers are rejected`
   - Input: server, relay, scene-reader, bridge, actor signers claiming `human_input`.
   - Expected: each rejected.

6. `human input: empty text rejected`
   - Input: empty or whitespace-only text.
   - Expected: `ContractError`.

7. `human input: actor response requires causation`
   - Input: actor response/decision without predecessor human input id.
   - Expected: `ContractError`.

8. `human input: audit projection shows provenance`
   - Input: accepted human input + actor response/decision.
   - Expected: projection exposes channel, signer, text/context reference, predecessor ids, and valid status.

9. `S000 regression: bootstrap tests still green`
   - Input: existing S000 suite.
   - Expected: all existing scene/action/effect tests pass unchanged.

## Failure-Mode Coverage Matrix

| Failure mode | Required test evidence |
|---|---|
| `browser-as-human-author` | browser signer on `human_input` rejected |
| `browser-api-command-input` | `/api/*` command payload rejected/absent from success |
| `server-authored-human-input` | relay/server signer on `human_input` rejected |
| `actor-self-instruction` | actor signer on `human_input` rejected |
| `missing-human-text` | empty/blank text rejected |
| `missing-causation` | actor response/decision without input predecessor rejected |
| `S000-regression` | existing S000 tests remain green |

## Tester QC Requirements

Before implementation, `auto_qc/qc` must verify:

- every AC maps to at least one red test;
- every failure mode maps to a red test;
- tests fail because S001 public helpers/validation are missing, not because of syntax or unrelated setup;
- tests do not assert implementation internals not required by the story;
- no implementation files are changed during tester phase except tests/evidence.

## Coder QC Requirements

After implementation, `auto_qc/qc` must verify:

- all red tests now pass without weakening assertions;
- implementation reuses S000 envelope patterns rather than bypassing validation;
- `pkg.generated.mbti` is regenerated if public API changes;
- no browser/server `/api/*` shortcut path is introduced;
- `moon info && moon fmt --check && moon test` passes.

## Verification Commands

Run in `moonbit/cdda_native_contract`:

```bash
moon info && moon fmt --check && moon test
```

If runtime/browser files are touched, also run from repo root:

```bash
grep -RIn "reach_playable\|/api/state\|/api/.*progress\|server-authored\|browser-authored" scripts web moonbit 2>/dev/null || true
```
