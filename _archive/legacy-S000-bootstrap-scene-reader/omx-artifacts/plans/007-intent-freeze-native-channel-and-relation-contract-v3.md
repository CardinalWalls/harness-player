# Intent Freeze

## Change slug
cdda-native-channel-and-relation-contract-v3

## Problem
v2 仍然把页面想成一组并排栏目，导致“channel 作为 canonical object”与“channel 在多个关系里重复出现”的本质没有被表现出来。用户需要的不是五个互相隔离的栏目，而是自上而下的一组 relation sections：每个 section 通过两个真实 channel 的并置，解释一条 contract 如何把数据从一个 truth surface 传到另一个 truth surface。

## Frozen intent
新的 native contract 必须同时满足两件事：
1. channel 在运行时中是唯一的 canonical object，拥有稳定 id、owner、sequence、payload；
2. web 展示层可以在多个 section 中重复引用同一个 channel，把它放进不同 contract 上下文中解释。页面的基本单元不再是“单个 channel 栏目”，而是“section = 两个 channel 的关系说明面板”。每个 section 都必须由两个实时 channel 视图、一个 relation contract、以及一段解释文字组成。这样用户能看到：同一个真实 channel 如何在不同关系中充当 source 或 target。

## Explicit non-goals
- 不再把页面建模成 5 个互不复用的列。
- 不让一个 channel 只出现一次，导致数据关系断裂。
- 不把“重复渲染一个 channel”误做成多个不同 channel 实例。
- 不回到 legacy capture/parse dashboard 上增量打补丁。

## Truth classification
- Raw truth surfaces:
  - `raw-tui`
  - raw execution evidence / raw logs
- Canonical native channels:
  - `scene-state`
  - `action-intent`
  - `action-result`
  - `supervisor-reflection`
  - optional `human-instruction`
- Native relation contracts:
  - `raw-tui -> scene-state`
  - `scene-state -> action-intent`
  - `action-intent -> action-result`
  - `action-result -> scene-state`
  - `supervisor-reflection -> action-intent`
  - optional `human-instruction -> supervisor-reflection` or `human-instruction -> action-intent`
- Derived summary surfaces:
  - stack summary / relation health overview / timeline digest

## Acceptance shape
- 页面主体是自上而下的一组 section，而不是固定五栏。
- 每个 section 展示两个真实 channel（或 raw truth + channel），并说明它们的关系。
- 同一个真实 channel 可以在多个 section 中重复出现；所有出现都同步指向同一个 canonical channel id。
- 页面上能明显看出“这是同一个 channel 在另一个关系里再次出现”，例如通过 channel id / sequence / updated_at 对齐。
- relation explanation 要回答：为什么展示这两个 channel，它们之间的数据契约是什么。

## Approval gate
Implementation is forbidden until the user explicitly approves this frozen intent and the corresponding mock.
