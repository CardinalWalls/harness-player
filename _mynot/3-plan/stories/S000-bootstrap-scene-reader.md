# Story: S000 Bootstrap scene-reader signed-message chain

**Status**: ready-for-ralplan  
**Epic**: CDDA signed-message test bench  
**Story ID**: S000-bootstrap-scene-reader  
**Depends On**: Layer 1 PRD freeze; Layer 2 Architecture freeze  
**Upstream dependency**: `_mynot/2-architecture/ARCHITECTURE.md` §§3, 4, 5, 6, 7, 9, 10

---

## User Story

As a reviewer, I want the first CDDA bootstrap loop to be represented as signed envelopes from the real scene-reader, actor, and action bridge, so that the browser/audit surface can prove game-visible progress was not produced by a relay, browser command, or scripted shortcut.

---

## Scope

This story implements one causal chain only:

`scene_observation` → `action_decision` → `action_effect` → next `scene_observation`

The story does not implement full save/restore. It must not add new Layer 2 components or new channels beyond the Architecture channel catalog.

---

## Acceptance Criteria

### AC1: Scene-reader authors first observation
**Given** a raw screen reference and screen text from the scenario **When** the scene-reader creates the first bootstrap record **Then** the output is a `scene_observation` signed envelope whose signer is the scene-reader actor, whose payload cites the raw screen reference, and whose channel/signer mapping is valid.

### AC2: Actor decision consumes only accepted scene observation
**Given** a valid scene-reader-signed `scene_observation` **When** the actor chooses the next bootstrap action **Then** the output is an `action_decision` signed envelope causally linked to the observation.

### AC3: Wrong upstream author is rejected
**Given** a browser-, relay-, server-, human-, or bridge-signed envelope claiming to be a scene observation **When** the actor tries to create an action decision from it **Then** the contract rejects it before producing any decision.

### AC4: Action bridge reports effect without becoming strategist
**Given** a valid actor-signed `action_decision` **When** the bridge applies the action **Then** it publishes an `action_effect` signed by the bridge and causally linked to the decision, without changing the decision author.

### AC5: Next scene observation closes the bootstrap loop
**Given** a valid bridge-signed `action_effect` and new screen reference **When** the scene-reader observes again **Then** the next `scene_observation` is scene-reader-signed and causally linked to the action effect.

### AC6: Browser remains non-privileged in this story
**Given** the browser/human input path exists **When** tests and implementation validate the bootstrap loop **Then** no success path relies on browser `/api/*` progress calls, browser-authored scene observations, or browser-authored action decisions.

### AC7: Audit projection can explain the causal chain
**Given** the four accepted envelopes in the bootstrap chain **When** the audit view/projection is built **Then** it lists channel, signer, and causal predecessor for each accepted envelope and identifies the chain as valid.

---

## Technical Context

### Tech stack and versions

- MoonBit package: `moonbit/cdda_native_contract/moon.mod.json` name `yetian/cdda_native_contract`, version `0.1.0`.
- MoonBit tests: blackbox tests in `moonbit/cdda_native_contract/*_test.mbt`; whitebox tests in `*_wbtest.mbt`.
- Python dashboard/runtime surface: Python 3 standard library scripts under `scripts/`; no new dependency may be added for this story.
- Browser surface: `web/index.html` plus data emitted by `scripts/cdda_web_server.py` if needed for audit projection.

### File locations

Primary implementation files:

- `moonbit/cdda_native_contract/cdda_native_contract.mbt` — domain contract types and constructors.
- `moonbit/cdda_native_contract/cdda_native_contract_test.mbt` — required failing-first then passing contract tests.
- `moonbit/cdda_native_contract/cdda_native_contract_wbtest.mbt` — optional internal helper invariant tests.
- `moonbit/cdda_native_contract/pkg.generated.mbti` — regenerated via `moon info`; do not hand-edit.

Optional integration/audit files only if needed to satisfy AC6-AC7:

- `scripts/cdda_web_server.py` — must not synthesize accepted channel messages for another actor.
- `web/index.html` — render-only changes for signer/causal metadata.

### Existing pattern references

- Constructor validation pattern: `moonbit/cdda_native_contract/cdda_native_contract.mbt` functions `action_intent_from_scene` and `action_result_from_intent`.
- Rejection test pattern: `moonbit/cdda_native_contract/cdda_native_contract_test.mbt` test `writer constructors: reject invalid upstream channel`.
- Section/projection helper pattern: `section_ids_for_channel` and `default_sections` in `moonbit/cdda_native_contract/cdda_native_contract.mbt`.
- MoonBit local guide: `moonbit/cdda_native_contract/AGENTS.md` requires `moon info && moon fmt`, then `moon test`.

### Required domain names from Layer 2

Use these Architecture channel names in new public APIs and tests:

- `scene_observation`
- `action_decision`
- `action_effect`
- `human_input` only for negative/non-privileged browser checks in this story
- `audit_finding` only if an explicit audit projection type is added

### Suggested public shape

Keep APIs concise. If replacing older names, preserve compatibility only if tests require it; prefer a direct Layer 2 vocabulary for this story.

- `SignedEnvelope`: fields from Architecture §3 (`id`, `channel`, `signer_actor_id`, `signer_role`, `causation_ids`, `correlation_id`, `payload`, `signature`).
- `scene_observation_from_raw(...) -> SignedEnvelope`
- `action_decision_from_scene(...) -> Result[SignedEnvelope, ContractError]`
- `action_effect_from_decision(...) -> Result[SignedEnvelope, ContractError]`
- `next_scene_observation_from_effect(...) -> Result[SignedEnvelope, ContractError]`
- `audit_chain(...) -> Result[...]` or equivalent projection helper for AC7.

---

## Failure Modes (must be tested)

1. `failure-mode: server-authored-scene-observation` — any relay/server-authored envelope claiming `scene_observation` is rejected.
2. `failure-mode: browser-api-progress` — browser `/api/*` command progress cannot be used as a valid bootstrap success path.
3. `failure-mode: browser-authored-agent-message` — browser/human signer cannot author `scene_observation`, `action_decision`, or `action_effect`.
4. `failure-mode: scripted-screen-authority` — payloads marked as scripted/parser-authoritative are not sufficient unless the signer is the scene-reader actor and the envelope cites raw screen evidence.
5. `failure-mode: missing-causation` — decisions/effects/next observations without required predecessor ids are rejected.
6. `failure-mode: bridge-as-strategist` — bridge cannot author `action_decision`.

---

## Tasks

### Task 1: Lock red tests for signed bootstrap chain (AC: 1-7)
- [ ] Add/replace tests in `moonbit/cdda_native_contract/cdda_native_contract_test.mbt` for accepted chain construction.
- [ ] Add rejection tests for all failure modes listed above.
- [ ] Tests must fail before implementation changes.

### Task 2: Implement Layer 2 envelope contract (AC: 1-5)
- [ ] Add signed envelope and payload/projection fields in `moonbit/cdda_native_contract/cdda_native_contract.mbt`.
- [ ] Implement role-specific constructors and upstream validation.
- [ ] Ensure wrong signer/channel/causation returns `ContractError`.

### Task 3: Add audit projection (AC: 7)
- [ ] Provide a MoonBit projection helper or section view that exposes channel, signer, and predecessor ids.
- [ ] Keep projection read-only: it explains accepted envelopes but does not make invalid chains valid.

### Task 4: Guard browser/server shortcut paths (AC: 6)
- [ ] If touching `scripts/cdda_web_server.py`, remove or quarantine any path that writes accepted channel messages for another actor.
- [ ] If touching `web/index.html`, keep it render/input only; no privileged `/api/*` progress path may be required for story success.
- [ ] Add tests or static checks demonstrating the story success path is the MoonBit signed chain, not browser/server synthesis.

### Task 5: Regenerate and format (Definition of Done)
- [ ] Run `moon info` in `moonbit/cdda_native_contract` or from its module root.
- [ ] Run `moon fmt`.
- [ ] Run `moon test`.

---

## Test Scenarios

### Test strategy

**Coverage**: MoonBit unit/contract tests first; optional Python static/integration checks only if runtime files are touched.  
**Complexity**: Moderate causal-chain state validation.

### Required tests

| Test Case | AC | Input | Expected |
|---|---|---|---|
| First scene observation is scene-reader signed | AC1 | raw screen id/text | `scene_observation` envelope with scene-reader signer and raw evidence |
| Actor decision accepts valid observation | AC2 | valid observation | `action_decision` envelope linked to observation id |
| Actor rejects wrong scene signer | AC3 | human/browser/server/bridge signer on scene channel | `ContractError` |
| Bridge effect accepts actor decision | AC4 | valid decision | `action_effect` envelope linked to decision id |
| Bridge cannot author decision | AC4, failure-mode 6 | bridge signer in decision constructor | `ContractError` |
| Next observation links to bridge effect | AC5 | valid effect + new screen | next `scene_observation` causally linked to effect id |
| Missing causation rejected | failure-mode 5 | envelope with empty predecessor where required | `ContractError` |
| Scripted/parser authority rejected | failure-mode 4 | payload/evidence marked scripted/parser-authored as authoritative | `ContractError` or invalid audit finding |
| Browser path remains non-privileged | AC6 | browser/human signer attempts agent channels | rejected and not counted as success |
| Audit projection lists chain | AC7 | four accepted envelopes | projection includes channel, signer, predecessor for each |

### Commands for verification

Run from `moonbit/cdda_native_contract/` unless tooling requires repo root:

```bash
moon info && moon fmt && moon test
```

---

## Anti-Patterns (do not do)

- ❌ Do not let a relay/server/browser author another actor's accepted envelope.
- ❌ Do not use browser `/api/*` commands as the bootstrap proof.
- ❌ Do not treat scripted or parsed screen text as authoritative unless the scene-reader signs an observation with raw evidence.
- ❌ Do not add a new component or channel that is not listed in Architecture §4.
- ❌ Do not make the action bridge decide strategy; it only applies signed decisions and reports effects.
- ❌ Do not hand-edit `pkg.generated.mbti`; regenerate it.
- ❌ Do not add external dependencies.

---

## Definition of Done

- [ ] Every acceptance criterion has at least one passing test or explicit audit/static check.
- [ ] Every failure-mode above has a corresponding test.
- [ ] `moon info`, `moon fmt`, and `moon test` complete successfully for `moonbit/cdda_native_contract`.
- [ ] `pkg.generated.mbti` changes, if any, match the new public contract.
- [ ] No server-side channel synthesis, browser `/api/*` progress path, or scripted-screen authority is required for success.
- [ ] The story remains scoped to the bootstrap scene-reader causal chain and does not implement unrelated save/restore work.
