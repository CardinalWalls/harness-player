# Story: S001 Human input signed-message path

**Status**: ready-for-ralplan  
**Epic**: CDDA signed-message test bench  
**Story ID**: S001-human-input-signed-message  
**Depends On**: S000-bootstrap-scene-reader; Layer 1 PRD freeze; Layer 2 Architecture freeze  
**Upstream dependency**: `_mynot/2-architecture/ARCHITECTURE.md` §§2, 3, 4, 5, 7, 9, 10

---

## User Story

As a human observer/operator, I want browser-entered text to become a human-signed `human_input` envelope that the actor can consume, so that speaking into the demo uses the same signed-message boundary as agent progress and does not become a privileged browser/API command path.

---

## Scope

This story brings one causal input path online:

`human text in browser/input surface` → signed `human_input` → actor consumes accepted human input

It does **not** implement full browser UI, save/restore, live CDDA capture, multi-step autoplay, or a complete natural-language strategy engine. The output of this story is a valid human-authored message and a minimal actor-side decision/acknowledgement that proves the message was consumed through the signed channel boundary.

---

## Acceptance Criteria

### AC1: Human text becomes a human-signed envelope
**Given** human text and optional visible context reference **When** the input surface submits it **Then** the output is a `human_input` signed envelope whose signer role is human and whose payload preserves the text.

### AC2: Actor consumes only accepted human input
**Given** a valid human-signed `human_input` envelope **When** the actor creates a response or next action decision from it **Then** the output is an actor-signed envelope causally linked to the human input.

### AC3: Browser transport does not become author
**Given** a browser/display component carrying the human text **When** it submits input **Then** browser transport metadata does not replace the human signer or author an agent envelope.

### AC4: Privileged `/api/*` command paths are not success
**Given** `/api/*` command payloads or browser-authored progress messages **When** the actor/input contract evaluates them **Then** they are rejected or absent from the success path.

### AC5: Wrong signer/channel combinations are rejected
**Given** server-, relay-, browser-, scene-reader-, bridge-, or actor-signed records claiming `human_input` **When** a subscriber attempts to consume them as human instructions **Then** the contract rejects them before producing an actor response.

### AC6: Audit projection shows human input provenance
**Given** accepted human input and actor response/decision envelopes **When** the audit projection is built **Then** it shows channel, signer, text/context reference, and causal predecessor ids.

### AC7: S000 bootstrap contract remains green
**Given** the existing S000 signed bootstrap tests **When** S001 adds human-input behavior **Then** all S000 tests continue to pass without weakening scene/action/effect signer validation.

---

## Technical Context

### Tech stack and versions

- MoonBit package: `moonbit/cdda_native_contract/` remains the domain-contract source of truth.
- Runtime/browser glue, if added, must use Python/browser standard capabilities only; no new external dependency.
- Browser surface remains display/input only and must not become a privileged controller.

### File locations

Primary implementation candidates:

- `moonbit/cdda_native_contract/cdda_native_contract.mbt` — add `human_input` constructor and actor consumption validation if needed.
- `moonbit/cdda_native_contract/cdda_native_contract_test.mbt` — tests for human-input acceptance, wrong-signer rejection, `/api/*` shortcut rejection, and S000 regression.
- `moonbit/cdda_native_contract/pkg.generated.mbti` — regenerated via `moon info`; do not hand-edit.

Optional only if this story adds a minimal input adapter:

- `scripts/` — transport/input adapter only; must not author actor/scene/bridge envelopes.
- `web/` — render/input only; no privileged `/api/*` progress command path.

### Existing pattern references

- S000 signed-envelope constructors and rejection tests in `moonbit/cdda_native_contract/cdda_native_contract.mbt` and `moonbit/cdda_native_contract/cdda_native_contract_test.mbt`.
- Architecture §4 channel catalog row for `human_input`.
- Architecture §5 subscriber rejection rules for human input and scene observation.
- Architecture §7 browser architecture: subscribe/render plus human publish only.

### Required domain names from Layer 2

Use Architecture channel names exactly:

- `human_input`
- `action_decision` for actor consumption/response if producing a decision
- `audit_finding` only if an explicit audit finding is added

Suggested public shape:

- `human_input_from_text(...) -> Result[SignedEnvelope, ContractError]`
- `action_decision_from_human_input(...) -> Result[SignedEnvelope, ContractError]` or a narrow actor acknowledgement helper if a full action decision would over-scope.
- `audit_human_input(...)` or reuse/extend existing audit projection if needed.

---

## Failure Modes (must be tested)

1. `failure-mode: browser-as-human-author` — browser transport/display signer cannot replace the human signer.
2. `failure-mode: browser-api-command-input` — `/api/*` command payload cannot satisfy human input success.
3. `failure-mode: server-authored-human-input` — relay/server cannot author a successful human instruction.
4. `failure-mode: actor-self-instruction` — actor-signed records cannot masquerade as human input.
5. `failure-mode: missing-human-text` — empty/missing human text is rejected.
6. `failure-mode: missing-causation` — actor response/decision without the human input predecessor id is rejected.
7. `failure-mode: S000-regression` — existing scene/action/effect validation remains unchanged.

---

## Execution Contract for Conduct/OMX

OMX native agents may execute this story, but they must preserve explicit `conduct` phase contracts:

1. **Testing phase**: executor may be OMX `test-engineer` or team lane, but contract is `tester-agent`; leave a tester report and `.omx/evidence/S001-red-tests.log` before implementation.
2. **Tester QC phase**: run `auto_qc/qc` logic against tester claims before implementation; record the coverage decision in `PROGRESS.md` or `.omx/evidence/`.
3. **Implementation phase**: executor may be OMX `executor` or team lane, but contract is `coder-agent`; leave a coder report and `.omx/evidence/S001-green-tests.log`.
4. **Coder QC phase**: run `auto_qc/qc` logic against implementation, tests, story AC, and failure modes before CI/CD/follow.

---

## Tasks

### Task 1: Lock red tests for human input (AC: 1-7)
- [ ] Add failing tests for accepted human text → human-signed `human_input`.
- [ ] Add failing tests for actor consumption/response with causation link.
- [ ] Add failing tests for every failure mode above.
- [ ] Save red evidence under `.omx/evidence/S001-red-tests.log` before implementation.
- [ ] Run tester QC before implementation.

### Task 2: Implement human input contract (AC: 1-2, 5-6)
- [ ] Reuse existing S000 envelope shape and signer/channel validation style.
- [ ] Add minimal human input payload validation.
- [ ] Add actor-side consumption helper with required causation.
- [ ] Add/extend audit projection for human text/context provenance.

### Task 3: Guard browser/server shortcut paths (AC: 3-4)
- [ ] If runtime/browser files are touched, keep browser as input carrier only.
- [ ] Do not add `/api/*` progress command success path.
- [ ] Add static checks or contract tests for browser/server shortcut rejection.

### Task 4: Regenerate and verify
- [ ] Run `moon info`.
- [ ] Run `moon fmt --check` or `moon fmt` then inspect diffs.
- [ ] Run `moon test`.
- [ ] Save green evidence under `.omx/evidence/S001-green-tests.log`.
- [ ] Run coder QC.

---

## Test Scenarios

| Test Case | AC | Input | Expected |
|---|---|---|---|
| Human text creates human input | AC1 | text + optional visible context ref | human-signed `human_input` envelope |
| Actor consumes human input | AC2 | accepted human input | actor-signed response/decision causally linked to input id |
| Browser signer rejected | AC3, FM1 | browser signer on `human_input` | `ContractError` |
| `/api/*` command rejected | AC4, FM2 | `/api/progress` or `/api/human-instruction` payload | not accepted as human input success |
| Server/relay signer rejected | AC5, FM3 | server/relay signer on `human_input` | `ContractError` |
| Actor self-instruction rejected | AC5, FM4 | actor signer on `human_input` | `ContractError` |
| Empty text rejected | FM5 | empty text | `ContractError` |
| Missing causation rejected | FM6 | actor response with no human input predecessor | `ContractError` |
| Audit shows provenance | AC6 | accepted input + actor response | projection includes channel, signer, text/context, predecessor id |
| S000 regression suite remains green | AC7 | existing S000 tests | all pass |

---

## Anti-Patterns (do not do)

- ❌ Do not let browser, server, relay, actor, scene-reader, or bridge sign `human_input` for the human.
- ❌ Do not use browser `/api/*` commands as proof that the human spoke into the system.
- ❌ Do not implement full UI, save/restore, live capture, or multi-step autoplay in this story.
- ❌ Do not add new channels or components outside Architecture §4.
- ❌ Do not weaken S000 scene/action/effect validation.
- ❌ Do not hand-edit `pkg.generated.mbti`; regenerate it.
- ❌ Do not add external dependencies.

---

## Definition of Done

- [ ] Every acceptance criterion has test evidence.
- [ ] Every failure mode above has a corresponding test or static check.
- [ ] Red evidence exists before implementation evidence.
- [ ] Tester QC and coder QC are both recorded.
- [ ] `moon info && moon fmt --check && moon test` passes.
- [ ] No browser/server shortcut path is required for success.
- [ ] S001 remains scoped to human input signed-message path only.
