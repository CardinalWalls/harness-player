# Story: S002 Browser audit surface for signed messages

**Status**: ready-for-setup  
**Epic**: CDDA signed-message test bench  
**Story ID**: S002-browser-audit-surface  
**Depends On**: S000-bootstrap-scene-reader; S001-human-input-signed-message  
**Upstream dependency**: `_mynot/1-intent/PRD.md` §2 Use cases 1-2 and §§3.1-3.4; `_mynot/2-architecture/ARCHITECTURE.md` §§2-7, §9, and §10 (especially §4 `human_input`/`scene_observation`/`action_decision` channels and §7 Browser architecture)

---

## User Story

As a human observer/operator, I want to open a browser page that renders the accepted signed-message chain and lets me compose a human-signed input envelope locally, so that I can inspect the demo only when the web surface shows signer, channel, causation, and forbidden-path status without relying on privileged `/api/*` progress commands.

---

## Scope

This story brings up the first browser-checkable surface only. It is deliberately static/local so the browser cannot smuggle in a new server authority.

In scope:

1. Render a sample accepted chain containing S000 `scene_observation` → `action_decision` → `action_effect` → next `scene_observation` plus S001 `human_input` → `action_decision`.
2. Display channel, signer, signer role, causation predecessor(s), correlation, payload summary, and validity/forbidden-path status for each envelope.
3. Provide a local human input composer that creates a `human_input` envelope from typed text and a visible context reference, with signer fixed to `human` and signature semantics matching the current contract convention (`sig:<signer>:<channel>:<id>`).
4. Keep the browser as display/input surface only: no `/api/*`, no MCP command path, no server-authored agent messages, no game-screen parsing.

Out of scope:

- Live CDDA terminal capture.
- Real cryptographic key management.
- Network relay/server persistence.
- Save/restore UI.
- Visual polish beyond a clear reviewable page.

---

## Expected Result Mock

When `web/index.html` is opened locally, the page should show:

1. A title naming the surface as a signed-message audit surface.
2. A status/guardrail panel saying the browser is render/input only and uses no `/api/*` progress path.
3. A table/list of accepted envelopes with these visible fields: channel, signer, role, causation, correlation, validity, payload summary.
4. The S000 bootstrap chain and S001 human-input response are visible without needing a server.
5. A text input plus visible-context field can generate a preview `human_input` envelope signed by `human`.
6. Attempts to generate empty text or `/api/*` command text are rejected in the browser preview and do not create a success envelope.

Invalid/反例 shown or enforced:

- `/api/*` browser progress path must be absent/rejected.
- Server/relay-authored scene/action messages must not appear as accepted success.
- Browser-authored `human_input` must not replace the human signer.
- Scripted-screen or parser-authoritative state must not be presented as accepted scene observation.

---

## Acceptance Criteria

### AC1: Browser renders signed provenance
**Given** the static browser page is opened **When** it loads the embedded accepted demo envelopes **Then** each accepted envelope visibly lists channel, signer actor, signer role, causation ids, correlation id, payload summary, and a valid status.

### AC2: Browser shows forbidden-path guardrail
**Given** the browser surface is reviewed **When** its source and rendered guardrail are inspected **Then** it states that the browser is render/input only and has no `/api/*`, MCP, server-authored, or scripted-screen success path.

### AC3: Human input composer creates human-signed preview
**Given** a human types non-empty text and a visible context reference **When** the composer runs locally **Then** the preview envelope uses channel `human_input`, signer `human`, signer role `human`, causation equal to the visible context reference, and a signature in the same semantic format as the MoonBit contract.

### AC4: Browser composer rejects privileged commands
**Given** the human text or context contains `/api/` **When** the composer validates input **Then** it rejects the input and does not create a success envelope.

### AC5: Browser does not become an actor
**Given** the browser source is scanned **When** accepted demo envelopes and composer code are checked **Then** there is no accepted envelope signed by `browser`, `server`, or `relay` on `scene_observation`, `action_decision`, `action_effect`, or `human_input`.

### AC6: Regression contract remains green
**Given** S000 and S001 are complete **When** S002 browser tests run **Then** existing MoonBit contract tests still pass and the browser surface does not require changing the signed-message domain rules.

---

## Technical Context

### Tech stack and versions

- Browser surface: plain static HTML/CSS/JavaScript in `web/index.html`; no build tool and no new dependency.
- Verification: Python 3 standard library script under `scripts/`; no new dependency.
- Contract regression: MoonBit package `moonbit/cdda_native_contract` (`yetian/cdda_native_contract`, version `0.1.0`).

### File locations

Primary S002 files:

- `web/index.html` — static reviewable browser audit surface and local human-input composer.
- `scripts/verify_browser_audit_surface.py` — no-dependency test/verification script for AC1-AC5.
- `.omx/evidence/S002-red-tests.log` — tester red evidence.
- `.omx/evidence/S002-tester-report.md` — tester phase report.
- `.omx/evidence/S002-tester-qc.md` — tester QC.
- `.omx/evidence/S002-green-tests.log` — coder green evidence.
- `.omx/evidence/S002-coder-report.md` — coder phase report.
- `.omx/evidence/S002-coder-qc.md` — coder QC.

Do not modify unless needed for regression compatibility:

- `moonbit/cdda_native_contract/cdda_native_contract.mbt`
- `moonbit/cdda_native_contract/cdda_native_contract_test.mbt`
- `moonbit/cdda_native_contract/pkg.generated.mbti`

### Existing utilities and patterns to reuse

- Current signature semantic convention: `sig:<signer_actor_id>:<channel>:<id>` from `moonbit/cdda_native_contract/cdda_native_contract.mbt`.
- Accepted channel/signer mapping from `_mynot/2-architecture/ARCHITECTURE.md` §4 and current MoonBit tests.
- Human input payload fields from S001: `text=` and `visible_context_ref=`.
- Audit projection fields from `AuditProjection`: envelope id, channel, signer actor, signer role, causation ids, valid.

### Test Scenarios

**Strategy**: static browser contract tests plus MoonBit regression.

| Layer | Scope | Justification |
|---|---|---|
| Static verification script | Parse `web/index.html`, embedded demo data, and composer code markers | Catches forbidden `/api/*` paths, missing provenance fields, wrong accepted signers, and missing local composer before implementation is considered green. |
| MoonBit regression | `moon info && moon fmt --check && moon test` | Confirms S002 did not weaken S000/S001 domain contract. |

Boundary and negative cases:

- Empty human text rejected.
- Human text/context containing `/api/` rejected.
- Browser/server/relay signers rejected as accepted actor messages.
- Missing provenance columns fails verification.
- Page cannot depend on network endpoints to show sample accepted chain.

### Anti-Patterns / failure-mode

- failure-mode: Do not add browser `/api/*` calls or privileged command endpoints as a success path.
- failure-mode: Do not let browser/server/relay sign accepted agent or human messages.
- failure-mode: Do not make the browser read or parse the CDDA game screen as authoritative state.
- failure-mode: Do not hide signer/causation metadata behind visual-only text that tests cannot verify.
- failure-mode: Do not add npm, Playwright, or other dependencies for this slice.

---

## Execution Contract for Conduct/OMX

S002 must preserve the explicit phase contract even if OMX/Codex executes the work:

1. Setup/Ralplan produces `.omx/plans/prd-S002-browser-audit-surface.md` and `.omx/plans/test-spec-S002-browser-audit-surface.md` from this story only.
2. Tester phase creates failing verification first (`scripts/verify_browser_audit_surface.py` before `web/index.html` satisfies it) and records red evidence.
3. Tester QC maps every AC and failure-mode to the verification script or MoonBit regression.
4. Coder phase implements the smallest static browser surface needed to turn red green.
5. Coder QC verifies no forbidden path or signer substitution was introduced.
6. Follow/CI either opens PR and monitors checks or records local-only evidence if CI is unavailable.
