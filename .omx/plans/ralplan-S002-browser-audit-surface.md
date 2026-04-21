# Ralplan Summary — S002 Browser audit surface

## Decision

Implement S002 as a dependency-free static browser audit page plus a Python static verification script. Keep the browser-checkable proof local and transparent before any live relay/server work.

## Decision drivers

1. User only wants inspection when a web/browser surface is ready.
2. Prior failures came from server/browser shortcut authority; S002 must prove the browser boundary instead of adding runtime power.
3. The current repo has only MoonBit contract code, so a static page is the smallest reversible web slice.

## Alternatives considered

- Live web server/relay first — rejected because it risks reintroducing server authority before the render/input contract is testable.
- Playwright/npm browser test — rejected because S002 explicitly forbids new dependencies.
- Extend MoonBit contract only — rejected because the user asked to wait for a browser-checkable surface.

## Execution plan

1. Tester phase: create `scripts/verify_browser_audit_surface.py` red test only.
2. Tester QC: map all AC/failure modes to script and MoonBit regression.
3. Coder phase: implement `web/index.html` with embedded accepted envelopes, guardrails, provenance render, and local human-input preview.
4. Coder QC: rerun static script and MoonBit regression; scan for `/api/*`, browser/server/relay accepted signers, and new dependencies.
5. Follow: push branch/PR if remote remains available; otherwise record local evidence.
