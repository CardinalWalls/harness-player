# Mock Review

## Related intent freeze
- `.omx/plans/007-intent-freeze-native-channel-and-relation-contract-v3.md`

## Mock summary
页面主体改成自上而下的 relation-section stack。每个 section 只解释一条关系，并固定包含：左 channel、右 channel、relation badge、文字说明。真实 channel 不追求只出现一次；相反，它们会在多个 section 中重复出现，以显示数据如何流经整个系统。页面不是“5 个频道栏目”，而是“多条合同/关系的解释板”。

## Mock artifacts
- Markdown mock（本文件）
- 核心渲染单元：

```md
## Section title
[left channel live view] <relation explanation> [right channel live view]
```

- canonical channel repeated across sections:

```md
scene-state  appears in Section 1, Section 2, and Section 4
action-intent appears in Section 2 and Section 5
```

## Proposed section stack (v3)

### Section 1 — Raw TUI is interpreted into Scene State
- Left: `raw-tui`
- Right: `scene-state`
- Relation: `observation-contract`
- Why these two:
  - scene-reader reads raw TUI and publishes structured scene-state

### Section 2 — Scene State drives Action Intent
- Left: `scene-state`
- Right: `action-intent`
- Relation: `decision-contract`
- Why these two:
  - navigator consumes scene-state and emits next action intent

### Section 3 — Action Intent is executed into Action Result
- Left: `action-intent`
- Right: `action-result`
- Relation: `execution-contract`
- Why these two:
  - runtime-executor executes the chosen action and reports outcome

### Section 4 — Action Result feeds back into Scene State
- Left: `action-result`
- Right: `scene-state`
- Relation: `feedback-contract`
- Why these two:
  - action changes the world; scene-state must refresh from the new reality

### Section 5 — Supervisor reflects on Action Intent
- Left: `supervisor-reflection`
- Right: `action-intent`
- Relation: `governance-contract`
- Why these two:
  - supervisor judges whether the chosen intent is acceptable / risky / needs takeover

### Section 6 — Human Instruction influences Supervisor or Intent (optional in v1 UI, explicit in data model)
- Left: `human-instruction`
- Right: `supervisor-reflection` or `action-intent`
- Relation: `instruction-contract`
- Why these two:
  - human input may steer policy or next-step intent, but must be shown honestly as its own contract

## Example repeated-channel rendering

### Section 1
```md
raw-tui(raw-00041)
  -> observation-contract(owner=scene-reader)
scene-state(scene-00107)
```

### Section 2
```md
scene-state(scene-00107)
  -> decision-contract(owner=navigator)
action-intent(intent-00032)
```

### Section 4
```md
action-result(result-00032)
  -> feedback-contract(owner=scene-reader)
scene-state(scene-00108)
```

Note:
- `scene-state` 在 Section 1、2、4 中都出现。
- 这些不是 3 个不同的 channel，而是同一 canonical channel 在不同 relation context 中的 live view。

## Example live content
### raw-tui
```text
You see a zombie.
Pain 12
Wielding: makeshift crowbar
```

### scene-state
```json
{
  "channel_id": "scene-state",
  "sequence": 107,
  "owner": "scene-reader",
  "payload": {
    "mode": "combat-risk",
    "visible_threats": ["zombie"],
    "weapon": "makeshift crowbar",
    "confidence": 0.82
  },
  "evidence": {"source_capture_id": "raw-00041"}
}
```

### action-intent
```json
{
  "channel_id": "action-intent",
  "sequence": 32,
  "owner": "navigator",
  "payload": {
    "goal": "create-distance",
    "next_action": "move_west",
    "reason": "adjacent zombie threat"
  },
  "evidence": {"input_channel": "scene-state", "input_sequence": 107}
}
```

### action-result
```json
{
  "channel_id": "action-result",
  "sequence": 32,
  "owner": "runtime-executor",
  "payload": {
    "executed": "move_west",
    "success": true,
    "observed_change": true
  },
  "evidence": {"result_capture_id": "raw-00042"}
}
```

### supervisor-reflection
```json
{
  "channel_id": "supervisor-reflection",
  "sequence": 9,
  "owner": "supervisor",
  "payload": {
    "verdict": "ok",
    "note": "navigator used threat-first heuristic correctly",
    "risk": "medium"
  },
  "evidence": {"intent_sequence": 32}
}
```

## Display rules
- Every section shows:
  - source view
  - relation badge
  - target view
  - one-paragraph explanation
- If a canonical channel appears in multiple sections, all appearances must show the same `channel_id` and latest `sequence` lineage.
- A section may show latest snapshot plus the specific referenced sequence used by that relation.
- Derived overview moves to the very bottom and is optional.

## Agent / skill mock
- `scene-reader`: interprets raw TUI into `scene-state`
- `navigator`: transforms `scene-state` into `action-intent`
- `runtime-executor`: turns `action-intent` into `action-result`
- `supervisor`: evaluates `action-intent` / system health into `supervisor-reflection`

## Honesty labels
- Raw truth: `raw-tui`
- Native channel: all canonical channel cards
- Native relation: every section badge/contract
- Derived: bottom summary only

## Open questions for confirmation
- 第一版主页面是否显示 5 个必选 section + 1 个可选 human section？
- section 中是否需要同时显示“latest snapshot”和“relation-referenced snapshot”两个层次？
- section explanation 是否直接写成人话说明，还是保留更结构化的 contract note？

## Approval gate
No implementation until this mock is explicitly approved.
