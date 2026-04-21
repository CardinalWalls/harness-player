# Context Snapshot — cdda native relation contract rebuild

## Task statement
从 spec 开始，重新构建 CDDA live demo 里的 relation/channel contract；明确不要在旧的混合 capture/snapshot/observation 实现上继续修补。

## Desired outcome
产出一套新的 frozen intent、mock、spec、implementation plan，用于把 relations 提升为 first-class native relation snapshots，而不是继续把 edge 当作由 channel snapshots 推导出来的 descriptive rows。

## Known facts / evidence
- 用户本轮给出的纠偏是当前最高优先级事实：
  - 旧版/后续 spec 只把 `nodes` 明确成 live structured channels。
  - `edges` 仍然 mostly descriptive。
  - 真正缺口是把 `edges` 提升成 first-class relation snapshots。
  - `captured structured flow` 与 `channel takeover is still being completed` 说明旧 spec 承认缺口，并不等于已经完成 native channel contract。
- 当前 checkout 中可见的实现证据：
  - `scripts/cdda_web_server.py` 仍然通过 `_build_flow_topology()` 生成 descriptive `rows`，例如：
    - `CDDA Raw -> clone-hermes` = `capture / observe`
    - `clone-hermes -> supervisor-hermes` = `monitor / diagnose`
    - 各 channel -> relay-store = `publish snapshot`
  - 这些 rows 基于现有 `channel_records` / `channel_snapshots` 组合而成，而不是 first-class relation objects。
  - `web/index.html` 也把 topology 作为 `flow_topology.rows` 展示，并继续把 channel panels 标成 `captured/parsed`。
- 当前 repo 中旧的 autopilot spec / impl 已经被标记为 INVALIDATED，不能继续沿用。
- 用户在 prompt 中提到的旧文件：
  - `.omx/context/cdda-live-relation-sections-20260420T081000Z.md`
  - `.omx/plans/autopilot-spec.md`
  - `.omx/plans/autopilot-impl.md`
  其中前一个 context 文件不在当前 checkout，但其纠偏内容作为同线程用户证据处理。

## Constraints
- 不在旧实现上打补丁。
- 先走 intent freeze + mock-first；未获显式确认前禁止 implementation。
- 新 spec 必须诚实区分 raw truth / captured structured / derived summary / native relation contract。
- 尽量采用并行 greenfield slice：新文件、新入口、新数据目录，最后再决定是否切换默认入口。

## Unknowns / open questions
- relation snapshots 的 owner 是 relation-specific runtime，还是由各参与 channel 共同发布？
- 新 dashboard 是新增页面/入口，还是批准后再替换现有首页？
- relation snapshot 是否进入 relay-store，还是先落地本地 relation store 再镜像出去？

## Likely touchpoints
- `.omx/plans/001-intent-freeze-native-relation-contract-v1.md`
- `.omx/plans/002-mock-review-native-relation-contract-v1.md`
- `.omx/plans/003-spec-revision-native-relation-contract-v1.md`
- `.omx/plans/autopilot-spec.md`
- `.omx/plans/autopilot-impl.md`
- 未来获批后的 greenfield 实现候选：
  - `scripts/cdda_relation_contract_server.py`
  - `scripts/relation_store.py`
  - `scripts/open-relation-dashboard.sh`
  - `web/relation-contract.html`
