# 大项目上下文（非 CDDA demo SSOT）

> 本文件**不是** CDDA demo 的 SSOT。CDDA demo 的 SSOT 是 `1.md`。
>
> 这里放的是"本 repo（`new-real-100-commits/`）作为大项目本体，它在更大生态里怎么定位、从哪里取料、按什么总纲领做事、哪些过时信号要主动反对"所需的最少背景。动 CDDA demo 时**不需要**改这个文件；动项目开发总纲、抽取候选清单、test-asset 主线、或要推翻一条外部结论时，改这个文件。
>
> 外部 discussions 原文：`/Users/yetian/Desktop/finall-start-100-commits-team-live-scene/docs/discussions/`
> 外部 specs 镜像：`/Users/yetian/Desktop/finall-start-100-commits-team-live-scene/docs/specs/`

## A. 大项目一句话

> 一个围绕 **skill + profile + topology** 的 agent 软件资产**捕获、结构化、分享、复现**系统。Hermes 是第一个宿主运行时，Git 是第一个出处(provenance)载体。Git-原生捕获的成熟架构思想、checkpoint 分支形状、capture/commit 联动策略——**从 `entire.io` 这类成熟外部框架抽取**，不是我们自己从 0 发明。我们用 MoonBit 手写的那一层**目前只是 demo**，离"软件"还差一段距离；要成为真正的软件，靠的是 §C 的总纲领：**抽取成熟架构 + 抽取测试资产**，而不是闭门造车。

出处：`discussions/2026-04-19-architecture-research-report.md` §"Executive summary" / §"Recommended split"；`discussions/2026-04-19-software-synthesis-subject-comparison.md` §"Git decision"。

## B. 本 repo 在生态里的位置

`new-real-100-commits/` **就是大项目本体**，不是任何东西的 sub-repo。

它内部和外部的关系：

- **CDDA demo（`1.md` 所治理的那套）= 本项目内的 test bench**。CDDA 不是产品，也不是项目身份；它只是用来把底座顶到真实压力场里的测试场景。换成别的游戏/别的软件/别的场景也应该能跑——跑得动才算架构漂亮。
- **已有的实物参考 `MoonBit-100commits/cdda-demo/`**（兄弟目录）—— 我们已经真跑过一遍的 tmux + Hermes + MCP proxy 运行参考，是 test bench 的"已有实物证据 / 运行参考 / 失败恢复参考"，不是产品。
- **真实开源项目**（§D 对标表里列的那些 —— `entireio/cli`、Hermes、Gitea、skill-forge、anthropics/skills、mizchi 系列 Git 包……的**源码和官方文档本身**）= **架构抽取 + 测试资产抽取的唯一合法来源**。我们**直接**读它们的代码、docs、test fixtures 来做抽取。
- **外部需求澄清辅助**（`finall-start-100-commits-team-live-scene/docs/discussions/`、同 repo 下的 `docs/specs/` 镜像、以及所有 `MoonBit-100commits-*` 兄弟 repo）= **只用于敲定我们的需求**，里面有用的不多；**不是架构抽取源，也不是 test-asset 抽取源**。从它们这里可以取"我们到底想要什么"这个方向，仅此而已。把 discussions 里的某个总结复制过来当作抽取产物是**错误操作**（见 §H.8）。
- SSOT（本文件 + `1.md`）是仲裁者，但 **SSOT 的内容必须来自对真实开源项目的抽取**，不是我们凭空写出来的，也不是从 discussions 里搬过来的。

等价关系：

- CDDA demo 跑不通 → 底座没有真实资产被压过 → 底座是纸面。
- 底座做不出来 → CDDA demo 只是一个会玩游戏的多 agent 小玩具。
- **抽取工作（§C）做不出来 → 我们就是在自己玩泥巴，MoonBit 手写的那一层永远停在 demo。**

## C. 项目开发总纲（两条并列主线）

> **我们就是要抽取成熟的架构、测试资产，而不是自己在这里玩泥巴。**

这是本项目的总纲领。它推翻了任何"原创靠自己从 0 合成"的叙述。项目实质产出只有两类，相应地我们只做两条主线工作：

### C.1 主线一：架构抽取

**源**：`entireio/cli` / Hermes / Gitea / skill-forge / anthropics/skills / mizchi 系列 Git 包等**真实开源项目**（的源码 + 官方文档本身，**不是** discussions 里对它们的总结）。

**做什么**：系统性地**分辨并抽取**成熟的架构思想、接口形状、数据模型、流程分支。

成熟度**不来自** MoonBit 手写的那一层，而来自这些被抽取对象本身已经在真实世界里跑过、被验证过。

抽出来的东西落地为：provenance 分支形状、capture/commit 联动策略、skill 包格式、profile 语义、topology 归一化、hosted 产品切分……

### C.2 主线二：测试资产抽取（独立主线，见 §E）

**源**：同样是那批**真实开源项目**（源码 + 官方文档 + 它们自带的测试 fixtures）。

**做什么**：系统性地提炼真实的 test assets（skill 包样例、profile 导出、checkpoint metadata 样例、topology pattern、mock 边界样本、负向案例……）。

test-asset 抽取**不是** C.1 的附属产物，是独立一级主线。它的源头规范、收集计划、落地面都有独立位置（见 §E）。

### C.3 两条主线都禁止的事

- 闭门造车、自己在这里玩泥巴。
- 把未经抽取的手写代码当作原创卖点。
- 用"我们自己合成的才算原创"的叙述来回避抽取工作。
- 只给出索引而不做有意义的知识抽取（当前 discussions 消化和外部项目分辨**都还卡在索引阶段**，这是必须推进的瓶颈）。
- **把 discussions / 外部 specs 的条目直接复制过来当作抽取产物**。discussions 只能用来敲定需求，抽取必须去读真实开源项目的源码 + 官方文档。

### C.4 工作空间

两条主线的唯一工作空间：`new-real-100-commits/extraction/`。

- `extraction/AGENTS.md` — 工作空间硬约束（先读）
- `extraction/METHOD.md` — 两条主线共用的 5 步法
- `extraction/sources/` — 真实开源项目 clone（不入库）+ `PIN.md`
- `extraction/architecture/` — 架构抽取产物（模板：`architecture/_template.md`）
- `extraction/test-assets/` — 测试资产抽取产物（模板：`test-assets/_template/`）
- `extraction/requirements/` — 从外部 discussions / specs 消化出来的"要什么"（**仅**此目录允许引用 discussions；见 §H.8）

凡是 §D / §E 的推进，都从这个 workspace 立项、走流程、写产物。

## D. 抽取候选清单（原对标表，重新定性）

这张表里每一个外部项目都是**架构抽取候选**或**test-asset 抽取候选**。**它们最终都会被丢弃**——我们保留的是从中抽出来的结构/策略/test assets，不是继续依赖它们本体。

"分辨"就是指：在这张表的每一行里，决定**哪些部分可学**（抽出来）、**哪些部分不可学/不适用**（丢掉）。

| 外部项目 | 抽取什么思想 | 抽取什么 test assets | 丢弃什么 |
|---|---|---|---|
| **Agent Skills**（`agentskills.io`, `agentskills/agentskills`） | skill 包格式、metadata/compatibility/allowed-tools、progressive disclosure | canonical / template skill | 无产品形态可抽（它只是标准） |
| **anthropics/skills** | 高质量真实 skill 打包模式（带 `scripts/` / `references/` / `assets/`） | 真实 skill 文件夹样例，覆盖打包、校验、依赖、二进制 | Claude/marketplace 专属指令 |
| **motiful/skill-forge**（MIT） | "skills 是代码"、validation、安全扫描、注册、发布流水线 | validation / publish pipeline 的 mock 输入 | 它作为独立产品的整体形态 |
| **entireio/cli**（MIT） | 一边工作一边 capture、commit 时才落 checkpoint metadata、元数据放单独分支 `entire/checkpoints/v1`、local-vs-synced 切分 | `checkpoint_metadata_test.go` / `metadata.go` 形状 | code-session 可解释性产品的业务范围 |
| **Gitea**（`go-gitea/gitea`，MIT） | self-hosted Git 产品形态、API-first、部署/DB 切分 | hosted management API 的 mock 输入 | 通用 Git 托管的整体实现 |
| **Hermes**（`~/.hermes/`, `hermes-agent.nousresearch.com`） | profile、skill 目录、session、gateway、plugin 机制、runtime event 边界 | bundled skills、profile 样例 | Hermes 作为中心产品的定位 |
| **GitHub / Gitea / 自托管 Git** | Git 托管本身 | — | 重新发明 Git 托管 |
| **mizchi/git, mizchi/libgit2**（MoonBit 生态） | MoonBit 原生 Git 能力（packfile 生成、repo 持久化、object 构造、upload-pack、libgit2 绑定） | — | 完整 Git 解决方案 |

凡是没列在这里的外部项目，都是过去讨论里没被正式纳入抽取的新来源，要先改这张表才能引入。

出处：`discussions/2026-04-19-first-wave-concrete-asset-sources.md`、`per-source-extraction-notes.md`、`extraction-rules-and-quality-grading.md`、`seed-rules-reference.md`、`moonbit-native-candidates-matrix.md`。

## E. 测试资产抽取（独立主线）

**`test-asset` 抽取升级为与架构抽取并列的一级主线**，不作为任何其他工作的子项。

### E.1 定位

- 独立主线。有独立源头规范、独立收集计划、独立落地面。
- 必须能产出**真正有意义的知识抽取**，不能停在索引层。当前 discussions 和外部项目的消化都**还卡在索引层**——这一段必须补上。

### E.2 源头规范（改这两处就动了整条主线的骨架）

- **层定义**：`/Users/yetian/Desktop/MoonBit-100commits/40-test-assets/README.md` —— 规定 `40-test-assets` 这一层只负责"提前暴露 bug、mock、反例、失败信号、复现前提、可被下游 contract/tdd 直接认领的风险"，**不写 contract、不写实现方案**。
- **任务规格**：`/Users/yetian/Desktop/MoonBit-100commits-asset-handoff-loop/specs/task-asset-handoff-test-assets.spec.md` —— 规定 test-assets 文档必须覆盖 mock 样本、负向案例、演示脚本、测试数据来源、参考项目映射；每项资产都能 Trace 回 story / architecture / contract。

### E.3 外部收集计划

- first-wave 源清单与用途：`discussions/2026-04-19-first-wave-concrete-asset-sources.md`
- 具体 corpus candidates（含已经 clone 到 `/tmp/omx-research/` 的路径）：`discussions/2026-04-19-seed-asset-corpus-candidates.md`
- mock 边界清单：`discussions/2026-04-19-seed-mock-boundaries.md`
- 每个源怎么抽 / 放哪个桶：`discussions/2026-04-19-per-source-extraction-notes.md`
- 抽取质量分级：`discussions/2026-04-19-extraction-rules-and-quality-grading.md`

### E.4 本项目内的 test-asset 落地面

- `new-real-100-commits/fixtures/`
- CDDA demo 产出的 `artifacts/`（从 test bench 压出来的真实资产）

### E.5 当前状态与瓶颈

- discussions 侧的收集计划**已经存在**，但**没有被转成有意义的抽取产物**，目前还只是索引 + 规划。
- 本 SSOT 要求：下一步推进必须把"有意义的知识抽取"作为硬性产出，不允许再以索引交差。

## F. MoonBit 实现层的当前状态与边界

### F.1 当前状态

- MoonBit 手写的这一层目前**只是 demo**，不是软件。
- 它要升级为软件，唯一的路径是 §C 两条主线真跑起来：架构从 §D 抽出来、test assets 从 §E 抽出来，用它们把 MoonBit 这一层顶到成熟度。

### F.2 边界立场（锁定反过时信号）

**MoonBit 应当尽可能深入到 Hermes 对接层。**

反面的陈述 —— "Hermes plugin 那一层不要硬塞 MoonBit，Python 薄壳即可" —— **是过时的，已被本 SSOT 明确推翻**。任何文档、PR、代码评审、任务拆分里出现"Hermes 层只能 Python 薄壳 / MoonBit 进不去"这种说法，都应被视为**错误信号**，按本节标准驳回。

具体立场：

- Hermes 对接层的**可以**薄，但"薄"指**职责薄**（只翻译、不决策），不是**语言薄**（不许用 MoonBit）。
- MoonBit 在这一层负责：把 Hermes 吐出来的 runtime 事件映射成我们的内部 capture 记录；把我们打包好的 `skill + profile + topology` 送进 Hermes；**在这一层就做掉 schema 校验、版本协商、错误规整**。
- 如果某个 Hermes ABI 暂时没有 MoonBit 绑定，用 **MoonBit 的 virtual package + FFI** 把它切干净——**不是**放弃 MoonBit。
- Python 可以存在，但**只作为 Hermes 自己那边强制要求的 entrypoint 外壳**（`plugin.yaml` + `__init__.py` 的注册胶水），业务逻辑不进 Python。

反方向也用 virtual package 切干净：MoonBit-native Git 后端 vs libgit2 后端；本地 blob 后端 vs 远程后端；本地-only 控制面 vs 托管实现。

出处：`discussions/2026-04-19-architecture-research-report.md` §2a "Hermes plugin reality is important"。**注意**：那篇报告原文的推论"keep the Hermes-facing shell thin"我们接受；但报告里**暗含的"MoonBit 不进 Hermes 这层"不被接受**，已被本节覆盖。

## G. 可分享资产的单位 = `skill + profile + topology`

来自 `discussions/2026-04-19-software-synthesis-subject-comparison.md` 第 156-190 行。

**默认对外分享**：
- `skill`（这个 agent 会什么——`SKILL.md` + 可选 scripts/references/assets）
- `profile`（这个 agent 怎么跑——模型、参数、技能目录配置）
- `topology`（agent 之间谁订阅谁、谁往哪条频道发；结构层，不带 runtime binding，见 `discussions/2026-04-19-topology-defaults-and-test-asset-priority.md` §"Layer split"）

**默认不对外分享**（可留在本地作为 provenance）：
- 原始 trace、tmux 状态、运行中的 runtime context、checkpoint 内部细节

分享成功的判据：**另一个人拿到 `skill+profile+topology` 包，在他自己的 Hermes 上能复现同样的"核心体验"** —— 不是逐字节复现原过程，而是能再跑出同样形态的工作。

这正是 CDDA demo SSOT `1.md` §4 commit 冻结的东西、§5 restore 重建的东西的本体。CDDA demo 里说的"冻结 agent 配置/技能/拓扑/信息流"，对应到这里就是 `profile/skill/topology/trace`。

## H. 本 SSOT 明确反对的过时信号（反信号清单）

这里记录本文件与若干老 discussion / 老 spec / 老 SSOT 草稿**显式冲突**的结论。老文档留在那边作为历史，**但它们的这些说法不再生效**：

1. **"我们用 MoonBit 手写的那一层是原创中心 / 是本项目的软件主体"** —— 见 §A、§F.1。那一层目前**只是 demo**；真正的软件主体靠 §C 两条主线的抽取产出。
2. **"借鉴是方法，自己合成才是原创"** —— 见 §C。**我们就是要抽取成熟的架构、测试资产，而不是自己在这里玩泥巴**。"自己合成"式叙述被本 SSOT 推翻。
3. **"Git-原生底座 ≠ entire.io，是我们自己从 0 写的 MoonBit 层"** —— 见 §A。Git-原生捕获的成熟思想就是从 `entire.io` 这类外部成熟框架抽取的，我们自己没从 0 发明；MoonBit 是实现载体，不是原创性来源。
4. **"Hermes plugin 那一层不要硬塞 MoonBit，Python 薄壳即可"** —— 见 §F.2。MoonBit 要深入 Hermes 对接层；Python 只作为 Hermes 强制要求的 entrypoint 外壳。
5. **"new-real-100-commits/ 是子项目 / 是 CDDA test bench"** —— 见 §B。本 repo 就是大项目本体；CDDA demo 才是 test bench。
6. **"test-asset 抽取是 D 节下一个子条目 / 是'顺手收集'"** —— 见 §E。test-asset 抽取升级为与架构抽取并列的**独立一级主线**。
7. **"discussions / 外部项目已经消化完了"** —— 见 §C.3、§E.5。当前**只做了索引**，**有意义的知识抽取还没产出**，这是硬瓶颈，不是"已完成"。
8. **"可以直接从 discussions / 外部 specs 里抽架构或 test assets"** —— 见 §B、§C.1、§C.2。discussions 和外部 specs **只用于敲定需求**，不是架构/test-asset 的合法来源。合法来源是真实开源项目的源码 + 官方文档。把 discussions 的一段话复制过来贴到 extraction 产物里算错误操作。

任何文档如果重新引入这八条之一，**必须先改本节**才能生效。review / PR / 任务拆分碰到这些说法按错误信号处理。
