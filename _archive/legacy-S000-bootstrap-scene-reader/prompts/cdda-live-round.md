运行一轮 CDDA 直播回合。

先读这些文件：
- `AGENTS.md`
- `tmp/live/current/request.txt`
- `tmp/live/current/game-state.md`（如果存在）

要求：
1. 使用 MCP runtime tools 连接 tmux-backed CDDA 会话。
   默认省略 `session_name`，或使用 `cdda-smoke`。
2. 把 `tmp/live/current/request.txt` 当作本轮上下文。
   里面会告诉你当前直播风格、上一轮摘要、人类消息和当前状态文档。
3. 根据当前画面自由继续游戏，不预设固定动作数、固定路线或固定策略。
4. 你可以先观察，再自行决定接下来怎么行动；如果当前画面需要先处理弹窗、菜单或阻塞态，也可以直接处理。
5. 在你准备开始本轮行动前，写一条公开直播计划：
   `python3 scripts/live_state.py append --round <ROUND> --channel commentary --text "..."`
6. 在行动过程中或行动前，写一条公开反思/旁白：
   `python3 scripts/live_state.py append --round <ROUND> --channel reflection --text "..."`
   这是给观众看的公开直播文本，按 request 里的风格要求写。
7. 在一个自然停顿点，写一条公开结果：
   `python3 scripts/live_state.py append --round <ROUND> --channel result --text "..."`
8. 在结束本轮前，重写 `tmp/live/current/game-state.md`。
   内容要基于你真实观察到的局面，并至少包含这些段落：
   - `# Game State`
   - `Last Updated`
   - `Current Location`
   - `Visible Situation`
   - `Short-Term Intent`
   - `Wield / Gear Notes`
   - `Open Questions / Risks`
   - `Recent Round Recap`
9. 在结束本轮前，更新 `tmp/live/current/latest.json`：
   `python3 scripts/live_state.py latest --run-id "..." --round <ROUND> --model "..." --keys "..." --plan "..." --reflection "..." --result "..." --mode "..." --location "..." --action-count 0 --round-outcome running --reflection-level "..."`
   控制器会在回合结束后补全动作统计和最终状态。
10. 只修改 `tmp/live/current/` 下的文件。
11. 最后的终端回复保持一句简短中文。
