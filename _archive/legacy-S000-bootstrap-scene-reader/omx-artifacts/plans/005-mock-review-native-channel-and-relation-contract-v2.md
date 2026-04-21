# Mock Review

## Related intent freeze
- `.omx/plans/004-intent-freeze-native-channel-and-relation-contract-v2.md`

## Mock summary
第一版页面不追求花哨。它像一个实时更新的 markdown board，从左到右放 5 个主栏目，每个栏目绑定一个真实 channel 的最新 snapshot；栏目之间再有一排 relation cards。raw TUI 仍保留最左侧作为 raw truth；其余栏目只显示 native channel 的实时输出。derived overview 退到最下方，明确标注 `derived`。

## Mock artifacts
- Markdown mock（本文件）
- 预期布局：

```md
| Raw TUI | Scene State | Action Intent | Action Result | Supervisor |
|---------|-------------|---------------|---------------|------------|
| live tmux raw text | scene-reader latest snapshot | navigator latest decision | executor latest outcome | supervisor latest reflection |
```

- relation row（位于栏目下方）：

```md
[raw-tui -> scene-state] [scene-state -> action-intent] [action-intent -> action-result] [action-result -> scene-state] [supervisor -> action-intent]
```

## Expected user-visible result
1. **Raw TUI**
   - 直接显示 tmux/raw capture
   - 标签：`raw truth`
2. **Scene State**
   - 显示 scene-reader 对 TUI 的结构化理解
   - 例：visible threats / inventory cues / current mode / confidence
   - 标签：`native channel · owner=scene-reader`
3. **Action Intent**
   - 显示 navigator 的当前目标、下一步动作、理由
   - 标签：`native channel · owner=navigator`
4. **Action Result**
   - 显示 runtime executor 最近执行的动作与成功/失败
   - 标签：`native channel · owner=runtime-executor`
5. **Supervisor**
   - 显示 supervisor 对 navigator / scene-reader 的反思、纠偏、health verdict
   - 标签：`native channel · owner=supervisor`
6. **Relations**
   - 每张 card 显示：relation id / source / target / kind / owner / status / evidence / updated_at
7. **Derived overview**
   - 只做次级摘要，如“当前 loop 健康 / 最近 5 次动作”
   - 必须标 `derived`

## Example real-time content
### Raw TUI
```text
You see a zombie.
Pain 12
Wielding: makeshift crowbar
```

### Scene State channel
```json
{
  "mode": "combat-risk",
  "visible_threats": ["zombie"],
  "weapon": "makeshift crowbar",
  "confidence": 0.82,
  "source_capture_id": "raw-00041"
}
```

### Action Intent channel
```json
{
  "goal": "create-distance",
  "next_action": "move_west",
  "reason": "adjacent zombie threat",
  "input_scene_snapshot": "scene-00107"
}
```

### Action Result channel
```json
{
  "executed": "move_west",
  "success": true,
  "observed_change": true,
  "result_capture_id": "raw-00042"
}
```

### Supervisor channel
```json
{
  "verdict": "ok",
  "note": "navigator used threat-first heuristic correctly",
  "risk": "medium"
}
```

## Agent / skill mock
- `scene-reader` prompt / skill:
  - 任务：只负责把 raw TUI 解读成 scene-state，不直接给游戏发动作
  - 输出约束：结构化字段 + confidence + evidence pointer
- `navigator` prompt / skill:
  - 任务：只基于 scene-state 生成 action-intent，不直接解析 raw TUI
- `runtime-executor`:
  - 任务：只执行 action-intent 并写 action-result
- `supervisor`:
  - 任务：观察上述 channels，写 reflection / correction，不直接替代 navigator 除非 takeover

## Honesty labels
- Raw truth: Raw TUI column
- Native channel: Scene State / Action Intent / Action Result / Supervisor columns
- Native relation: relation cards row
- Derived summary: bottom overview section only

## Open questions for confirmation
- 第一版是否就采用 5 栏固定布局？
- `human instruction` 是否作为第 6 栏，还是先保留在侧边控制区？
- supervisor 是独立一栏，还是先只显示 relation/governance verdict？

## Approval gate
No implementation until this mock is explicitly approved.
