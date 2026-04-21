# Context Snapshot — CDDA native channel contract v3 (stacked relation sections)

## Task statement
根据用户对 v2 mock 的纠正，重新定义 native channel contract 的展示与解释方式：
- 页面不是左到右五栏；
- 更接近的是自上而下多个 section；
- 每个 section 下面放两个 channel；
- 每个 section 负责解释一条数据关系；
- 同一个真实 channel 必须能在多个 section 中重复出现；
- 页面要能把这些重复出现解释清楚，而不是让 channel 只出现一次。

## Desired outcome
产出新的 v3 frozen intent、mock、spec、implementation plan，使页面结构从“独立栏目板”升级为“relation-section stack”：每个 section 是对一条 contract 的现场解释面板，由两个真实 channel 视图 + relation 说明组成。真实 channel 有唯一 canonical identity，但可以被多个 section 重复引用和实时渲染。

## Known facts / evidence
- 用户直接纠正：
  - “从上到下五个section还差不多”
  - “五个不够”
  - “每个section下面是两个channel, 展示其数据关系并说明”
  - “每个真实channel, 肯定都不止一次的出现”
- 这意味着 v2 的主要问题是：
  - 把页面误建模为单次出现的 channel columns；
  - 没把 channel 的 reusable appearance 和 pairwise relation explanation 表达清楚。
- 现有 repo/legacy 仍然不变：
  - `scripts/cdda_web_server.py` 是 capture/parse/topology old path
  - 新设计仍需 greenfield，不回到旧 server 上打补丁

## Constraints
- 不把真实 channel 设计成页面上的“只出现一次的唯一栏目”。
- UI 必须允许一个 channel 出现在多个 section 中，但这些出现都指向同一个底层 channel object。
- 每个 section 必须清晰说明：
  - source channel
  - target channel
  - relation / contract kind
  - why these two channels are shown together
- 继续保持 intent+mock 先行，implementation 仍未开始。

## Unknowns / open questions
- section 总数是固定 5/6/7，还是按 contract registry 动态生成？
- `raw-tui` 是否视作 channel-like truth surface，还是单独 raw surface 但可作为 section 左侧 participant？
- human instruction 第一版是否进入主 section stack？

## Likely touchpoints
- `.omx/plans/007-intent-freeze-native-channel-and-relation-contract-v3.md`
- `.omx/plans/008-mock-review-native-channel-and-relation-contract-v3.md`
- `.omx/plans/009-spec-revision-native-channel-and-relation-contract-v3.md`
- `.omx/plans/autopilot-spec.md`
- `.omx/plans/autopilot-impl.md`
