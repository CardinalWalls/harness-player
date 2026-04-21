# Mock Review

## Related intent freeze
- `.omx/plans/001-intent-freeze-native-relation-contract-v1.md`

## Mock summary
新版本不再把关系显示为一张泛化 topology 表，而是把页面拆成四类 surface：raw truth、structured channels、native relations、derived summaries。native relations 区域只展示真正的 relation snapshot cards；如果 relation contract 尚未 live，则明确显示 `not yet native` / `awaiting owner`，而不是回退成伪装后的 descriptive edge。

## Mock artifacts
- Markdown mock（本文件）
- 预期页面分区：
  1. CDDA Raw Panel
  2. Structured Channels（captured/parsed）
  3. Native Relations（first-class snapshots）
  4. Derived Summaries（optional, clearly labeled）

## Expected user-visible result
1. 页面顶部保留 raw game truth，与 relation contract 分离。
2. Human / Clone / Supervisor 仍然作为 channel cards 存在，并明确标注 `captured/parsed`。
3. Relations 单独显示为 relation cards，例如：
   - `cdda-raw -> clone-hermes` / kind=`live-observation-contract`
   - `clone-hermes -> supervisor-hermes` / kind=`supervision-contract`
   - `human-input -> human-hermes` / kind=`instruction-contract`
4. 每个 relation card 至少展示：
   - relation id
   - source / target
   - owner
   - native status (`live`, `stale`, `not_started`, `broken`)
   - evidence pointer
   - last native snapshot time
5. 如果某 relation 尚未拥有原生 owner，就展示 `missing native relation snapshot`，而不是用旧 descriptive row 顶替。

## Honesty labels
- Raw truth:
  - CDDA raw panel
  - raw tmux captures
  - raw relay event stream
- Captured/parsed:
  - human / clone / supervisor channel snapshots
- Derived summary:
  - optional overview section, must be visibly labeled `derived`
- Native relation:
  - only relation snapshot cards backed by dedicated relation objects

## Open questions for confirmation
- 第一版 native relations 是否只覆盖 3 条核心关系（instruction / live observation / supervision）？
- relation snapshots 是否先落本地 relation store，再异步镜像到 relay-store？
- 默认首页是否在 implementation 完成后再切换，还是先通过新的独立入口试运行？

## Approval gate
No implementation until this mock is explicitly approved.
