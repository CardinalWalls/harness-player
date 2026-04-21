# S002 Tester Report — Red Phase

Story: `_mynot/3-plan/stories/S002-browser-audit-surface.md`

## Contract followed

- Designed tests from S002 AC/failure modes before implementing `web/index.html`.
- Wrote only the verification script: `scripts/verify_browser_audit_surface.py`.
- Did not implement the browser page in tester phase.

## Red evidence

Command:

```bash
python3 scripts/verify_browser_audit_surface.py
```

Result recorded in `.omx/evidence/S002-red-tests.log`:

```text
FAIL: missing browser surface: /Users/yetian/Desktop/new-real-100-commits/web/index.html
```

This is the expected red failure because the browser surface does not exist yet.

## Coverage map

| AC / failure-mode | Test coverage in script |
|---|---|
| AC1 provenance render | Requires embedded envelopes and visible/source field labels for channel, signer, role, causation, correlation, payload, valid. |
| AC2 forbidden-path guardrail | Requires guardrail terms and rejects network call markers. |
| AC3 human-signed composer | Requires composer function markers, fixed `human` signer, `human_input` channel, and semantic signature format. |
| AC4 privileged command rejection | Requires `/api/` rejection marker and empty-text rejection marker. |
| AC5 browser does not become actor | Parses embedded accepted envelopes and fails on browser/server/relay signers for system channels. |
| AC6 regression remains green | Delegated to coder/final phase MoonBit regression command after browser implementation. |
| no new dependencies | Script uses Python stdlib only; story forbids package manager additions. |
