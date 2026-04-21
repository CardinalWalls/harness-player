# Spec Revision

## Prior frozen direction
- `.omx/plans/004-intent-freeze-native-channel-and-relation-contract-v2.md`
- `.omx/plans/005-mock-review-native-channel-and-relation-contract-v2.md`

## User correction
用户指出 v2 的页面结构仍然不对：
- 不是左到右五栏；
- 更像自上而下的多个 section；
- 每个 section 下是两个 channel；
- 真实 channel 一定会在多个 section 中重复出现。

## What was wrong before
- 把 channel 展示误建模成一次性栏目。
- 没有清晰表达 canonical channel 与 repeated channel view 的关系。
- 没把 section 作为“解释关系”的主单元。

## Revised intent
页面主单元从 column 改成 section。每个 section 围绕一条 relation contract，展示两个实时 channel 视图；同一个 canonical channel 可以在多个 section 中复用出现。

## Revised mock requirement
mock 必须展示至少 5 个 relation sections，并至少有一个 channel 在 3 个 section 中重复出现，证明“同一真实 channel 的多处出现”已经被设计清楚。

## Implementation status
Not started. Approval still required before implementation.
