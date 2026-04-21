# Test Spec: S000 Bootstrap scene-reader signed-message chain

## Test Scope

Primary verification is MoonBit blackbox contract testing in `moonbit/cdda_native_contract/cdda_native_contract_test.mbt`. Python/browser checks are unnecessary unless those files are modified.

## Required Red Tests

1. `signed bootstrap: first observation is scene-reader authored`
   - Input: raw screen id/text.
   - Expected: `scene_observation` envelope, signer `scene-reader`, role `scene-reader`, raw evidence cited, non-empty signature.

2. `signed bootstrap: actor decision consumes valid observation`
   - Input: valid scene-reader observation.
   - Expected: `action_decision` envelope, signer `actor`, causation contains observation id.

3. `signed bootstrap: wrong scene observation authors are rejected`
   - Input: envelopes claiming `scene_observation` from browser, relay/server, human, bridge.
   - Expected: `ContractError` before any decision.

4. `signed bootstrap: bridge reports effect without becoming strategist`
   - Input: valid actor decision.
   - Expected: `action_effect` signed by action bridge, linked to decision; bridge-authored `action_decision` rejected.

5. `signed bootstrap: next observation closes loop`
   - Input: valid action effect and next raw screen evidence.
   - Expected: second `scene_observation` signed by scene-reader and linked to effect id.

6. `signed bootstrap: browser remains non privileged`
   - Input: browser/human signers attempting agent channels and/or `/api/*` progress payload.
   - Expected: rejected; not counted as accepted chain progress.

7. `signed bootstrap: audit projection explains causal chain`
   - Input: four accepted envelopes.
   - Expected: projection rows preserve channel, signer, and predecessor ids; chain valid.

## Failure-Mode Coverage Matrix

| Failure mode | Required test evidence |
|---|---|
| `server-authored-scene-observation` | wrong author rejection includes relay/server signer on `scene_observation` |
| `browser-api-progress` | browser `/api/*` payload/signer cannot author an accepted scene/action envelope |
| `browser-authored-agent-message` | browser/human signer rejected for `scene_observation`, `action_decision`, `action_effect` |
| `scripted-screen-authority` | scripted/parser-authoritative payload without raw evidence is rejected |
| `missing-causation` | decision/effect/next observation constructors reject missing predecessor ids |
| `bridge-as-strategist` | bridge signer cannot produce accepted `action_decision` |

## Verification Commands

Run in `moonbit/cdda_native_contract`:

```bash
moon info && moon fmt && moon test
```

Completion evidence must include the passing command output and the generated `pkg.generated.mbti` diff when public API changes.
