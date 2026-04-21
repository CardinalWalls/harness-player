# Context Snapshot — CDDA native channel contract + split dataflow rebuild

## Task statement
基于用户最新澄清，重新定义 CDDA live scene 的真实数据流：
1. 拆分当前 CDDA 场景中的数据流动；
2. 研究并设计 agent 的职责、反思链路、提示词/skill，让一个专门的 Hermes 负责解读 TUI 信息；
3. 在可实现的前提下，落到原生 native channel contract，而不是 capture-pane 的后处理伪 channel；
4. 先给出简单清晰的 web mock（类似 markdown 栏目从左到右），并且 mock 对应的栏目在实现阶段要绑定真实 channel、实时变化；
5. 文档完成后进入执行阶段，但仍受 repo 的 intent+mock approval gate 约束。

## Desired outcome
产出一套新的 frozen intent、mock、spec、implementation plan，把当前混合 capture/parse/act 的旧流拆成：raw truth、native channels、native relations、derived summaries 四层，并明确哪些 agent 负责观察、结构化、决策、执行、监督。

## Known facts / evidence
- 用户最新澄清的核心判断：
  - `capture-pane` 不应该继续直接喂给当前 `clone-hermes` 这种又解读又执行的角色。
  - TUI 的结构化解读很可能应该由专门 agent 负责。
  - “两个独立 channel，但它们之间还有关系” 才是更接近 native contract 的形状。
- 现有 repo 证据：
  - `scripts/cdda_web_server.py` 仍以 `tmux_capture()` -> `_sync_tmux_agent_channel()` -> `_build_flow_topology()` 工作。
  - `web/index.html` 仍把 `clone-hermes` / `supervisor-hermes` 标成 `captured/parsed`，并把 topology 渲染为 descriptive rows。
  - `scripts/clone_hermes_mcp_server.py` 当前是把 `clone_hermes` tmux session 包成 MCP surface，不是 native channel runtime。
- 先前 v1 冻结产物已经 committed，但范围偏向 relation-first；本轮需要 v2 明确把 native channel contract 放在更前面，并把 agent/dataflow 拆分写清楚。

## Constraints
- 不在 legacy `scripts/cdda_web_server.py` 上继续补丁式演化原生 contract。
- 先文档冻结，再 mock，再 approval，再实现。
- mock 需要足够具体，能说明 web 页面每栏是什么、对应哪个真实 channel、实时如何变化。
- 新设计要区分：raw truth / native channels / native relations / derived summaries。
- agent 命名要避免 `clone-hermes` 这种混淆观察者与执行者职责的名字。

## Unknowns / open questions
- scene-reader 的结构化输出是纯 snapshot，还是 event stream + latest snapshot 双层？
- runtime executor 是否保持工具型角色，还是也需要自己的 channel？
- supervisor 是直接观察 scene-state + action-intent，还是观察 navigator 的 reflection channel？
- 第一版是否保留 legacy clone session 仅作兼容旁证？

## Likely touchpoints
- `.omx/plans/004-intent-freeze-native-channel-and-relation-contract-v2.md`
- `.omx/plans/005-mock-review-native-channel-and-relation-contract-v2.md`
- `.omx/plans/006-spec-revision-native-channel-and-relation-contract-v2.md`
- `.omx/plans/autopilot-spec.md`
- `.omx/plans/autopilot-impl.md`
- 获批后的 greenfield 候选：
  - `scripts/cdda_channel_runtime.py`
  - `scripts/channel_store.py`
  - `scripts/relation_store.py`
  - `scripts/cdda_contract_web_server.py`
  - `web/native-contract.html`
