# Layer 1 — Intent

> **只放 WHAT & WHY，不放 HOW。**

## 这一层的产物

- `PRD.md` —— 用 `/prd` skill（agents-zone-skillset）产出。

本目录下**只应**出现 `PRD.md` 一份（及其必要附件，如用户访谈记录）。任何 HOW 级别的东西请走 Layer 2。

## 可以写什么

- 项目是什么、给谁用。
- 5 个用户用例（对标现 `_mynot/1.md §2`），每个用例达成与否可机器判定。
- 需求（抽象原则级，对标现 `_mynot/1.md §3`）。
- 反例清单（对标现 `_mynot/1.md §4`）。
- 最小跑通证明 = "架构成立的唯一检验"（对标现 `_mynot/1.md §5`）。
- 项目定位（CDDA demo = test bench；项目核心 = 数据资产的保存管理；对标 `_mynot/0-bigger-project-context.md §B`）。
- 不变量（明文写死："每个功能单向"、"web 只是展示层"、"游戏画面只能 agent 读"、"server 不许合成消息"——这些之前丢过，这一层必须显式钉死）。

## 不可以写什么

- `writer` / `MoonBit constructor` / `supervisor_reflection_from_intent` 这种实现名词。
- 具体频道 schema（频道名、字段列表、签名格式）—— 归 Layer 2。
- `tmux session` / `Hermes profile` / 具体脚本文件名。
- "删掉 `cdda_sections_server.py`" / "保留 `launch-cdda-demo.sh`" 这种 cleanup 指令 —— 归 Layer 3 / Layer 4。

## 谁产出

- 首选：`/prd`（agents-zone-skillset，`~/.claude/skills/prd.md`）。
- 前置可选：`$deep-interview`（OMX）—— 如果你觉得用例或需求还有"don't assume"的坑。
- 输入素材：`_mynot/0-bigger-project-context.md` + `_mynot/1.md`（仅作历史参考，`/prd` 不许直接引用，只能拆进新结构）+ 用户当面补充。
- 输出位置：本目录 `PRD.md`。

## 冻结条件

见 `_mynot/AGENTS.md §3 "Layer 1 Intent 冻结条件"`。简版：

- [ ] 不含 HOW 词汇；
- [ ] 5 用例机器可判定；
- [ ] 反例清单完整；
- [ ] "最小跑通证明"那条守门条款显式存在；
- [ ] 之前丢过的原则（见仓库根 `PROGRESS.md` 的 `Lessons To Route` 段）全部被嵌回。

冻结动作：
1. 用户 approve；
2. 在仓库根 `PROGRESS.md` 的 Current Work 里把 `- [ ] Design` 改成 `- [x] Design`，加冻结日期到 Notes；
3. 把 `_mynot/1.md` 原文移到 `_mynot/_legacy/1-original-mixed.md`，避免下游误读。

## 下一步

Layer 1 冻结之后，`_mynot/AGENTS.md §9` Bootstrap 流程指向 Layer 2 —— 启动 `/architect`。
