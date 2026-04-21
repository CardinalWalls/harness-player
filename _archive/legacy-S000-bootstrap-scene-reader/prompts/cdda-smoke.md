Run one bounded CDDA runtime smoke in this local harness.

Read these files first:
- AGENTS.md
- tmp/smoke/current/request.txt

Rules:
1. Use the MCP runtime tools to launch or reconnect to the tmux-backed CDDA terminal session.
   Prefer a single `reach_playable` call once the session is available.
2. Do not invent a custom tmux session name. Omit `session_name`, or use exactly `cdda-smoke`.
3. Reach an actual in-game screen where the player can move, not just the main menu.
4. Follow the validated shortest path from `tmp/smoke/current/request.txt` exactly unless the current screen proves you are already past that step.
5. Do not browse MOTD, settings, help, world management, or any other side menu.
6. If you end up off-path, return to the main menu and then use the validated shortest path.
7. You may only edit files under `tmp/smoke/current/`.
8. Create `tmp/smoke/current/agent-note.md`.
9. The first line of that file must be exactly `cdda-smoke-ok`.
10. The second line must summarize the visible in-game place in one sentence.
11. The third line must name the last key sequence you used to reach the playable screen.
12. Keep the final terminal reply to at most two short sentences.
