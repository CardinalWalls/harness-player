# CDDA Demo Runbook

这份文档是 `cdda-demo/` 的调用手册, 目标是把当前测试环境变成“可重复启动、可网页查看、可被 Codex 调用”的稳定入口.

## 确定

- 当前环境可以在本机后台持续运行 CDDA terminal-only build.
- 当前环境可以通过本地网页看到 tmux 中的 curses 画面.
- 当前环境可以通过本地 MCP server 被 `codex` / `codex exec` 调用.
- 当前环境已经验证过 smoke 路径能进入实际可游玩的 in-game 画面.
- 下一步的多 agent 分层设计见 [ARCHITECTURE.md](/Users/yetian/Desktop/new-real-100-commits/ARCHITECTURE.md).
- 当前环境也支持把 `clone_hermes` 这条 agent tmux 会话包装成第二层 supervisory MCP.

## 目录与入口

- 主目录: `/Users/yetian/Desktop/new-real-100-commits`
- 运行时安装目录: `tmp/runtime/cdda-terminal/`
- 本地网页入口脚本: [scripts/open-dashboard.sh](/Users/yetian/Desktop/new-real-100-commits/scripts/open-dashboard.sh)
- Codex 交互入口脚本: [scripts/open-codex.sh](/Users/yetian/Desktop/new-real-100-commits/scripts/open-codex.sh)
- Codex 自动游玩入口脚本: [scripts/open-autoplay.sh](/Users/yetian/Desktop/new-real-100-commits/scripts/open-autoplay.sh)
- 停止自动游玩脚本: [scripts/stop-autoplay.sh](/Users/yetian/Desktop/new-real-100-commits/scripts/stop-autoplay.sh)
- Codex 直播 loop 入口脚本: [scripts/open-live-loop.sh](/Users/yetian/Desktop/new-real-100-commits/scripts/open-live-loop.sh)
- 停止直播 loop 脚本: [scripts/stop-live-loop.sh](/Users/yetian/Desktop/new-real-100-commits/scripts/stop-live-loop.sh)
- Smoke 入口脚本: [scripts/smoke.sh](/Users/yetian/Desktop/new-real-100-commits/scripts/smoke.sh)
- MCP server 启动脚本: [scripts/start-cdda-mcp.sh](/Users/yetian/Desktop/new-real-100-commits/scripts/start-cdda-mcp.sh)
- 网页服务实现: [scripts/cdda_web_server.py](/Users/yetian/Desktop/new-real-100-commits/scripts/cdda_web_server.py)
- MCP runtime 实现: [scripts/cdda_mcp_server.py](/Users/yetian/Desktop/new-real-100-commits/scripts/cdda_mcp_server.py)

## 最短使用路径

### 1. 一键启动后台网页

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/open-dashboard.sh
```

默认会做这些事:

- 跑 `preflight`
- 如有需要安装 terminal-only CDDA build
- 在后台启动网页服务
- 固定绑定 `cdda-smoke` 这条 tmux/CDDA 会话
- 自动调用 `reach_playable`, 尝试把游戏推进到可游玩状态

默认网页地址:

- [http://127.0.0.1:8875](http://127.0.0.1:8875)

### 2. 打开 Codex 手动接管

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/open-codex.sh
```

它会把本地 `cdda` MCP server 配到当前 `codex` 会话里, 方便直接让 Codex 驱动运行时.

### 2.5 给别的本地 agent 一个常驻 MCP

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/open-persistent-mcp.sh
./scripts/mcp-status.sh
```

这样会在本地拉起一个常驻的 streamable HTTP MCP:

- endpoint: `http://127.0.0.1:8766/mcp`
- proxy tmux session: `cdda-mcp-proxy`
- shared game session: `hermes-cdda`

如果要停掉:

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/stop-persistent-mcp.sh
```

### 2.6 给 overseer 一个 clone supervisory MCP

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/open-clone-hermes-mcp.sh
./scripts/clone-hermes-mcp-status.sh
```

这样会在本地拉起一个第二层 streamable HTTP MCP:

- endpoint: `http://127.0.0.1:8767/mcp`
- proxy tmux session: `clone-hermes-mcp-proxy`
- supervised clone session: `clone_hermes`

默认行为是接管现有 `clone_hermes` session, 不会主动重启它.

如果只想停掉 wrapper:

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/stop-clone-hermes-mcp.sh
```

### 3. 跑一次可回归的 smoke

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/smoke.sh
```

成功时会产出:

- `tmp/smoke/current/agent-note.md`
- `artifacts/smoke/<run-id>/codex-error.txt`
- `artifacts/smoke/<run-id>/events.jsonl`
- `artifacts/smoke/<run-id>/final-screen.txt`

### 4. 启动一轮后台自动游玩

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/open-autoplay.sh
```

默认会做这些事:

- 确认 `preflight`
- 复用网页和 `cdda-smoke` 这条游戏会话
- 在新的 tmux session 里跑一轮后台 `codex exec`
- 让 Codex 通过 MCP 工具做一批保守的游戏内动作
- 把本轮日志和 note 落到 `tmp/autoplay/current/` 与 `artifacts/autoplay/<run-id>/`

要停掉最近一次 autoplay:

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/stop-autoplay.sh
```

### 5. 启动持续直播 loop

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/open-live-loop.sh
```

默认会做这些事:

- 确认 `preflight`
- 复用网页和 `cdda-smoke` 这条游戏会话
- 在固定 tmux session `cdda-live-loop` 里持续启动一轮接一轮的 `codex exec`
- 每一轮只做一次安全游戏动作, 同时写一段公开直播解说到网页
- 把轮次日志落到 `artifacts/live-loop/<run-id>/round-*/`

要停掉持续直播 loop:

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/stop-live-loop.sh
```

## 网页模式说明

网页服务默认监听:

- `127.0.0.1:8875`

页面提供:

- 持续刷新当前 curses 屏幕
- 当前 `mode`
- 是否已到 `in_game`
- 当前 `Place`
- 当前 `Wield`
- 当前直播 loop 状态、轮次、模型、上次按键
- 直播 commentary 面板, 展示公开的行动解说
- 常用按钮: `Start Session`, `Reach Playable`, `Stop`, 方向键, `Enter`, `Esc`, `Tab`, `Y`, `N`

后台常驻方式:

- 脚本会新建 tmux session: `cdda-dashboard-web-clean`
- 网页服务内部固定操作 CDDA tmux session: `cdda-smoke`

相关状态文件:

- 当前 URL: [tmp/web/dashboard-url.txt](/Users/yetian/Desktop/new-real-100-commits/tmp/web/dashboard-url.txt)
- 当前 pid: [tmp/web/dashboard.pid](/Users/yetian/Desktop/new-real-100-commits/tmp/web/dashboard.pid)
- 当前日志: [tmp/web/dashboard.log](/Users/yetian/Desktop/new-real-100-commits/tmp/web/dashboard.log)
- 当前 autoplay note: [tmp/autoplay/current/agent-note.md](/Users/yetian/Desktop/new-real-100-commits/tmp/autoplay/current/agent-note.md)
- 当前 autoplay 状态: [tmp/autoplay/current/status.txt](/Users/yetian/Desktop/new-real-100-commits/tmp/autoplay/current/status.txt)
- 当前 autoplay tmux session 名: [tmp/autoplay/current/tmux-session.txt](/Users/yetian/Desktop/new-real-100-commits/tmp/autoplay/current/tmux-session.txt)
- 当前 live loop 状态: [tmp/live/current/loop-status.json](/Users/yetian/Desktop/new-real-100-commits/tmp/live/current/loop-status.json)
- 当前 live commentary: [tmp/live/current/commentary.log](/Users/yetian/Desktop/new-real-100-commits/tmp/live/current/commentary.log)
- 当前 live latest: [tmp/live/current/latest.json](/Users/yetian/Desktop/new-real-100-commits/tmp/live/current/latest.json)
- 当前 live loop 日志: [tmp/live/current/loop.log](/Users/yetian/Desktop/new-real-100-commits/tmp/live/current/loop.log)

## 可编程调用面

网页服务还暴露了本地 HTTP API, 方便外部脚本或其它代理调用.

### 健康检查

```bash
curl -fsS http://127.0.0.1:8875/api/health
```

### 读取当前状态

```bash
curl -fsS http://127.0.0.1:8875/api/state
```

### 启动/重连游戏

```bash
curl -fsS -X POST http://127.0.0.1:8875/api/ensure-game \
  -H 'Content-Type: application/json' \
  --data '{"restart": false, "wait_ms": 2500}'
```

### 自动推进到可游玩状态

```bash
curl -fsS -X POST http://127.0.0.1:8875/api/reach-playable \
  -H 'Content-Type: application/json' \
  --data '{"restart": true, "startup_wait_ms": 3500, "wait_ms": 1200, "max_steps": 12}'
```

### 发送按键

```bash
curl -fsS -X POST http://127.0.0.1:8875/api/act \
  -H 'Content-Type: application/json' \
  --data '{"keys":["Tab"],"wait_ms":800}'
```

### 停止游戏会话

```bash
curl -fsS -X POST http://127.0.0.1:8875/api/stop-session \
  -H 'Content-Type: application/json' \
  --data '{}'
```

## MCP 工具面

当前 `cdda` MCP server 暴露这些 runtime tools:

- `session_status`
- `ensure_game`
- `observe`
- `act`
- `reach_playable`
- `stop_session`

其中 `reach_playable` 是当前最适合外部代理调用的高层入口, 因为它会按已验证路径尝试把会话带到 `in_game`.

常驻 HTTP MCP 暴露的是同一组工具, 只是把本地 stdio server 代理到了固定 URL `http://127.0.0.1:8766/mcp`.

## Clone Supervisory MCP

`clone-hermes` wrapper 当前暴露这些 supervisory tools:

- `clone_status`
- `clone_capture`
- `clone_send`
- `clone_reset`
- `clone_restart`
- `clone_write_skill`
- `clone_reflect`
- `clone_apply_skill_and_reset`

它们的对象不是游戏本身, 而是 `clone_hermes` 这条 Hermes worker session.

## 当前默认路径

当前已验证的最短推进路径来自:

- [fixtures/smoke-cdda/request.txt](/Users/yetian/Desktop/new-real-100-commits/fixtures/smoke-cdda/request.txt)

核心序列是:

1. 如需要, `Enter`
2. 在 New Game 菜单, `Down`, `Down`, `Enter`
3. 在 Create World, `f`, `Y`
4. 在角色创建, 连续 `Tab` 到 finish, 然后 `Tab`, `Y`

说明:

- 现在 runtime helper 会根据屏幕内容自动判断是否处在 `main_menu`、`world_selection`、`character_creation_tabs`、`character_creation_finish`、`confirmation`、`in_game` 等状态.
- 因此外部通常不需要手动硬编码整条路径, 除非要做更细粒度测试.

## 常见工作流

### 只想看它在跑

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/open-dashboard.sh
open http://127.0.0.1:8875
```

### 想让 Codex 接管

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/open-dashboard.sh
./scripts/open-codex.sh
```

然后直接让 Codex 用 `cdda` MCP 工具操作同一套环境.

### 想直接看 Codex 自己玩

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/open-dashboard.sh
./scripts/open-autoplay.sh
```

然后打开网页看 `cdda-smoke` 的画面持续变化.

### 想看它一边玩一边直播解说

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/open-dashboard.sh
./scripts/open-live-loop.sh
```

默认模型可用环境变量切换:

```bash
CDDA_LIVE_MODEL=spark ./scripts/open-live-loop.sh
CDDA_LIVE_MODEL=mini ./scripts/open-live-loop.sh
```

### 想要回归验证

```bash
cd /Users/yetian/Desktop/new-real-100-commits
./scripts/smoke.sh
```

## 故障排查

### 网页打不开

先看:

- [tmp/web/dashboard.log](/Users/yetian/Desktop/new-real-100-commits/tmp/web/dashboard.log)

再查监听:

```bash
lsof -nP -iTCP:8765 -sTCP:LISTEN
```

### 游戏没进到 in-game

先看:

- `http://127.0.0.1:8875/api/state`
- tmux 当前屏幕

```bash
tmux capture-pane -p -t cdda-smoke -S -120 | tail -n 80
```

必要时直接重新推进:

```bash
curl -fsS -X POST http://127.0.0.1:8875/api/reach-playable \
  -H 'Content-Type: application/json' \
  --data '{"restart": true, "startup_wait_ms": 3500, "wait_ms": 1200, "max_steps": 12}'
```

### autoplay 没有继续动作

先看:

- [tmp/autoplay/current/status.txt](/Users/yetian/Desktop/new-real-100-commits/tmp/autoplay/current/status.txt)
- 最近一次 `artifacts/autoplay/<run-id>/codex-output.txt`
- 最近一次 `artifacts/autoplay/<run-id>/codex-error.txt`

也可以直接看 tmux:

```bash
tmux capture-pane -p -t "$(cat tmp/autoplay/current/tmux-session.txt)" -S -160 | tail -n 120
```

### live loop 没有继续解说或动作

先看:

- [tmp/live/current/loop-status.json](/Users/yetian/Desktop/new-real-100-commits/tmp/live/current/loop-status.json)
- [tmp/live/current/commentary.log](/Users/yetian/Desktop/new-real-100-commits/tmp/live/current/commentary.log)
- [tmp/live/current/loop.log](/Users/yetian/Desktop/new-real-100-commits/tmp/live/current/loop.log)

再看最近一轮 artifact:

```bash
ls -1dt artifacts/live-loop/*/round-* | head -n 3
```

### smoke 失败

先看:

- 最近一次 `artifacts/smoke/<run-id>/codex-error.txt`
- 最近一次 `artifacts/smoke/<run-id>/events.jsonl`

## 还不稳定的部分

### 有依据的推测

- 角色创建阶段是当前最容易漂移的 UI 段, 因为不同角色页签会改变 helper 需要按多少次 `Tab`.
- 现有 helper 已经能覆盖当前机器上的已验证路径, 但如果上游 build 改 UI, 这里仍可能需要微调分类规则.

### 模糊

- 不同 CDDA 版本如果改变 world generation / character creation 文案, 是否还会完全复用当前分类规则, 目前没有额外版本矩阵验证.
