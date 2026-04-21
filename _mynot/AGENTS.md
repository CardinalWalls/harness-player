# `_mynot/` — 分层工作空间契约

> 本文件治理 `_mynot/` 下的全部文档工作。它**不替代**仓库根 `/AGENTS.md`（那份是 OMX / Codex 的通用操作契约）。本文件**只规定**：意图 / 架构 / 计划 / 运行手册 / 实现 这五层怎么分家、怎么交接、OMX workflow 和外部 skill 按哪一层挂进来。
>
> **根 `/AGENTS.md` 管"怎么工作"。本文件管"产出什么、按什么顺序产出、谁产出"。**

---

## TL;DR — 你只敲三条命令，其余是自动编排

**前提**（一次性）：已把 agents-zone-skillset 装到 `~/.claude/`（§5.1）；已装好 OMX；当前 shell 能跑 `$ralph` / `$ralplan`；仓库根已有 `PROGRESS.md`（不是 `_mynot/PROGRESS.md`，那份已作废）。

日常只用这三条：

| 你敲 | 在哪敲 | 它做什么 |
|---|---|---|
| `/conduct` | Claude Code 会话里（仓库根或任何子目录都行，它会向上搜 `PROGRESS.md`） | **自动编排**：读 `PROGRESS.md` → 看当前 phase → 调对应 skill / 子 agent / shell → 写回 `PROGRESS.md`。完成完整一条 story 不需要你再点"下一步"。 |
| `/hr <一句话教训>` | 同上；发现某个早先说过的原则在当前产物里丢了的时候 | **HR 回路**：把这条教训写进对应的 skill / agent / 文档的 upstream，防止它两周后又丢（详见 §7）。 |
| `$ralph` | 独立 tmux 窗 / 终端里跑 OMX | **Layer 5 执行环**。`/conduct` 到 Testing 阶段**会暂停并提示你**开一个 `$ralph`，它跑完 TDD red-green-QC 循环后把 story 标成 done，你再回到 `/conduct` 推下一条。 |

**整个流程在本仓库里长这样**（单条 story 的全生命周期）：

```
你 ──> /conduct ──> [Design]    /prd          → _mynot/1-intent/PRD.md
       /conduct ──> [Architect] /architect    → _mynot/2-architecture/ARCHITECTURE.md
       /conduct ──> [Story]     /story        → _mynot/3-plan/stories/<name>.md
       /conduct ──> [Setup]     git worktree + $ralplan  → .omx/plans/prd-<name>.md + test-spec-<name>.md
       /conduct ──> [Testing+Impl] ★ 暂停 ★
                           你开终端跑: $ralph
                           $ralph 跑红绿灯 + QC，完了 commit
                           回到 /conduct 报告"done"
       /conduct ──> [QC]        /qc           → 对抗式审计
       /conduct ──> [CI/CD]     gh pr create  → PR 开出来
       ──> PROGRESS.md 把这条 story 从 "Current Work" 挪到 "Completed"
```

剩下的文件**都是给 `/conduct` 读的，不是给你每次翻的**。

---

## 0. 这个工作空间存在的理由

上一版 `_mynot/1.md` 把意图 / 架构 / 计划 / 运行手册**糊在一份 SSOT 里**。结果是：

- 抽象原则（R1 "消息必须由真正发出者签名"、R6 "浏览器不调 `/api/*`"）和具体命令（§7 "五个 writer"、§11 "薄展示层 `cdda_sections_server.py`"）放在同一份文档里；
- 下游任何单层 plan 工具（OMX `$ralplan` 等）消费糊状输入 → 必然产出糊状 plan → 具体命令盖过抽象原则 → 实现长出 `reach_playable()` / server 代写 jsonl / 浏览器 `/api/*` 这一串与 SSOT 冲突的东西；
- 执行侧没做错，是输入端没分层。

本工作空间的唯一目的就是**把输入分好层，再喂给 OMX + skill 执行**。

---

## 1. 五层分工表

| 层 | 目录 | 产物 | 产出工具 | 下游消费 |
|---|---|---|---|---|
| 0 | `_mynot/0-bigger-project-context.md` | 大项目背景（本仓库在生态里的位置、抽取主线、反信号清单）| 手工，稳定 | 所有层 |
| 1 **Intent** | `_mynot/1-intent/` | `PRD.md`（WHAT & WHY）| `/prd`（agents-zone-skillset），或 `$deep-interview`（OMX，补漏）| 层 2 |
| 2 **Architecture** | `_mynot/2-architecture/` | `ARCHITECTURE.md`（HOW：组件边界 / 频道 schema / publisher↔subscriber / 信任链）| `/architect`（agents-zone-skillset）| 层 3 |
| 3 **Plan** | `_mynot/3-plan/stories/` | 每个功能一份 `<story>.md`（AC + 测试计划 + 文件路径）| `/story`（agents-zone-skillset）；之后 OMX `$ralplan` 按单 story 细化成 `.omx/plans/*` | 层 4 / 层 5 |
| 4 **Runbook** | `_mynot/4-runbook/` | `RUNBOOK-*.md`（怎么启动 / profile / tmux / 灭火手册）| 手工，或实现收敛后补 | 运维人 / agent |
| 5 **Impl** | 仓库代码树（`moonbit/` / `scripts/` / `web/` / `prompts/` / `~/.hermes/`）| 代码 + test | `agents/tester.md` + `agents/coder.md`（agents-zone-skillset），或 OMX `$ralph` / `executor` | —— |

**法定顺序**：0 已在 → 1 冻结 → 2 冻结 → 3 按 story 分片 → 每个 story 走 3→5（可与其他 story 并行） → 4 在实现稳定后补。

"冻结"≠"完美"。冻结 = 满足本层的 QC checklist（见 §3）+ 用户 approve。

---

## 2. 三条硬规则（单向流 / 不跨层 / 失败上报）

### 规则 A — 绝不跨层写
- Layer 1 **只**写 WHAT & WHY。禁止出现"writer"、"MoonBit constructor"、"tmux session 名字"、"Hermes profile 路径"、"具体脚本文件名"。
- Layer 2 **只**写 HOW（组件 / 频道 / schema / publisher / subscriber / 信任链）。禁止出现启动命令、skill 文件名、"删除 xxx 文件" 这种 plan 条目。
- Layer 3 **只**写单功能 AC + 测试计划 + 引用上层的哪条原则 / 哪条 schema。禁止重新论证架构。
- Layer 4 **只**写运行手册（命令、环境变量、profile、tmux session、灭火步骤）。禁止引入新架构概念。

违反上述任何一条 = 把该条挪走，不是就地修辞。

### 规则 B — 绝不向上写
下游层发现上层有漏洞时，**不**在下游文件里"顺手补"。流程是：

1. 在 `PROGRESS.md`（仓库根）的 `Upstream Gaps` 段登记：哪一层缺、缺什么、谁发现的、什么 story 受阻。
2. 停下当前层工作，回上一层打开 `/prd` 或 `/architect` 把漏洞补上。
3. 上层冻结更新 → 下层继续。

这条是**防止上一版 §11 `reach_playable` 那种事件再发生**的机制：当时没这条规则，plan 发现 bootstrap 没人做 → 就地在 plan 里塞了一个 server 端补丁 → 漂移。

### 规则 C — QC 卡在每一个交接点
- **层 1 → 层 2 交接**：`/architect` skill 必须能只读 Layer 1 PRD 产出 Layer 2 ARCHITECTURE，不许回头翻 Layer 0 或 `_mynot/1.md`。如果必须回头 → Layer 1 不完整，回去补。
- **层 2 → 层 3 交接**：story 要用的每一条频道 / 每一个 publisher-subscriber 对 / 每一条信任边界，Layer 2 必须已经定义。story 里不许出现未在 Layer 2 登记的组件。
- **层 3 → 层 5 交接**：tester 写的失败测试**只看 story 文件**，不看实现代码、不看现有测试。这是 agents-zone-skillset 的核心反共谋设计。
- **每一次交接**：问一句"这份新产物是否替换或否决了上游某条规则？" 是 → 阻断，回上游改；否 → 放行。

QC 工具：`/qc`（agents-zone-skillset 对抗式审计）或 OMX `verifier` 角色。两者只有命名差异。

---

## 3. 每层冻结 checklist（放这里，方便 skill 自检）

### Layer 1 Intent（PRD.md + MOCK-EXPECTED-RESULT.md）冻结条件

产物 = `_mynot/1-intent/PRD.md` **和** `_mynot/1-intent/MOCK-EXPECTED-RESULT.md`，两份都要存在且非空。

以下 8 条全部机械可判（conduct Design phase 跑这张表；全绿 → 自动 `[x]`，**不需要人点头**；任一失败 → `STORY-BLOCKED: <id>` + 失败清单）：

- [ ] PRD 有 ≥5 个用例标题（正则 `^### .*(Use case|用例)\s*\d+`）。
- [ ] PRD 每个用例下含 "Machine-checkable" 或 "machine-checkable" 小节。
- [ ] PRD 有 Out-of-scope 段（正则 `^##? .*(Out of scope|Out-of-scope|不做什么|范畴)`）。
- [ ] PRD Out-of-scope 段**同时**出现 `/api/`、`MCP`、`server-authored` 或 `server 合成`、`scripted screen` 或 `脚本解析`——四者至少命中三。
- [ ] PRD **不含**以下 Layer-2+ 泄漏词（大小写不敏感，全词匹配）：`tmux`、`MoonBit`、`Hermes`、`cdda_sections_server`、`reach_playable`、`jsonl`、`constructor`、`profile path`、`session name`。
- [ ] MOCK 含 happy-path 编号步骤清单（`^\d+\.` 至少 5 条）。
- [ ] MOCK 含 "Invalid" 或 "反例" 段，列 ≥3 条反模式（`/api/`、MCP、server-authored、scripted-screen 覆盖 ≥3 条）。
- [ ] MOCK 同样不含上一条列的 Layer-2+ 泄漏词。

**根 `/AGENTS.md §Intent Freeze` 的"explicit user confirmation"在分层工作流里等价于这 8 条全绿**（见根 AGENTS 那一节的 carve-out 子条）。不要在 Design phase 再叠一层"等用户确认"——那是把人工守门重复计费。

### Layer 2 Architecture（ARCHITECTURE.md）冻结条件
- [ ] 只用 Layer 1 PRD 做输入，不翻 Layer 0 / 历史 SSOT。
- [ ] 列完频道清单：名字、载荷 schema、publisher（唯一）、subscriber（一到多）、签名方。
- [ ] 列完信任链：每条频道的真伪由谁保证（= publisher 自签），谁可以拒绝（= subscriber 验签），server 的位置是"转发 / 展示"还是"中心仲裁"。
- [ ] 列完 bootstrap 路径：主菜单 → playable 由哪个频道 / 哪组 publisher-subscriber 承担（不允许"server 自己推"）。
- [ ] 列完浏览器定位：它订阅哪几条频道，它往哪条频道 publish。确认**不调 `/api/*`**。
- [ ] 列完 commit / restore 语义：commit 是 `commits` 频道上的一条特殊签名消息（R4）；restore 从 commit 重建状态（R5）。
- [ ] 每一条结论标注是从 Layer 1 哪一条原则推出来的。

### Layer 3 Plan（per-story）冻结条件
- [ ] 一份 story 只做一条因果链或一个频道的上线。
- [ ] AC 可测试（有输入、有预期输出）。
- [ ] 引用 Layer 2 的具体频道名 / schema 位置；不新增组件。
- [ ] 明确出现本 story 的 "upstream-dependency"（需要哪些 Layer 2 章节已冻结、哪些其他 story 已完成）。
- [ ] 明确出现本 story 的 "failure-mode"：哪些反例要在实现里主动避免（例如 "本 story 不许在 server 里写 channel jsonl"）。

### Layer 4 Runbook 冻结条件（实现基本稳定后才写）
- [ ] 起服命令 / 停服命令 / 健康检查。
- [ ] 依赖的环境变量、profile 路径、tmux session 名字。
- [ ] 常见故障 → 定位 → 修复步骤（从 `_mynot/_debug/` 里沉淀出来）。
- [ ] **不**引入任何 Layer 2 没有的新概念。

---

## 4. `/conduct` 自动编排细节（每个 phase 具体做什么）

**本节是操作手册，不是路由哲学**。`/conduct` 读 `PROGRESS.md`，看当前 story 的 Phase Progress 第一个未 `[x]` 的 phase，按下表执行。读这张表，你就知道自动编排每一步在干嘛、遇到事了你该怎么接管。

| conduct phase | 它调什么 | 产物写哪 | 前置条件 | 失败/异常情况你该做什么 |
|---|---|---|---|---|
| **Design** | `/prd`（agents-zone-skillset）；需求含糊时先 `$deep-interview` | `_mynot/1-intent/PRD.md` | 读过 `_mynot/0-bigger-project-context.md`；`_mynot/1-intent/README.md` 里的"禁止出现 HOW 条目"已读。 | `/prd` 问你 10 个需求问题你答不出 → **停下**，回头读 `_mynot/_debug/error_MCP.md` 和老 `_mynot/1.md`，或先 `$deep-interview`。 |
| **Architecture** | `/architect`（agents-zone-skillset） | `_mynot/2-architecture/ARCHITECTURE.md` | Design phase `[x]`；`_mynot/1-intent/PRD.md` 满足 §3 Layer 1 冻结 checklist。 | `/architect` 要回去翻 `_mynot/1.md` 或 Layer 0 才能写清楚 → **Layer 1 不完整**，回 Design，按 §2 规则 B 在 `PROGRESS.md` 的 "Upstream Gaps" 登记。 |
| **Story** | `/story`（agents-zone-skillset），**一次只开一条**；story 命名 `S<NUM>-<slug>.md` | `_mynot/3-plan/stories/S<NUM>-<slug>.md` | Architecture phase `[x]`；知道"本轮先做哪一条因果链"（通常 = PRD §用例 里的最小可验证子集，例如 "bootstrap → scene-reader 读到主菜单"）。 | 一次开了 2 条 story → 违反 §2 规则 A，把第二条挪到 `PROGRESS.md` 下一个 Current Work 槽排队，本 story 先推。 |
| **Setup** | `/conduct` 自己跑两件事：① `git worktree add` 切分支；② `$ralplan` 针对**该单条 story** 产 OMX plans。 | 分支 `new-real-100-commits-S<NUM>-<slug>`；`.omx/plans/prd-S<NUM>-<slug>.md` + `.omx/plans/test-spec-S<NUM>-<slug>.md` | Story phase `[x]`；OMX 已安装。 | `$ralplan` 报错说读不到 story 路径 → 检查它是否被喂了**单条 story**（根 `/AGENTS.md` `<keyword_detection>` 禁止多 story），不是 PRD 全文、不是 `_mynot/1.md`。 |
| **Testing** + **Implementation** | ★**这里 `/conduct` 会暂停**★<br>skillset 默认要启 `agents/tester.md` + `agents/coder.md` 两个子 agent 跑 TDD red→green。**本仓库覆盖该默认**：让 `$ralph` 接管（用户偏好 + OMX root-gate 已配好）。 | 本 story 要求的代码 + test 文件（story 里定义）；一条或多条 commit 到分支上。 | Setup phase `[x]`；`.omx/plans/prd-*.md` + `test-spec-*.md` 都存在。 | `$ralph` 启动被 root `<keyword_detection>` 门挡住 → 去看 `.omx/plans/` 是否两份都在；只有一份时 `$ralplan` 没跑完，回 Setup。<br>`$ralph` 跑着跑着偏题了（例如又要在 server 里写 channel jsonl） → Ctrl-C，在 story 里加 `failure-mode:` 条（§3 Layer 3 checklist）再重启 `$ralph`。 |
| **Quality Check** | `/qc`（agents-zone-skillset 对抗式审计） | QC 报告追加到 `PROGRESS.md` 的 Current Work → Notes | Testing + Implementation 都 `[x]`。 | `/qc` 发现 "实现过了但反例守门失败"（例如测试没覆盖 "server 不写 channel jsonl" 这条 failure-mode） → phase 打回 Implementation，让 `$ralph` 加测试再跑一轮。 |
| **Dev Testing** | 本仓库 **n/a**（没有独立 dev env） | —— | —— | `/conduct` 跑到这里直接标 `[x]` 跳过。在 `PROGRESS.md` 对应行加注释 `n/a (local demo only)`。 |
| **CI/CD** | `gh pr create --base main --head <branch>`；之后 `/follow` 盯 PR check | PR URL 写回 `PROGRESS.md`；合并后把该条 story 从 Current Work 挪到 Completed | QC phase `[x]`。 | `gh pr create` 失败 → 看 `/AGENTS.md` 的 "Tool usage" 节，多半是没 `gh auth`。 |

### 每个 phase 都要守的共通规则

1. **phase 产物只能写入表里"产物写哪"一列的路径**。`/conduct` 自己检查；如果某个 skill 偷偷在别处写了，下一次 `/conduct` 启动时 `/qc` 会在 handoff 点拦住。
2. **下游发现上游漏了**（例如 Story 阶段发现 ARCHITECTURE 没定义 `commits` 频道）→ 按 §2 规则 B 在 `PROGRESS.md` 的 "Upstream Gaps" 段登记，`/conduct` 自动把当前 phase 标回未 `[x]` 并切到上游 phase 重跑。
3. **你每次手动 kill 或 Ctrl-C 了 `$ralph`**，回来 `/conduct` 的第一件事是检查分支上有没有悬挂的 test 文件或半截实现；skillset 的 `/conduct` Phase 2 会做这件事，你不需要额外命令。

### 本表和根 `/AGENTS.md` `<keyword_detection>` 的关系

根 `/AGENTS.md` 里 `<keyword_detection>` 定义了 ralph / ralplan 的门禁（`$ralph` 必须等 `$ralplan` 产出两份 plan 才能启动）。**本表不覆写那些门，只是把它们翻译成"在 /conduct 的哪个 phase 会被触发"**。两边冲突时，根 `/AGENTS.md` 的 `<keyword_detection>` 胜。

---

## 5. 外部 skill 来源 + 调用入口

### 5.1 主套：`agents-zone-skillset`（朋友 repo，本机已 clone）

路径：`/Users/yetian/Desktop/learn-harness-manux/_repo/agents-zone-skillset/`

安装到 `~/.claude/`（一次性）：

```bash
mkdir -p ~/.claude/skills ~/.claude/agents ~/.claude/templates
cp /Users/yetian/Desktop/learn-harness-manux/_repo/agents-zone-skillset/skills/*    ~/.claude/skills/
cp /Users/yetian/Desktop/learn-harness-manux/_repo/agents-zone-skillset/agents/*    ~/.claude/agents/
cp /Users/yetian/Desktop/learn-harness-manux/_repo/agents-zone-skillset/templates/* ~/.claude/templates/
```

调用入口：

| 命令 | 触发什么 | 在哪一层用 |
|---|---|---|
| `/prd` | 产 `_mynot/1-intent/PRD.md` | Layer 1 |
| `/architect` | 产 `_mynot/2-architecture/ARCHITECTURE.md` | Layer 2 |
| `/story` | 产 `_mynot/3-plan/stories/<name>.md` | Layer 3 |
| `/qc` | 对抗式审计（tester 或 coder 声明 vs 证据）| 每次交接 |
| `/hr <教训>` | 把教训嵌回相关 skill/agent 文档 | 任何层事后 |
| `/hr audit` | 盘点所有 skill/agent 文档质量 | 周期性 |
| `/conduct` | 读仓库根 `PROGRESS.md` → 自动推进下一阶段 | 跨会话恢复 + 日常入口 |

### 5.2 辅助：Superpowers（按需单挑，不整套引入）

本机路径：`~/.claude/plugins/cache/claude-plugins-official/superpowers/<version>/skills/`

- `brainstorming` → Layer 1 开局收敛用
- `verification-before-completion` → 冻结前强制 checklist（叠加本文件 §3）
- `dispatching-parallel-agents` / `subagent-driven-development` → Layer 3 多 story 并行时用

### 5.3 抽取主线（**与本工作空间分开**）

`new-real-100-commits/extraction/references/` 里的 `context-priming.md` 等服务于 **`0-bigger-project-context.md §C`** 的抽取主线，**不**服务于 CDDA demo 重写。两条线并行，不交叉。

---

## 6. PROGRESS.md（跨会话状态）

**位置**：仓库根 `/Users/yetian/Desktop/new-real-100-commits/PROGRESS.md`。**不是** `_mynot/PROGRESS.md`（那个路径已作废）。

放在根的唯一理由：agents-zone-skillset 的 `/conduct`（`skills/conduct.md` Phase 1）在 stock 配置下从当前目录向上搜 `PROGRESS.md`；放在根下意味着你从仓库任何子目录敲 `/conduct` 都能工作，**零配置**。

**格式**：使用 skillset `templates/progress.md` 的格式（`Current Work` / `Completed` / `Blocked` 三段 + 每个 feature 的 `Phase Progress` checklist）。本仓库额外追加两段（不影响 skillset 读取）：

- `Upstream Gaps`：下游层发现的上游漏洞（触发 §2 规则 B 回路）。
- `Lessons To Route`：已知但未回路的教训（触发 §7 的 `/hr <教训>`）。

**谁读、谁改**：
- 任何 agent（你、`/conduct`、子 agent、`$ralph`）**开始**会话必须先读 `PROGRESS.md`。
- **只有 `/conduct` 主 agent**直接写 `PROGRESS.md`。子 agent / `$ralph` 只**报告**完成情况给主 agent，主 agent 更新。
- 你本人**可以**手改 `PROGRESS.md`（典型：登记 Upstream Gaps、登记 Lessons To Route、修正 phase 状态）。改完建议下一轮 `/conduct` 先 `--dry-run`。

---

## 7. HR-式教训回路（防止"说过的话又丢"）

你已经多次遇到同一种事：早先说过的原则，在新一版文档里消失。修办法**不是**只改当前产物，是把原则嵌回上游：

1. 在 `PROGRESS.md`（仓库根）的 `Lessons To Route` 段写一行"教训 + 被丢在哪个文档"。
2. 判断原则该归到哪里：
   - 如果它是"项目级原则" → 归到 `_mynot/0-bigger-project-context.md` 或 Layer 1 PRD。
   - 如果它是"某个 skill 本该教但没教的事" → 归到 `~/.claude/skills/<skill>.md`，用 `/hr <教训>` 路由。
3. 先改上游 → 再改下游产物。
4. 在 PROGRESS.md 把该条标 `routed`。

这条是本工作空间长期能自愈的关键。缺了它，两周后你会在别的文件里看到同一个"被丢的原则"重现一次。

---

## 8. 和根 `/AGENTS.md` 的关系（不重复，不冲突）

根 `/AGENTS.md` 的管辖范围：autonomy 指令、delegation rules、OMX 模型路由、keyword registry、team/swarm pipeline、Lore commit 协议、整个 OMX runtime gating。

本文件的管辖范围：哪一层产出什么、按什么顺序产、单向流、交接 QC、OMX workflow 按层怎么挂、PROGRESS.md 契约、HR 教训回路。

**组合规则**：疑问时，根文件决定"怎么做事"，本文件决定"做哪件事 / 做成什么形状"。

为了互相找到，根 `/AGENTS.md` 会新增一个 `<workspace_layering>` 段，指向本文件；本文件承担"layered workflow 权威"。

---

## 9. Bootstrap（从零接手这个工作空间怎么起步）

**短版**：打开 Claude Code，敲 `/conduct`。等它问你问题。

**长版**（只有在 `/conduct` 失败的时候你才需要看）：

1. 读 `_mynot/0-bigger-project-context.md`（大项目背景，稳定）—— 一次，以后不用再读。
2. 读本文件（`_mynot/AGENTS.md`）—— 一次，以后不用再读。
3. 确认 agents-zone-skillset 已装到 `~/.claude/`（见 §5.1 安装步骤）。
4. 确认仓库根有 `PROGRESS.md`（`ls /Users/yetian/Desktop/new-real-100-commits/PROGRESS.md`）。
5. 敲 `/conduct`。它会读 `PROGRESS.md`，自己决定下一步，告诉你它在做什么。
6. 按它的提示推进。**唯一一次你需要离开 `/conduct`** 是到 Testing + Implementation phase，它会让你开终端跑 `$ralph`（见 §4 表）。

**不**走捷径。捷径包括：
- 跳过 Design phase 直接开 Story（"反正我心里有 PRD"）→ `$ralph` 会按你的空想跑出一堆漂移。
- 一次开 2 条 story → `$ralplan` 默认拒绝，被根 `/AGENTS.md` `<keyword_detection>` 挡住。
- 手动写 `.omx/plans/` 绕过 `$ralplan` → 同样会被挡，且规避不了 `$ralph` 的 gate 检查。

---

## 10. 版本和修改

- 本文件的修改需要和用户确认；不允许 agent 悄悄改。
- §1 的五层分工表、§2 的三条硬规则、§3 的冻结 checklist、§4 的 OMX 路由表——**这四节是地基**，改这四节等同于改 SSOT 本身，走 HR 回路。
- §5–§9 是辅助条款，可以在 `/hr` 路由过程中被更新。
