1. 创建 tmux session
tmux new-session -d -s clone_hermes -x 140 -y 50 "hermes -p cdda"
- -d：后台运行
- -s clone_hermes：session 名字
- -x 140 -y 50：窗口大小
- "hermes -p cdda"：启动的命令

这会在 tmux 里开一个窗口，跑 hermes -p cdda 这个进程。

2. 我直接用 terminal 工具调的 tmux，没有用 delegate_task

我没有用 delegate_task 工具。我直接调 terminal 执行 shell 命令。

3. Profile 是独立的

每个 tmux session 跑 hermes -p cdda，所以每个都加载 /Users/yetian/.hermes/profiles/cdda/config.yaml。

但注意：每个 session 的 HERMES_HOME 是独立的进程内存，skill 文件是同一个（~/.hermes/skills/gaming/cdda-agent/SKILL.md），所以 patch skill 文件会同时影响所有 session。

4. 流程是这样的
tmux new-session -d -s clone_hermes "hermes -p cdda"
    ↓
Hermes 进程启动，读 profile cdda
    ↓
启动完成后，Hermes 进入等待输入状态
    ↓
我用 tmux send-keys 往它的 pane 发 startup prompt
    ↓
Clone 的下一次 iteration 读到 prompt，开始工作
5. 所以我没有用 delegate_task

delegate_task 是 spawn 独立的子进程。我用的是 tmux session——每个 session 是独立的 tmux 窗口，有自己的 terminal 状态。

6. 共享的 skill 文件

所有 session 都读同一个 skill 文件（~/.hermes/skills/gaming/cdda-agent/SKILL.md）。所以 patch 这个文件，所有 session 下一个 iteration 都会读到。

---

所以架构本质是：tmux session 容器 + hermes 进程 + 共享 skill 文件。

完整清单

1. 正在跑的 TMUX Sessions（CDDA 相关）

| Session | 用途 | 命令 |
|---------|------|------|
| hermes-cdda | CDDA 游戏本身 | cataclysm 二进制 |
| clone_hermes | Clone Agent（演员） | hermes -p cdda |
| supervisor | Supervisor Agent（监督者） | hermes -p cdda |
| cdda-mcp-proxy | CDDA MCP 端（8766） | mcp-proxy --port 8766 |
| clone-hermes-mcp-proxy | Clone MCP 端（8767） | mcp-proxy --port 8767 |

---

2. 各 Agent 的发起方式

Clone（演员）：
tmux new-session -d -s clone_hermes -x 140 -y 50 "hermes -p cdda"
- Profile: ~/.hermes/profiles/cdda/
- Skills: ~/.hermes/skills/（通过 external_dirs 加载）

Supervisor（监督者）：
tmux new-session -d -s supervisor -x 140 -y 50 "hermes -p cdda"
- 同样的 profile，同样的 skills

CDDA 游戏：
cd /Users/yetian/Desktop/new-real-100-commits/tmp/runtime/cdda-terminal && 
HOME=/Users/yetian/Desktop/new-real-100-commits/tmp/runtime/home-hermes ./cataclysm
---

3. 关键文件位置

| 文件 | 位置 |
|------|------|
| CDDA profile | ~/.hermes/profiles/cdda/config.yaml |
| CDDA profile .env | ~/.hermes/profiles/cdda/.env |
| cdda-agent skill | ~/.hermes/skills/gaming/cdda-agent/SKILL.md |
| cdda-clone-launcher skill | ~/.hermes/skills/gaming/cdda-clone-launcher/SKILL.md |
| CDDA 二进制 | /Users/yetian/Desktop/new-real-100-commits/tmp/runtime/cdda-terminal/cataclysm |
| CDDA home 目录 | /Users/yetian/Desktop/new-real-100-commits/tmp/runtime/home-hermes |
| CDDA MCP server | /Users/yetian/Desktop/new-real-100-commits/scripts/cdda_mcp_server.py |
| Clone MCP server | /Users/yetian/Desktop/new-real-100-commits/scripts/clone_hermes_mcp_server.py |
| MCP 8766 (CDDA) | cdda-mcp-proxy tmux session |
| MCP 8767 (clone 控制) | clone-hermes-mcp-proxy tmux session |

---

4. Profile 配置关键项

- agent.max_turns: 300
- HERMES_PLATFORM=cli（在 .env 里）
- skills.external_dirs: [/Users/yetian/.hermes/skills]（读取共享 skills）
- platform_disabled.cli 里 74 个 skill 被禁用（确保只有 cdda 相关 skill 可用）

---

5. 当前问题

- Clone 已跑 3 小时但只用了 10% iteration budget——说明它卡在 sleep 循环里
- 游戏正在无限保存（"Saving game" 一直刷）——可能是游戏卡住了
- Narrator session 已崩溃
