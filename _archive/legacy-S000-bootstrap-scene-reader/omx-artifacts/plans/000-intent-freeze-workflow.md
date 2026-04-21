# Intent Freeze Workflow

This repo now follows a mandatory versioned workflow for any architecture/product/demo-semantics change.

## Required order
1. Freeze intent in version control
2. Freeze a mock / expected result in version control
3. Get explicit user confirmation
4. Implement

## Tooling
- Git is required
- Entire is the default checkpoint/context tool when available
- Intent and mock artifacts should live under `.omx/plans/` or another committed repo path

## Reset rule
If a spec or implementation is rejected as misleading, remove/revert it and restart from a new frozen intent instead of iterating on the rejected implementation by default.
