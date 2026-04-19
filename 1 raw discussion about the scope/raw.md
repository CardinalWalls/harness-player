

本质上,我们是在进行软件合成比赛, 要借鉴成熟的开源软件框架和测试资产.
目标是100次commits, 大概2-3万行, 使用moonbit语言. 



直观来看, 我们是要给Hermes开发一个插件,指导它搭建一个玩游戏的场景, 并且通过web页面展示.

注意, 你需要非常理解Hermes, 它本身就是运行时内核,负责所有细节“* 管理 run / session 的生命周期
* 维护 agent、channel、projection、asset 之间的关联
* 处理事件、订阅、触发、checkpoint、commit”的执行.

但是我们的内核是可插拔的, 未来也要兼容其他agent,比如Openclaw,Claude code,等等.

我们软件的边界: 
不负责具体运行、或具体业务内容.
不负责agent的创建、编排.
不负责信息流和投影.
不负责资产的产出.
不负责runtime;
不负责adapter,Hermes自己去解析信息流;
不做agent manageer, Hermes自己就能管理,但是我们帮它做控制平面;


虽然如此,我们必须非常理解agent如何使用skill,如何使用chennel, tmux如何交互, 等等.

应当非常注意, 应当忽略我的具体场景实现(即使我没实现, 也可以通过测试用例和mock server来描述), 专注于架构.
比如, 我“用tmux跑起来CDDA游戏, 并且让Hermes在里面操作游戏”这个不是我们需要关心的, 我们只需要看到, 有一个独立session, 源源不断的产出信息流; “Hermes profile如何配置”不是我们需要关心的, 我们只需要看到, 这个session的管理需要一些配置,这个配置是可以修改、甚至版本管理的; 我们不需要关心 “一个agent玩游戏,另一个agent监督他,第三个agent讲故事”, 而只需要关心, 三个session之间是有关联的,其权限和工具是可以管理的.
不需要关心,有“ 4 类 worker”, 只需要关心定制worker需要profile和权限、工具管理, 而这些能力也需要持久化;
不需要关心“三层 view + 一条 control lane”, 而是可以随意定义, 也可以预定义一套;
不是“ 给运行时建一个分层事件壳”, 而是我们每一层都有agent接受信息产出信息,根据上下游自然就有层级关系;
不是“硬编码流程”,而是“规则引擎”, 产生了trigger,如何进行广播,具体事件配置为钩子;

我想象的一个用例:
1. 用户给自己的Hermes, 发送一个链接;
2. Hermes安装了插件,完成部署,返回一个网页链接,这个网页上展示我们预设的CDDA游戏, 对应着各自的channel, 后台自动开始部署;
3. 在tmux session 0,启动Hearmes profile 0,等待网页上的人类输入栏, 并广播给所有其他session, 触发相应条件;
4. 在tmux session 1,启动Hearmes profile 1,打开CDDA游戏, 根据预设的prompt和skill,开始游戏交互,游戏界面和chaneel信息出现在网页上;
4. 在tmux session 2,启动Hearmes profile 2, 根据预设的权限,可以使用工具获取session 1的信息流, 进行反思,根据skill指导, 发送指令、修改其prompt和skill, 帮助它不断优化游戏过程;
5. 在tmux session 3,启动Hearmes profile 3,根据预设的权限,可以使用工具获取session 2的信息流, 根据skill指导, 过滤2的信息流为游戏状态和意图信息;
6. 在tmux session 4,启动Hearmes profile 4,根据预设的权限,可以使用工具获取session 3的信息流, 根据skill指导, 过滤3的信息流为故事,通过channel直播到网页端;
7. 但2发现1进入了重复的模式,则进行反思,给1进行指导,当终于解决了问题,2把问题、解决方法制作为skill,并且进行commit;
8. 当3和4发现故事陷入重复和无趣,4找到之前预设的玩家偏好提出想法、3结合角色人设, 对2不断发出建议;
9. 当人类觉得一个故事非常不错,发消息:故事真有意思,存档! 此时0广播消息, 所有session接受到消息,保存游戏存档和整个快照,然后0进行commit,保存这些快照,意图信息写明了“故事不错、人类指令”,

我希望能从成熟开源项目中借鉴, 比如[aircd、IRC协议](https://github.com/c4pt0r/aircd/issues/1), https://github.com/nostr-protocol/nostr/ WAL范式, entire.io和gitea
newtype-ai/nit


1. 我现在已经跑通的, 是在tmux上跑CDDA的console版本, 然后把各种命令, 和capture屏幕获取信息, 包装为MCP. 

2.我在telegram chennel上, 把这个MCP交给Hermes去玩, 就实现了它在一个连贯的推理中, 自动用MCP获取信息、发送命令.  

但这个MCP写的不好, 结果还不如直接send-key.

3.  但是, 我发现它总是更新一些非常琐碎的命令, 很恼火. 我是期待它能够聪明的屏蔽信息, 给我解说有意思的部分的.

交互也不通畅, 我的命令很快就被淹没了. 另外, 它会犯错误, 不知道游戏怎么玩, 所以我需要它能够总结重复的地方, 故意的反思来解决问题, 或者能找出目前skill中错误的地方, 等等. 

但它被占满了, 很难做到. 

所以, 我觉得这个架构是不能满足我的要求的, 类似WAL范式, 一个信息流不应该负责记录它自己. 

4. 因此, 我的想法是, 需要有平行的一个agent, 去读取它的信息流, 进行反思, 帮助提示, 或者更新skill, 以及出了问题debug, 等等. 

比如, 我可以调整iteration budget, 调整skill的数量, 等等.

5. 我的第一个想法, 是把第一个agent所在的tmux, 再次包装为MCP, 然后设置第二个agent去使用MCP监控、反思. 同时, 我的telegram对接的应该是这第二个agent, 这样信息就质量高了很多.

但是说实话, 我也不确定这个抽象是否正确, 确实, 信息的过滤需要实时的agent来处理, 无法通过脚本僵硬的进行, 只是说MCP似乎不是正确的渠道来传递一个动态的tmux信息流. 

MCP写的不好, 它还不如直接capture-pane和sleep呢.  

6. 根据我的想法, 可能还需要第三个agent, 从第一个agent中过滤得到纯粹的故事性的信息, 解说给人, 这样才干净有趣.  我还希望, 能有一个故事的整体思路, 能引导游戏到我感兴趣的方向, 让我进行关键决策, 就好像游戏解说一样. 

或者是我一开始就有个扮演规则,  有个agent始终在背后为我导演, 如何让游戏有趣. 

然后, 我也可以实时交互, 影响任何一个agent. 

7. 我反思了一下, 我看到比较理想的直播动态, 是在telgram的channel里看到的,背后是Hermes的Gateway对吧? 

因此, 我可以为游戏开发一个web版的插件, 类似telegram, 作为channel跟Hermes对接. 

这个页面上还可以暴露出游戏画面, 甚至对接多个agent的信息流, 甚至自由的添加agent.

这样实现一种harness play.

这里的问题在于, 架构究竟怎样是最优雅? 我的每个channel对应一个tmux, 上面跑一个Hermes, 然后Hermes之间可以自由的获取对方的信息流? 

这像不像aircd/IRC? 

但似乎, 我不是要广播某一条消息, 而是有一个实时存在的play, 产生信息流, 通过各个agent之间的订阅关系, 最终要人类的直接交互、提前的设定、使用数据的积累, 来进行确认. 

8. 另外, 自己做的channel可以拦截信息, 这样我可以实现游玩过程的存档,

每个agent都像是在写程序, 当发现有意思的内容的时候, 就commit, 在这个基础上继续;

当解决了一些难题时候, 也要commit, 就可以积累经验;

如果知道哪个错了, 就带着错误信息, 回到某个分支. 

这个类似开源项目entire.io

9. 不一定同时只有一个地方拥有游戏. 假如人类没有在看游戏的时候, 其实可以开多个游戏并行跑.  也就是说 ”执行、观察、反思“ 其实就可以根据之前的设定, 积累素材, 产生闭环了. 
10. **执行、观察、反思、讲故事、人类交互、提交存档**塞进了同一个会话上下文里，于是上下文被琐碎操作淹没，而 OpenClaw/Hermes 这类系统本来就受上下文窗口限制，工具结果、历史消息、技能列表都会挤占窗口。OpenClaw 官方也明确说了 context 就是当前窗口里的系统提示、对话历史、工具结果等，受模型上下文上限约束 ([OpenClaw][1])。
11. WAL范式, “一个信息流不应该负责记录它自己。”
12. 并非是固定死的六个平面, 而是一个更优雅的架构. 
13. 第一个agent, 是直接跟tmux里面的CDDA互动; 它的行为是否能产出结构化的信息, 这我不确定. 可能涉及到提示词怎么注入, skill如何发挥作用, 这里需要研究. 
14. 现在有一个非常重要的点, 就是我唯一实现完全实时连续的play, 只有通过agent直接操作游戏tmux; 但我找了第二个agent, 去观测反思的时候, 就不是实时的了, 因为停下来等待. 第二个agent也很难学会说, 不要直接去控制游戏,而是间接的方式干预. 
15. 很难想象能存在一个结构化的事件流, 这肯定是过度设计了, 跟MCP的问题是一样的. 只能说通过另一个agent, 去把琐碎的操作, 包装为意图级别的action. 这个到底如何实现? 总之我正在实验, 要求观察者修改skill, 来间接的控制执行者的行为.
16. 再次强调, 我们的架构要解决的, 不是具体的游玩, 而是如何让这些功能可以可能? 真实的功能可能是”把琐碎的操作, 包装为意图级别的action语义“, ”观察者修改skill, 来间接的控制执行者的行为“
17. 现在我已经在实验了, 在telegram上的中控agent, 去协调直接执行的、监督的agent, 一共三个agent, 看起来是可以的.
18. 是否可以存在非实时的agent? 可能是可以的, 比如一个hearbeat看每个tmux的状态,比如查看最近N条提取经验,比如发现了问题,喊一个debug. 甚至说,可以所有游玩都不是实时的只要有一个主动, 进行消息的扩散,设置好扩散的机制就行了. 这样思考, 可能更容易一些. 尤其是在我们的调整阶段, 但这跟架构是两码事.
19. 专门负责叙事的agent, 也是在意图的基础上, 结合故事背景,进行信息的再加工. 还要自然的跟人类互动. 但是人类的决策,似乎并不适合让它直接转发.
20. 这里就很像聊天室了. 人类发出的消息, 究竟应该落在哪个agent? 这里人类虽然看到的是故事, 但人类发出的消息却是反思层来处理的吧?甚至可能是独特的一层,处理人类消息,告诉所有其他人. 
21. 而且真的不用写死,所有功能都可以通过skill存在,只要有三层这种信息的channel,以及快速发起agent的能力,不需要制定僵硬的plane.
22. 所以另一个角度的重点在于,skill如何进行归类, 在不同的信息层级上分布, 并且在需要的时候能被找到; 另外也涉及到,我如何提前去跑、准备这些skill,并且分享给其他人,这就是我说的,游戏资产的积累. 比如我给一个新用户,新的hermes, 那么这些skill、游戏都应该是在我们的插件里,可以直接打开用的.
23. 这里就涉及到一些范式了, 需要借鉴开源项目,比如借鉴gitea,借鉴entire.io, 借鉴skill-forge等等.
24. 最后说说人类控制平面, 我觉得telegram肯定是不理想的, 而是一个网页端, 作为多个channel,对接到Hermes, 展示消息. 人类的输入栏, 就是一个聊天channel, 可以@到各个层面, 比如直接控制命令,对故事提出意见,提出自己的方式,保存资产等等. 而且人类的输入优先级最高, 应该是一种广播模式,保证不被刷屏淹没.
25. 我们插件的本体, 就是准备好一切游戏、channel、前端、skill数据,甚至背后的基建.最后只需要一个Hermes接入, 按照skill设置好各种tmux(不一定哈),订阅相应的信息流,实际玩起来,开始产出资产. 我们插件的架构,应当尽可能优雅, 提供架构基建,而不是写实业务. 有余力的话,就慢慢加入更好的可视化、上下文管理等等. 
26. 一些技术细节,需要讨论,比如tmux是否是最优,获取信息流有没有比capture-pane更优雅的,如何剪裁技能、管理提示词,如何划分plane,适合人类的aircd/IRC如何跟编排结合;
27. 最后再强调, 我们的一等公民应该是游戏资产,就是checkpoint, 这也是为什么一开始我们要做成插件和channel,“三类提交

### 1. State Checkpoint

存：

* 游戏 save
* tmux pane snapshot
* runtime state
* recent trace slice
* current directives

用来恢复继续玩。

### 2. Story Commit

存：

* 一段完整故事
* 标题
* highlights
* 用户偏好关联
* 可分享摘要

### 3. Skill Commit

存：

* 触发 bug 的上下文
* 修复后的 skill patch
* 对应 replay case
* provenance”

28. 还有一个难题,是触发事件. 可能最硬的那一些,是游戏开始结束、游戏人物死亡、人类的交互, 但也有比较软性的,比如agent做了skill, 甚至讲故事,都可能触发,这个版本管理,虽然能想象到, 但设计一个测试用例,还是比较复杂的.
29. 最后是我们的故事要包括moonbit.下面这个说法供你思考 “
> **用 MoonBit 写运行时内核、事件模型、投影视图、checkpoint 与资产管线。**
> **把 agent 只当作可插拔 worker。**
”

## 关于适配我们游戏场景的web前端
它应该是：

* projection viewer
* control router
* commit shelf
* run switcher
* branch explorer

而不是“另一个 agent transcript”。

OpenClaw 插件本身就可以扩展 channel、tool 等能力，所以做自定义 web channel/plugin 是合理路线；只是这个 plugin 应该薄，只负责人类 ingress/egress，屏幕流和 projections 直接连 kernel。([OpenClaw][8])


* 左上：live screen / frame
* 右上：story lane
* 左下：ops lane
* 右下：lab + commits
* 顶部固定条：control lane

人类输入默认进 control lane，可 `@target`：

* `@exec 往东撤退，别捡垃圾`
* `@coach 现在太保守了，提高探索预算`
* `@director 让故事朝宗教/寒冬/背叛方向发展`
* `@story 别播报琐碎拾取，只讲关键转折`
* `@runtime checkpoint`

这样你的人类交互就不会被 story feed 淹没。

## 关于trigger的讨论,

触发源分两类：

### Hard Trigger

* process exit
* save detected
* human message
* heartbeat timeout
* death-screen detected
* manual checkpoint

### Soft Trigger

* novelty 高
* repeated failure
* long silence after danger
* chapter boundary
* skill confidence drop
* story-worthy highlight

然后配置规则：

* 触发什么 event
* 是否请求 commit
* 是否要暂停 executor
* 是否要喊 Coach / Distiller
* 是否要向人类弹 choice

## 关于资产系统的讨论

**Git-shaped commit graph + content-addressed blob store**

### State Checkpoint

存：

* save 文件
* pane snapshot / scrollback slice
* active directives
* active overlays
* 最近 trace slice
* 当前 projection cursor

### Story Commit

存：

* 一段完整 story arc
* title / highlights
* linked checkpoint
* 用户偏好标签
* 可分享摘要
* 相关 frame / screenshot 引用

### Skill Commit

存：

* failure slice
* patch diff
* replay case
* provenance
* evaluation result

也就是说：

* 小文本对象、manifests、patches 走 Git-like DAG
* 大对象（save、截图、长日志）走 blob store
* commit 里只引用 blob id

这样你既有“像开源项目一样提交”的感觉，又不会让 Git 承受所有二进制和高频 trace 噪音。


## 记录关于OpenClaw的机制
OpenClaw 自己的 source of truth 也不是某个 channel，而是 Gateway 持有的 session store 和 transcript；多个设备/频道可以映射到同一 session，但历史不会完整同步回每个客户端，所以 channel 天生不适合当你的主真相层。([OpenClaw][2])

`openclaw mcp serve` 适合把已有 channel conversation 暴露给 MCP 客户端，但它的 live queue 只在桥接存活时驻留内存，断开就丢，所以它适合控制面和历史读取，不适合当动态 tmux 流的主总线。([OpenClaw][3])

tmux 更合适的位置是 **host adapter**。它有 control mode 这种可解析的文本协议，`pipe-pane` 可以持续镜像 pane 的新增输出，而 `capture-pane` 适合按需快照；所以实时流应该靠 control mode / pipe-pane，snapshot / replay 才用 capture-pane。([GitHub][4])

MoonBit 也确实适合做这个内核：它支持 WIT/component model、host imports 和多 target；但官方 async runtime 目前对 native 支持最好，尚不支持 Wasm，所以 **run kernel + tmux host bridge 先走 native，viewer / projection model 再走 wasm 或 js** 才是最稳的拆法。([MoonBit Documentation][5])

## 记录一下Hermes 的机制.

“现在研究下, 如何通过一个skills, 就让Hermes做到如下事情
1. 创建子Hermes, A,B,C, 可以设定它们的iteration budget, 剪裁skills的范围, 设置任务提示词;
2. 各自自动对接到channel 1, 2, 3, 这三个都是我自己开发的, 能在同一个网页中呈现;
3. 后续, 我可以方便的点击添加按钮,创建新的agent+chanel, 并且呈现在前端里.
4. Hermes的信息流, agent自己的推理, 跟它输出到channel中的信息, 究竟是怎么区分的? 这个推理的过程, 除了它自己调用工具, 能否被打断加入消息? 
5. 我如何让一个agent的权限是可以暴露出来的, 比如别的agent可以获取它的信息流、 修改它skill的内容、重启、 打断它加入消息? (我知道tmux能做到)
6. 如何获取这个agent的所有数据, 做快照, 或者加载已有的快照, 甚至做版本管理? “
### 1. State Checkpoint

存：

* 游戏 save
* tmux pane snapshot
* runtime state
* recent trace slice
* current directives

用来恢复继续玩。

### 2. Story Commit

存：

* 一段完整故事
* 标题
* highlights
* 用户偏好关联
* 可分享摘要

### 3. Skill Commit

存：

* 触发 bug 的上下文
* 修复后的 skill patch
* 对应 replay case
* provenance””

”

30. 这种临时委派的`delegate_task`, 并不是我关注的对象, 只能用来压缩上下文;
31. 我需要长期可见的agent“
* A/B/C 长期存在
* 各自接自己的 channel
* 你能点按钮新增 agent+channel
* 你能读它信息流、打断、重启、改 skill、快照、版本化

**Hermes 现在原生不提供这一整套。**
GitHub 上当前公开 issue 也正好说明了这一点：现在的 child agent 更像“委派工具”，不是你要的“真正多 agent 协作与管理系统”；还没有原生的 session 列表、按 session 发消息、agent 间共享消息总线这类管理面。([GitHub][3])”

32. 目前已经跑通的, 是用tmux session, 直接跑独立的hermes profile; 创建好后, 用tmux send-keys发送start up prompt;而skill文件是共享的;
33. 我不确定是否需要MCP来做,agent manager, 感觉skill也能做.“* `agent_spawn(name, clone_from, system_prompt, max_iterations, toolsets, skill_whitelist, channel_id)`
* `agent_start(name)`
* `agent_stop(name)`
* `agent_restart(name)`
* `agent_send(name, message, interrupt=false)`
* `agent_interrupt(name)`
* `agent_tail(name, include_reasoning, include_tools)`
* `agent_patch_skill(name, skill_name, patch)`
* `agent_export(name)`
* `agent_import(name, snapshot)`
* `channel_bind(name, channel_id)`”
但同样的能力, 我需要前端可以用按钮交互也能完成, 比如加一个agent和channel. 

34. 还不太明白插件怎么用“插件可以加工具、命令、hooks；MCP server 是官方建议的“把外部系统接入 Hermes”方式。([Hermes Agent][4])”
35. 特别是如何进行定制: “
从官方开发文档和存储 schema 看，Hermes 会把这些维度分开：

* 最终 assistant 内容
* reasoning
* reasoning_details / codex_reasoning_items
* tool_calls / tool_name
* 其他消息内容
  session storage 里也有专门字段存这些。([Hermes Agent][8])

另外，reasoning 展示本身也有独立控制，CLI 里有 `/reasoning`。([Hermes Agent][9])”
比如能不能
显式加一个 tool，例如：

* `channel_post(channel_id, content, visibility="public")`

这样只有 agent 调了这个 tool，内容才进入频道。

36. 我希望的是某个tmux session中的消息流动, 不会被agent的生命周期影响. 
一方面, 我听说有tmux control;
另一方面,好像可以定义ACL, 然后控制对每个 agent 暴露一组受控工具;

至于信息流的过滤分级, 我希望不是对我们这个游戏专门设计, 而是比较普世的, 比如“
## L0 Public Channel

只看 agent 发到频道里的内容。

## L1 Transcript

能看会话文本，但不看 reasoning。

## L2 Debug Stream

能看 transcript + tool calls + status。

## L3 Full Introspection

能看 reasoning、messages、skill tree、config、checkpoint、可中断、可 patch。”
可能就太具体, 本质上, 这些信息分层不是天然就有的, 而是每个session中agent的具体产出, 不好写死.


37. Hermes 的 agent loop API 是可中断的；CLI 也有 `/stop`。官方文档写明中断时会放弃当前 API 线程，不会把半成品乱注入。([Hermes Agent][8])
插件里有 `ctx.inject_message(...)`，**但文档明确说它只在 CLI 模式有效，gateway 模式返回 `False`**。([Hermes Agent][4])
再加上公开 issue 里也有人在要“异步 steering / 非阻塞 delegation / 会话发消息”的能力，说明这块现在还没真正成型。([GitHub][10])

38. Hermes docs 里写得很直白：agent 能修改、创建、删除 skill；skills 在文件系统里。([Hermes Agent][12])

所以如果你用 profiles，每个 agent 的 skill 目录天然隔离

39. 下面的说法需要区分“## Hermes 已有的几种能力

### 1) 全局备份 / 恢复

有 `hermes backup` / `hermes import`。([Hermes Agent][13])

### 2) profile 级导出 / 导入

有 profile export/import，适合“一个 agent 一个打包体”。([Hermes Agent][14])

### 3) session 导出

有 `hermes sessions export`，适合拿 transcript。([GitHub][15])

### 4) rollback / checkpoints

Hermes 有自动 checkpoint 和 `/rollback` 机制，用 shadow git repo 记录 destructive 操作前状态，可 list/restore/diff。([Hermes Agent][16])

### 5) session DB

状态库里本来就存消息、reasoning、tool 调用这些。([Hermes Agent][17])

---

## 但要注意：Hermes 的“快照”不等于你要的“运行时整机冻结”

文档里对持久化/快照的说明非常关键：恢复的是**文件系统状态**，**不是 live process、不是 PID 空间、不是后台任务**。([Hermes Agent][18])

所以你列的：

### State Checkpoint

你要存：

* 游戏 save
* tmux pane snapshot
* runtime state
* recent trace slice
* current directives

这里只有一部分是 Hermes 原生覆盖的：

* recent trace slice：可以
* current directives：可以
* 会话消息/推理/tool log：可以
* skill / config / SOUL / profile：可以

但：

* **tmux pane live state**
* **后台进程 exact continuation**
* **游戏 runtime 进程内存态**

这些 Hermes 不能替你做，得你自己做。

---

# 你的三类 commit，我给你落地成可执行模型

## A. State Checkpoint

用途：恢复继续玩

### 应包含

* game save
* tmux pane screen dump
* 当前工作目录/branch/worktree
* Hermes profile export
* sessions export
* state DB slice
* 当前 directives / SOUL / active toolset
* channel cursor / last delivered event id

### 实现建议

* 内容世界自己负责存档：例如 CDDA save
* tmux 负责 pane capture
* Hermes 负责 profile export + sessions export
* 工程代码用 git worktree / branch
* manager 写一个 `checkpoint.json`

### 结论

**State Checkpoint 不能只靠 Hermes。**
它必须是：
**content runtime snapshot + Hermes profile/session snapshot + workspace snapshot** 的组合。

---

## B. Story Commit

用途：存一段完整故事、标题、highlights、用户偏好关联、可分享摘要

### 数据来源

* channel transcript
* assistant final outputs
* reasoning 中抽出来的关键节点
* tool/action log
* 用户偏好和 session manifest

### 存成什么

* `story.md`
* `story.json`
* `highlights.json`
* `share-card.json`
* provenance link

### 这类东西 Hermes 没有现成一键成品

但 session DB、reasoning 字段、导出 transcript 已经给了你原料。([Hermes Agent][17])

---

## C. Skill Commit

用途：存 bug 上下文、修复后的 skill patch、replay case、provenance

### 应包含

* 触发时的 transcript slice
* 对应 reasoning / tool trace
* 相关 skill 旧版本
* patch 后 skill 新版本
* replay 脚本或 test case
* checkpoint id / git commit / profile id

### 推荐实践

* 每个 agent 独立 skills 目录
* skill patch 走 git
* replay case 单独落库
* provenance 指向 session export + checkpoint
”


[1]: https://hermes-agent.nousresearch.com/docs/user-guide/features/skills?utm_source=chatgpt.com "Skills System | Hermes Agent"
[2]: https://hermes-agent.nousresearch.com/docs/user-guide/features/delegation "Subagent Delegation | Hermes Agent"
[3]: https://github.com/NousResearch/hermes-agent/issues/344 "Feature: Multi-Agent Architecture — Orchestration, Cooperation, Specialized Roles & Resilient Workflows · Issue #344 · NousResearch/hermes-agent · GitHub"
[4]: https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins "https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins"
[5]: https://hermes-agent.nousresearch.com/docs/user-guide/features/api-server "API Server | Hermes Agent"
[6]: https://hermes-agent.nousresearch.com/docs/user-guide/profiles "https://hermes-agent.nousresearch.com/docs/user-guide/profiles"
[7]: https://hermes-agent.nousresearch.com/docs/user-guide/features/dashboard-plugins "https://hermes-agent.nousresearch.com/docs/user-guide/features/dashboard-plugins"
[8]: https://hermes-agent.nousresearch.com/docs/developer-guide/agent-loop "https://hermes-agent.nousresearch.com/docs/developer-guide/agent-loop"
[9]: https://hermes-agent.nousresearch.com/docs/user-guide/messaging/ "https://hermes-agent.nousresearch.com/docs/user-guide/messaging/"
[10]: https://github.com/NousResearch/hermes-agent/issues/5586 "feat: non-blocking background agent delegation (async_delegation toolset) · Issue #5586 · NousResearch/hermes-agent · GitHub"
[11]: https://github.com/NousResearch/hermes-agent/issues/8948 "feat: multi-agent A2A — sessions_list/history/send/spawn tools · Issue #8948 · NousResearch/hermes-agent · GitHub"
[12]: https://hermes-agent.nousresearch.com/docs/user-guide/features/skills "https://hermes-agent.nousresearch.com/docs/user-guide/features/skills"
[13]: https://hermes-agent.nousresearch.com/docs/reference/cli-commands "https://hermes-agent.nousresearch.com/docs/reference/cli-commands"
[14]: https://hermes-agent.nousresearch.com/docs/reference/profile-commands "https://hermes-agent.nousresearch.com/docs/reference/profile-commands"
[15]: https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/sessions.md "https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/sessions.md"
[16]: https://hermes-agent.nousresearch.com/docs/user-guide/checkpoints-and-rollback "https://hermes-agent.nousresearch.com/docs/user-guide/checkpoints-and-rollback"
[17]: https://hermes-agent.nousresearch.com/docs/developer-guide/session-storage "https://hermes-agent.nousresearch.com/docs/developer-guide/session-storage"
[18]: https://hermes-agent.nousresearch.com/docs/user-guide/configuration "Configuration | Hermes Agent"
[19]: https://hermes-agent.nousresearch.com/docs/user-guide/git-worktrees "https://hermes-agent.nousresearch.com/docs/user-guide/git-worktrees"
。
