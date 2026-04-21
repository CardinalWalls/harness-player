# Intent Freeze

## Change slug
cdda-native-relation-contract-v1

## Problem
当前 dashboard / web server 对 relation 的表达仍然是描述性 overlay：它从 channel snapshots 与 tmux capture 中拼出 `flow_topology.rows`，因此 edges 不是 native truth surface。用户已经明确否定继续在这条混合 capture / snapshot / observation 链路上打补丁。

## Frozen intent
重建一条独立于现有 legacy topology 的 greenfield contract：把 relation 本身做成 first-class snapshot objects，并为每条 relation 提供明确 owner、schema、lifecycle、evidence provenance、storage surface 与 UI surface。新的 relation contract 必须直接表达“谁与谁之间存在什么关系、当前状态是什么、依据是什么、最近一次原生刷新是什么”，而不是从 channel snapshots 事后拼出 descriptive rows。实现应以新入口和新数据面落地，直到用户确认后才进入代码实现与默认切换。

## Explicit non-goals
- 不继续增强或美化现有 `flow_topology.rows`。
- 不把 captured/parsed channel views 重新命名后当作 native relation contract。
- 不在 approval 前声称 channel takeover 已经完成。
- 不在 approval 前替换现有默认 dashboard。

## Truth classification
- Raw truth surfaces:
  - `hermes-cdda` tmux raw panel
  - tmux session existence / pane capture
  - 原始 relay events / local logs
- Captured/parsed surfaces:
  - `human-hermes` / `clone-hermes` / `supervisor-hermes` channel snapshots
  - 从 tmux 文本解析出的 observation / plan / result 字段
- Derived summary surfaces:
  - 现有 `flow_topology.rows`
  - 任何通过 channel/state 拼装出来的 explanatory topology
- Target native relation surfaces:
  - relation-specific snapshot objects
  - relation event log / store
  - relation health / takeover / provenance status

## Acceptance shape
- 用户看到的是一组被单独命名和持久化的 relation cards / sections，而不是从 node 列表临时拼出的 edge rows。
- 每条 relation 明确展示：relation id、source、target、contract kind、owner、status、evidence、updated_at。
- UI 必须显式标注哪些是 raw truth、哪些是 captured/parsed、哪些是 derived summary。
- 在 native relation contract 真正落地前，任何页面都不得暗示“已经完成原生 channel / relation contract”。

## Approval gate
Implementation is forbidden until the user explicitly approves this frozen intent and the corresponding mock.
