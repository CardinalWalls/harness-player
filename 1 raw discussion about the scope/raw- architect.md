# cockpit — 架构笔记

> **读者测试**:把本文档中出现 *CDDA / 游戏 / 故事 / 执行 / 观察 / 策展 / RUN / L0-L3 / 三层 loop* 的段落全部删除,文档是否仍然自洽?
> 目标:第 1–6 章任一章删除任何具体场景后仍然成立;所有场景词只允许出现在第 8 章"参考拓扑"与第 9 章"参考实现现状"里。

---

## 目录

1. 一句话痛点
2. 软件定位与边界
3. kernel 词汇表(准用 / 禁用)
4. kernel 原语
5. 原语之间的关系
6. 持久化模型
7. MoonBit 的位置
8. 参考拓扑(可整章删除)
9. 参考实现现状(Hermes / OpenClaw / tmux)
10. 开放问题
11. 借鉴项目
12. 参考链接

---

## 1. 一句话痛点

**一条推理上下文同时承担产生、记录、反思、再加工,会被自己淹没。**

控制平面的任务,是让这些职责落到不同的 session 上,让它们之间通过订阅关系自然形成层级,而不是由 kernel 预先规定角色。

---

## 2. 软件定位与边界

### 2.1 我们是什么

一个 **可插拔 agent 的订阅 / 投影 / 提交 基础设施**。
kernel 提供最小原语;拓扑、角色、流程全部由 profile、skill、规则配置长出来。

### 2.2 我们不是什么(kernel 层)

- 不是 runtime:不执行 agent 推理,不调度"一次运行"。
- 不是 agent manager:agent 生命周期归 agent 框架自己。
- 不是 adapter:和外部世界(终端复用器、浏览器、MCP、文件系统)之间的翻译层属于 adapter,kernel 不关心其内部实现。
- 不是 workflow engine:没有"开始 / 结束 / 重试"。
- 不对业务内容做任何假设。

### 2.3 边界判定法

当一个功能点能被 "这属于某个具体场景" 反驳时,它就不该进 kernel;
当一个功能点被删掉,多个不相关场景都会垮,它才是 kernel 的。

---

## 3. kernel 词汇表

### 3.1 禁用词(出现在 kernel 设计 / API / 文档中视为污染)

- `run` / `run id` / `iteration` / `loop` / `tick`
- `executor` / `observer` / `coach` / `director` / `narrator` / `worker`(作为固定角色名)
- `exec lane` / `ops lane` / `story lane`
- `layer` / `level` / `L0` / `L1` / `L2` / `L3`
- "实时 / 近实时 / 低频"(这是 SLA,不是架构角色)
- 任何具体业务名词(游戏、故事、玩家、帧……)

### 3.2 准用词

| 词 | 含义 |
| --- | --- |
| session | 一个持续产出信息流的宿主挂点,没有开始 / 结束,只有 attach / detach |
| channel | 可订阅的消息流 |
| projection | 对一个或多个 channel 的投影视图(过滤、聚合、翻译) |
| subscription | 谁听谁的关系;运行时可增删改 |
| skill / profile | 某个 agent 的可版本化身份 |
| trigger / rule / hook | 事件来源 + 分发规则 + 外部响应 |
| commit / snapshot / blob | 被显式保留的"有意义时刻"及其引用资产 |
| acl / capability | 谁能在谁身上做什么 |
| adapter | kernel 与外部世界之间的翻译层 |

---

## 4. kernel 原语

每个原语只描述自己是什么、可被什么操作改变、怎么持久化。**不涉及场景。**

### 4.1 session

- 一个持续产出信息流的挂点。
- 可 attach / detach,可有多个订阅者。
- 有一份可版本化的 **session profile**:配置、权限、工具清单、身份。
- session 自己不一定是 agent;它可能是 agent,也可能是终端、外部服务,经由 adapter 暴露。

### 4.2 channel

- 一条可订阅、可投影的消息流。
- channel 来源于 session(由 adapter 把 session 产出翻译为消息),或来源于 projection。
- channel 的生命周期独立于任何 agent 的"本次推理"。

### 4.3 projection

- 对一个或多个 channel 的视图变换:过滤、聚合、再加工。
- projection 本身也是 channel(可被进一步订阅)。
- projection 的产出可以是 agent 推理结果,也可以是脚本规则;kernel 不区分。
- **"层级"不是 kernel 定义的,而是 projection 链拼出来的副产物。**

### 4.4 subscription

- `(subscriber, channel, filter, delivery)` 四元组。
- 运行时可增删改;kernel 保证一致性。
- 删除 subscription 不会杀死 channel,也不会杀死 subscriber。

### 4.5 profile / skill

- profile:某个 session 的身份包,包含系统提示、权限、工具清单、可用 skill 范围。
- skill:可版本化、可 patch、可分享的能力单元。
- kernel 负责 profile / skill 的存储、版本、分发,不解释其语义。
- profile 和 skill 可以在 kernel 管理下被运行时替换、而不必销毁 session。

### 4.6 trigger / rule / hook

- trigger:事件来源。kernel 提供若干硬触发(消息到达、subscription 变化、adapter 心跳),其余均由规则合成。
- rule:`when(trigger) then emit(event)` 的声明式配置。
- hook:对事件做外部响应的挂接点(外部命令、agent 发消息、落盘、广播)。
- **kernel 不认识具体事件语义**;语义在规则和 hook 层定义。

### 4.7 commit / snapshot / blob

- kernel 不定义"什么是值得保留的时刻",只定义:被显式 commit 的时刻会被固化。
- commit:一组引用(channel cursor、profile 版本、blob id、外部资源 id)。
- snapshot:commit 的一种特化,额外包含外部资源快照(如 pane 截图、外部存档文件)。
- blob:内容寻址的二进制存储,面向大对象。

### 4.8 acl / capability

- 每个 subject(session / external caller)持有一组 capability。
- capability 颗粒度到原语级:订阅某 channel、修改某 profile、patch 某 skill、发起 commit、打断某 session……
- capability 自身可版本化、可委托。

### 4.9 adapter

- kernel 与外部世界之间的翻译层。
- adapter 内部怎么做不是 kernel 的事;kernel 只规定 adapter 暴露出来的必须是 **session / channel**。
- 典型 adapter:终端复用器桥、agent 框架桥、浏览器桥、MCP 桥。

---

## 5. 原语之间的关系

```
adapter ──▶ session ──▶ channel ──▶ projection ──▶ channel ──▶ …
                                        │
                                        ▼
                               subscription(subject, filter)
                                        │
                                        ▼
                                   subject(profile, acl)
                                        │
           trigger + rule + hook ◀──────┤
                                        ▼
                                  commit / snapshot
```

- 信息流向由 subscription 决定,不由 kernel 预设。
- "分层"是多层 projection 的自然结果,不是 kernel 的配置项。
- "多 session 协作"是多 subscription 的自然结果,不是 kernel 的配置项。

---

## 6. 持久化模型

所有 kernel 对象的快照应满足三个条件:

1. **引用寻址**:大对象进 blob;commit 只持引用。
2. **可版本化**:profile、skill、subscription 拓扑、rule 集合均需可 diff、可回溯。
3. **外部资源可选**:kernel 不承诺冻结外部 runtime;由 adapter 决定提供何种 snapshot 能力。

commit 的分类**不由 kernel 枚举**。kernel 只定义 commit 结构;"这是一次状态存档 / 一段叙事 / 一次能力升级"属于规则层的 tag,可扩展。

---

## 7. MoonBit 的位置

- 用 MoonBit 写:kernel(原语、事件模型、subscription、projection、commit、blob 存储、规则引擎)。
- agent 框架、终端复用器、浏览器:均为 adapter。
- 目标体量:约 100 次 commit、2–3 万行。
- target 拆分建议:kernel 与 host adapter 走 native;查看端(projection viewer)视实现再决定 wasm / js。

---

## 8. 参考拓扑(可整章删除)

> **本章描述一种已经观察到的使用模式,用于验证 kernel 原语表达力。**
> **删除本章不影响 kernel 正确性。**
> **本章可以出现场景词。kernel 源码 / kernel 文档 / kernel API 不得引用本章任何概念。**

### 8.1 场景痛点

一条推理上下文里既要直接操作终端里一个长期运行的交互程序、又要记录、又要反思、又要对外讲给人听、又要接人类指令——上下文被琐碎操作淹没。

### 8.2 用原语怎么搭

- 一个 adapter 把终端复用器里一个长跑程序暴露为 session A,输出为 channel A。
- 一个 agent session B 订阅 channel A,做"意图化 projection",产出 channel B。
- 一个 agent session C 订阅 channel B,做"叙事化 projection",产出 channel C。
- 一个 agent session H 绑定到人类前端输入,订阅 channel C,同时作为 subject 向 A/B/C 广播。
- 规则:当 channel A 出现重复模式 → 触发 event,hook 调 B 的 skill patch 工具。
- 规则:当人类消息出现特定前缀 `@<subject>` → 路由到对应 subject 的 inbox,而非广播到 channel C。
- 规则:当人类发 "存档" → 触发 commit,引用所有 session 的 cursor + 外部程序的存档文件。

**这个拓扑不是 kernel 的一部分**,而是一组 profile + subscription + rule 的具体取值。换一套取值可以长成聊天室、代码评审协作、运维值班,甚至单人日志工具。

### 8.3 前端(作为一种 adapter)

- 前端订阅若干 channel 和 projection,渲染为若干面板。
- 人类输入默认进一条 "control" channel;`@<subject>` 决定路由。
- 前端不关心 kernel 里有几个 session、它们是不是 agent、是不是实时。

### 8.4 规则示例(硬 / 软 trigger 的具体取值)

- 硬:外部进程退出、心跳超时、人类消息到达、外部存档文件变化、手动 commit。
- 软:重复失败、长时间静默、confidence 骤降、被标记的"亮点"。

这些都是 **规则配置**,不是 kernel API。

---

## 9. 参考实现现状(Hermes / OpenClaw / 终端复用器)

> 本章只是"现成零件目录",说明当前哪些能力可以直接拿、哪些要自己在 kernel 里做。

### 9.1 Hermes 侧

- **profile / skill / session storage / rollback / backup / export**:基本可用。
- **agent loop API 可中断**、CLI 有 `/stop`。
- **插件的 `inject_message`**:只在 CLI 模式有效,gateway 模式不生效。
- **多 agent 协作 / 会话间消息总线 / session 列表 API**:现在没有原生能力,社区 issue 在要。
- **快照恢复的是文件系统状态**,不是外部 live process 或 PID 空间。
- 参考:plugins、agent-loop、skills、profile-commands、checkpoints-and-rollback、session-storage、sessions、configuration([1][2][3][4][5][6][7][8])、相关 feature request issue([9][10][11])。

### 9.2 OpenClaw 侧

- Gateway 的 session store / transcript 才是历史真相层,channel 不是;多端映射同一 session,但历史不完整同步回端。
- `openclaw mcp serve` 适合把历史暴露给 MCP,不适合作为动态流主总线。

### 9.3 终端复用器侧

- 定位为 **host adapter**:用 control mode / pipe-pane 做连续镜像;capture-pane 做按需快照。
- kernel 不认识终端,kernel 只认识 adapter 暴露出的 session / channel。

### 9.4 结论:三类 commit 的现成覆盖与缺口

| 目标 | 现成能覆盖 | 需要在 kernel / adapter 里自己做 |
| --- | --- | --- |
| 会话文本 / 推理 / 工具调用 | session storage、transcript、reasoning 字段 | commit 引用结构、cursor 固化 |
| profile / skill / 配置 | profile export / import | profile / skill 的 DAG 版本与 provenance |
| 大对象(截图、存档、长日志) | — | 内容寻址 blob store |
| 外部 runtime live state | — | 由 adapter 提供快照能力;kernel 只引用 |
| 叙事 / 亮点 / 分享摘要 | 有原料(transcript、reasoning) | 规则层 tag + 输出模板 |

---

## 10. 开放问题

1. **subscription 路由与背压**:多层 projection 下,如何避免 fan-out 放大与 cursor 漂移?
2. **profile 热替换**:不销毁 session 的前提下切换 profile,状态一致性边界在哪?
3. **capability 委托链**:A 把"可打断 B"委托给 C,C 再转授时的撤销语义?
4. **规则引擎表达力**:声明式规则要覆盖到什么程度,才不需要在 kernel 里为特定事件开口子?
5. **adapter 抽象**:不同外部世界(终端、MCP、浏览器、长跑进程)的共同接口是什么?一个 session 对应一个 adapter 实例,还是 adapter 可以多路复用?
6. **commit 粒度**:被命名的时刻究竟是"channel cursor 集合",还是要强制带外部资源引用?
7. **测试策略**:用 mock adapter + 脚本化 channel 事件流,覆盖全部原语的行为,不依赖任何具体业务场景。

---

## 11. 借鉴项目

- IRC / aircd:人类协作频道语义、`@target` 路由习惯。
- nostr:事件内容寻址、签名、订阅协议。
- WAL 范式:一条流不该负责记录它自己。
- Git / gitea / git 的 DAG 模型:profile / skill / commit 的版本化。
- ent.io / newtype-ai/nit:资产存储 / 分享。
- Hermes / OpenClaw:agent runtime 作为可插拔 adapter。

---

## 12. 参考链接

[1]: https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins
[2]: https://hermes-agent.nousresearch.com/docs/developer-guide/agent-loop
[3]: https://hermes-agent.nousresearch.com/docs/user-guide/features/skills
[4]: https://hermes-agent.nousresearch.com/docs/reference/profile-commands
[5]: https://hermes-agent.nousresearch.com/docs/user-guide/checkpoints-and-rollback
[6]: https://hermes-agent.nousresearch.com/docs/developer-guide/session-storage
[7]: https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/sessions.md
[8]: https://hermes-agent.nousresearch.com/docs/user-guide/configuration
[9]: https://github.com/NousResearch/hermes-agent/issues/344
[10]: https://github.com/NousResearch/hermes-agent/issues/5586
[11]: https://github.com/NousResearch/hermes-agent/issues/8948
