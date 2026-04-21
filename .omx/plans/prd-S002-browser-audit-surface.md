# PRD Handoff — S002 Browser audit surface

Source story: `_mynot/3-plan/stories/S002-browser-audit-surface.md`

## Goal

Create a first local browser-checkable surface for the signed-message test bench. The page must render accepted S000/S001 envelopes with signer/channel/causation visibility and allow a local human-input preview without using `/api/*`, MCP, server-authored messages, or scripted-screen progress.

## Non-negotiable constraints

- Browser is display/input only.
- No network or privileged command endpoint is required for success.
- Accepted demo messages must not be signed by browser/server/relay.
- The human-input composer may produce only `human_input` signed by `human`.
- No new dependency or build tool.

## Acceptance Criteria

1. Render signed provenance fields for embedded accepted envelopes.
2. Show source-visible and rendered forbidden-path guardrail.
3. Compose a local `human_input` preview with signer `human` and semantic signature `sig:human:human_input:<id>`.
4. Reject empty or `/api/*` input/context before preview success.
5. Static scan proves no browser/server/relay accepted actor messages and no `/api/*` success path.
6. MoonBit S000/S001 regression remains green.

## Expected artifacts

- `web/index.html`
- `scripts/verify_browser_audit_surface.py`
- `.omx/evidence/S002-*.md|log`
