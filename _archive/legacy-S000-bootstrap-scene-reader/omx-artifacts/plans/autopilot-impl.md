# Autopilot Implementation Plan — CDDA Native Channel + Relation Contract Rebuild (v3)

## Status
Execution blocked pending explicit user approval of the frozen intent + mock.

## Guardrails
- No implementation until `.omx/plans/007-intent-freeze-native-channel-and-relation-contract-v3.md` and `.omx/plans/008-mock-review-native-channel-and-relation-contract-v3.md` are explicitly approved.
- No edits that repurpose legacy `scripts/cdda_web_server.py` into the new native contract.
- No relabeling of captured/parsed views as native channels.

## Planned implementation lanes (post-approval)

### Lane 1 — Canonical channel runtime
Owner scope:
- `scripts/cdda_channel_runtime.py`
- `scripts/channel_store.py`

Tasks:
1. Define canonical channel schema and lifecycle.
2. Implement writer/reader APIs for `scene-state`, `action-intent`, `action-result`, `supervisor-reflection`, optional `human-instruction`.
3. Preserve sequence lineage for repeated UI references.
4. Add smoke tests for sequence/order/live/stale behavior.

### Lane 2 — Relation runtime
Owner scope:
- `scripts/relation_store.py`
- relation portions of `scripts/cdda_contract_web_server.py`

Tasks:
1. Define relation schema and lifecycle.
2. Materialize first-class relations linking the canonical channels.
3. Support section-oriented lookup: each section resolves left participant, relation, right participant.
4. Add smoke tests for all primary contracts.

### Lane 3 — Agent prompt / skill artifacts
Owner scope:
- repo-tracked artifacts for `scene-reader`, `navigator`, `supervisor`

Tasks:
1. Write scene-reader artifact for TUI interpretation only.
2. Write navigator artifact for scene-state -> action-intent only.
3. Write supervisor artifact for governance/reflection only.
4. Verify role boundaries and evidence requirements.

### Lane 4 — Section-stack dashboard
Owner scope:
- `scripts/cdda_contract_web_server.py`
- `web/native-contract.html`
- `scripts/open-native-contract-dashboard.sh`

Tasks:
1. Render a top-to-bottom stack of relation sections.
2. Show two participant views per section.
3. Reuse the same canonical channel across multiple sections without data duplication.
4. Show relation explanation text and lineage metadata.
5. Keep derived summary at the bottom only.

### Lane 5 — Verification / compatibility
Owner scope:
- verification scripts under `scripts/`

Tasks:
1. Smoke canonical channel + relation stores.
2. Verify repeated channel references stay consistent across sections.
3. Verify live updates in the new dashboard.
4. Verify labels are honest.
5. Verify legacy dashboard remains unchanged.

## QA plan
1. Python/shell syntax checks.
2. Channel and relation schema tests.
3. Web endpoint + JSON payload smoke tests.
4. Manual live-update check for stacked sections.
5. Repeated-channel consistency validation.

## Validation plan
- Architect review: section model, canonical channel reuse, honesty.
- Code review: clarity and greenfield separation.
- Security review: local server, prompt artifacts, and file IO boundaries.

## Current next step
Wait for explicit approval of:
- `.omx/plans/007-intent-freeze-native-channel-and-relation-contract-v3.md`
- `.omx/plans/008-mock-review-native-channel-and-relation-contract-v3.md`

Implementation status: not started.
