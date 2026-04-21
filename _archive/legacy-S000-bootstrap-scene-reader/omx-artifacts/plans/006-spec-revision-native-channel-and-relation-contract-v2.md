# Spec Revision

## Prior frozen direction
- `.omx/plans/001-intent-freeze-native-relation-contract-v1.md`
- `.omx/plans/002-mock-review-native-relation-contract-v1.md`
- `.omx/plans/autopilot-spec.md`（上一版偏 relation-first）

## User correction / expansion
用户确认我已经理解方向，并补充了新的必做项：
1. 拆分 CDDA 场景中的数据流动；
2. 研究 agent 与信息流的反思设计，包括 prompt 和 skill，让专门的 Hermes 负责解读 TUI；
3. 设计必须符合 native channel contract；
4. 先给出清晰的 web mock，并且 mock 要面向真实 channel 的实时输出；
5. 文档完成后进入执行阶段。

## What was incomplete before
- 旧版冻结过于偏向 relation-first，没有明确把 native channel contract 放到前置基础层。
- 没有充分展开 agent 角色拆分与 prompt/skill 边界。
- mock 还不够具体，没展示左到右栏目以及真实 channel 输出示例。

## Revised intent
先定义 raw truth -> native channels -> native relations -> derived summaries 的四层模型；先把 scene interpretation 从 navigator/actor 角色中剥离出来，再在此基础上定义 relation 与 web 展示。

## Revised mock requirement
mock 必须展示至少 5 个实时栏目（Raw TUI / Scene State / Action Intent / Action Result / Supervisor）以及 relation cards，并给出每栏的真实 channel 输出示例。

## Implementation status
Not started. Approval still required before implementation.
