# Intent Freeze

## Change slug
cdda-native-channel-and-relation-contract-v2

## Problem
当前 CDDA live dashboard 的核心问题不只是 relation 还是 descriptive，而是 channel 本身也不是 native truth object。现有实现依赖 `tmux capture-pane -> parse -> channel snapshot -> topology rows` 的混合链路，导致“观察 TUI”“结构化 scene”“生成行动意图”“执行按键”被错误耦合，`clone-hermes` 这种角色同时承担了解读与操作，既不清晰也不诚实。

## Frozen intent
重建一条 greenfield runtime contract：先把 CDDA 场景的数据流拆成独立、可拥有的 native channels，再在这些 native channels 之上定义 native relations。新的系统必须把 raw TUI、scene interpretation、action intent、action result、supervisory reflection 分别做成独立 truth surface，由不同 owner 写入；web 只读取这些原生 channel/relation objects，不再通过 capture-pane 后处理伪造 channel truth。第一版要把“专门一个 Hermes 负责解读 TUI 信息”落实到独立角色与独立 channel，并明确提示词/skill 的职责边界。

## Explicit non-goals
- 不继续把 `clone-hermes` 作为同时“观察+解释+执行”的单体角色。
- 不把 tmux capture 的解析结果重新命名成 native channel。
- 不仅靠 MCP 包装就声称已经完成 native contract。
- 不在 approval 前替换默认 legacy dashboard。

## Truth classification
- Raw truth surfaces:
  - `hermes-cdda` TUI raw screen / tmux pane capture
  - 原始执行结果 / 原始 relay 或本地日志
- Native channel surfaces:
  - `scene-state`
  - `action-intent`
  - `action-result`
  - `supervisor-reflection`
  - 可选：`human-instruction`
- Native relation surfaces:
  - `raw-tui -> scene-state` (`observation-contract`)
  - `scene-state -> action-intent` (`decision-contract`)
  - `action-intent -> action-result` (`execution-contract`)
  - `action-result -> scene-state` (`feedback-contract`)
  - `supervisor-reflection -> action-intent` (`governance-contract`)
- Derived summary surfaces:
  - overview / topology summary
  - health aggregates / simplified timeline

## Acceptance shape
- 用户在 web 上能看到从左到右的简单栏目：Raw TUI | Scene State | Action Intent | Action Result | Supervisor。
- 每一栏对应真实 native channel 的最新输出，而不是 UI 现算的假摘要。
- 页面上每条 relation 都作为独立 relation card 显示，说明 source、target、owner、status、evidence。
- prompt/skill 文档能说明：哪个 agent 专门负责 TUI 解读，哪个负责导航决策，哪个负责执行，哪个负责监督。
- 在 native contract 未完成的部分，页面必须直接显示缺口，而不是用 derived/captured 内容冒充。

## Approval gate
Implementation is forbidden until the user explicitly approves this frozen intent and the corresponding mock.
