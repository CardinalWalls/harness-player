# Cleanup Plan — remove invalid relation-snapshot spec/implementation

## Why
The recent spec and implementation for live relation snapshots were rejected by the user as deceptive because they made the dashboard appear more agent-native than it really is.

## Goal
Return the repo to an honest baseline, codify a stricter intent-freeze workflow, and avoid further implementation beyond approved mock/spec.

## Cleanup scope
1. Remove invalid spec artifacts that assert or normalize the rejected direction.
2. Remove relation-snapshot code and UI that present derived flow objects as the new primary truth.
3. Restore a simpler honest dashboard baseline driven by raw panel + captured/parsed channel views.
4. Add process guardrails to AGENTS.md requiring:
   - intent freeze in version control
   - explicit mock artifact
   - user confirmation before implementation
5. Prepare a versioned workflow surface for future re-spec from scratch.
6. Evaluate and, if feasible, enable Entire for checkpoint-backed versioned intent tracking.

## Non-goals
- Do not debug or refine the rejected relation-snapshot model.
- Do not create a new speculative architecture without an approved mock.

## Verification
- Python/shell syntax checks pass
- Dashboard boots
- Proof script passes after being updated to the honest baseline
- AGENTS.md explicitly encodes the new workflow contract
