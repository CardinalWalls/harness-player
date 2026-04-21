# Autopilot Spec — CDDA Native Channel + Relation Contract Rebuild (v3)

## Status
Planning-only spec. Implementation is blocked on explicit approval of:
- `.omx/plans/007-intent-freeze-native-channel-and-relation-contract-v3.md`
- `.omx/plans/008-mock-review-native-channel-and-relation-contract-v3.md`

## Problem statement
当前系统不仅缺 native channel truth，也缺能把“同一 channel 在不同 contract 中复用”讲清楚的展示模型。`capture-pane -> parse` 生成的伪 channel 与一次性栏目式 UI 会把数据流误讲成彼此隔离的板块；但真实系统里，同一个 canonical channel 会在多个关系中反复充当 source 或 target。

## Product goal
构建一条 greenfield native contract：
- raw truth、canonical native channels、native relations、derived summaries 分层明确；
- channel 在 runtime 中有唯一 canonical identity；
- UI 通过 stacked relation sections 多次引用同一个 canonical channel；
- 每个 section 清楚解释一条数据契约如何从左 participant 流到右 participant。

## Core dataflow and section model
Canonical flow:
```text
raw-tui -> scene-state -> action-intent -> action-result -> scene-state
supervisor-reflection -> action-intent
optional human-instruction -> supervisor-reflection / action-intent
```

Display flow:
```text
Section 1: raw-tui + scene-state
Section 2: scene-state + action-intent
Section 3: action-intent + action-result
Section 4: action-result + scene-state
Section 5: supervisor-reflection + action-intent
Section 6: optional human-instruction + supervisor-reflection/action-intent
```

## Canonical channel model
Each native channel must have:
- `channel_id`
- `owner`
- `sequence`
- `updated_at`
- `status`
- `payload`
- `evidence`
- `native=true`

Target canonical channels:
- `scene-state`
- `action-intent`
- `action-result`
- `supervisor-reflection`
- optional `human-instruction`

## Section rendering model
Each section must contain:
- left participant (`raw-tui` or canonical channel)
- right participant (canonical channel)
- relation badge / contract kind
- explanation block
- live data views for both participants

Repeated channel appearances are required, not accidental.
Rules:
- multiple sections may reference the same `channel_id`
- repeated appearances must stay visibly linked via channel id / sequence lineage
- UI may show both the latest snapshot and the relation-referenced snapshot when needed

## Target agent roles
1. `scene-reader`
   - raw-tui -> scene-state
2. `navigator`
   - scene-state -> action-intent
3. `runtime-executor`
   - action-intent -> action-result
4. `supervisor`
   - supervisor-reflection -> action-intent governance
5. optional `human-instruction`
   - human steering input

## Prompt / skill design requirements
- `scene-reader`
  - only interpret TUI
  - output structured scene + confidence + evidence pointer
  - no direct act
- `navigator`
  - consume scene-state
  - emit goal / next action / reason
  - do not use raw-tui as primary source
- `runtime-executor`
  - execute only
  - emit action-result
- `supervisor`
  - reflect / govern / propose takeover
  - do not silently replace navigator output

## Native relation requirements
Every relation must have:
- `relation_id`
- `kind`
- `source`
- `target`
- `owner`
- `status`
- `evidence`
- `updated_at`

Target relations:
- `raw-tui -> scene-state` (`observation-contract`)
- `scene-state -> action-intent` (`decision-contract`)
- `action-intent -> action-result` (`execution-contract`)
- `action-result -> scene-state` (`feedback-contract`)
- `supervisor-reflection -> action-intent` (`governance-contract`)
- optional `human-instruction -> supervisor-reflection/action-intent` (`instruction-contract`)

## Web mock requirements
The main page must:
- render a top-to-bottom stack of relation sections
- show two participants per section
- allow canonical channels to appear repeatedly across sections
- explain why each pair is shown together
- keep derived summary only at the bottom
- bind every repeated appearance to the same underlying channel object

## Proposed greenfield implementation slice (post-approval)
- Backend/runtime:
  - `scripts/cdda_channel_runtime.py`
  - `scripts/channel_store.py`
  - `scripts/relation_store.py`
  - `scripts/cdda_contract_web_server.py`
- UI:
  - `web/native-contract.html`
  - `scripts/open-native-contract-dashboard.sh`
- Prompt / skill artifacts:
  - scene-reader artifact
  - navigator artifact
  - supervisor artifact
- Legacy compatibility:
  - keep legacy dashboard untouched

## Verification shape (post-approval)
- canonical channel schema tests
- repeated-channel-reference rendering tests
- relation store tests
- live-update checks for every section
- label honesty checks
- legacy compatibility checks

## Decision record
- The page unit is a relation section, not a single channel column.
- Canonical channels are reusable runtime objects and must appear multiple times when the dataflow demands it.
- Repeated UI appearances must not create fake duplicate channels.
- Do not patch the legacy dashboard into this design.
