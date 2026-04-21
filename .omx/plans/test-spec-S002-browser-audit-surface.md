# Test Spec — S002 Browser audit surface

Source story: `_mynot/3-plan/stories/S002-browser-audit-surface.md`

## Red phase requirements

Before implementation exists, create `scripts/verify_browser_audit_surface.py` that fails unless `web/index.html` provides:

- `DEMO_ENVELOPES` embedded data containing accepted channels from S000/S001.
- Required visible fields: channel, signer_actor_id, signer_role, causation_ids, correlation_id, payload summary, valid status.
- Guardrail copy covering render/input only, no `/api/*`, no MCP, no server-authored messages, no scripted-screen success.
- Composer functions/markers that create human-signed `human_input` previews.
- Validation that rejects empty text and any `/api/` in text/context.
- Absence of accepted browser/server/relay signers on system-relevant channels.

Expected red evidence: verification script fails before `web/index.html` is implemented.

## Green phase requirements

Run these commands from repo root:

```bash
python3 scripts/verify_browser_audit_surface.py
cd moonbit/cdda_native_contract && moon info && moon fmt --check && moon test
```

Both must pass. Record logs to `.omx/evidence/S002-green-tests.log`.

## AC / failure-mode mapping

| Story item | Verification |
|---|---|
| AC1 provenance render | Script checks embedded data and DOM labels for required fields. |
| AC2 forbidden-path guardrail | Script checks copy/markers and no forbidden API call syntax. |
| AC3 human-signed composer | Script checks composer markers and deterministic signature format. |
| AC4 privileged command rejection | Script checks rejection markers and fixtures. |
| AC5 browser does not become actor | Script parses embedded accepted signers and fails on browser/server/relay. |
| AC6 regression green | MoonBit command remains 22/22 passing. |
| failure-mode `/api/*` | Static scan fails on fetch/XMLHttpRequest/navigator.sendBeacon or `/api/`. |
| failure-mode wrong accepted signer | Parsed embedded envelope assertion. |
| failure-mode scripted-screen authority | Guardrail and sample data scan. |
| failure-mode hidden metadata | Required field labels must be present in HTML. |
| failure-mode new dependency | No package manifest/build tool added for this story. |
