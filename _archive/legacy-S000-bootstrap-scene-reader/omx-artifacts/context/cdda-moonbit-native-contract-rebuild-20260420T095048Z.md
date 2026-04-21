# Context Snapshot — CDDA MoonBit native contract rebuild

## Task statement
当前 native-contract 实现被用户判定为根本错误：它仍然是 adapter-backed runtime，把 tmux/capture/旧 agent 输出再包装成新 channel。需要吸收这次错误实现的教训，删除错误实现，改用 MoonBit 制定并执行一个正确的重建方案。

## Desired outcome
- 从错误实现中抽取明确反例与禁止事项
- 使用 ralplan 形成 MoonBit-first 的正确计划
- 删除所有错误实现文件与相关入口
- 使用 MoonBit 实现新的 canonical channel / relation / section-stack domain
- 用 ralph 风格执行到可验证完成

## Known facts / evidence
- 错误实现 commit: `90b0cf4`
- 该实现的错误核心：
  - `scene-state` / `action-intent` / `action-result` / `supervisor-reflection` 不是独立 writer 原生写入
  - 而是单个 adapter 从 tmux / clone / supervisor 输出推导出来
- 错误实现文件：
  - `scripts/cdda_channel_runtime.py`
  - `scripts/cdda_contract_web_server.py`
  - `scripts/channel_store.py`
  - `scripts/relation_store.py`
  - `scripts/open-native-contract-dashboard.sh`
  - `scripts/test-native-contract-dashboard.sh`
  - `web/native-contract.html`
  - `prompts/scene-reader.md`
  - `prompts/navigator.md`
  - `prompts/supervisor.md`
- 正确展示模型仍然有效：
  - 页面主单位是 section
  - 每个 section 展示两个真实 participant 与 relation explanation
  - 同一个 canonical channel 可以在多个 section 重复出现
- MoonBit toolchain is installed locally:
  - `moon 0.1.20260409`
- Local MoonBit skill references available:
  - `/Users/yetian/Desktop/MoonBit-100commits/learn-MoonBit/skills`

## Constraints
- 删除错误实现，不在其上修补
- MoonBit 必须成为新实现的核心语言
- 对“原生 channel contract”的说法必须诚实：只有独立 writer 真正写入时才能 claim native
- 页面仍应维持 stacked relation sections 模型

## Unknowns / open questions
- MoonBit 在本 repo 中作为独立 module 子目录，还是直接成为 repo 根 module
- 独立 writer 进程第一版是否全部自动启动，还是先提供 writer contract + MoonBit validator/runtime
- Web 层是 MoonBit JS 直出，还是 MoonBit 生成状态 + 极薄静态壳展示

## Likely touchpoints
- `.omx/plans/010-cleanup-wrong-native-contract-implementation.md`
- `.omx/plans/prd-cdda-moonbit-native-contract.md`
- `.omx/plans/test-spec-cdda-moonbit-native-contract.md`
- `.omx/plans/ralplan-cdda-moonbit-native-contract.md`
- new MoonBit module directory under repo
