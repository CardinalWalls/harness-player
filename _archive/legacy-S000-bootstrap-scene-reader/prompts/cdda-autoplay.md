Run one bounded autonomous CDDA play session in this local harness.

Read these files first:
- AGENTS.md
- tmp/autoplay/current/request.txt

Rules:
1. Use the MCP runtime tools to connect to the tmux-backed CDDA session.
   Omit `session_name`, or use exactly `cdda-smoke`.
2. If the game is not yet playable, prefer a single `reach_playable` call.
3. If an interaction popup or side menu is already open, dismiss it safely before exploring.
4. Stay conservative. Prefer short movement, waiting, and simple in-world exploration over risky actions.
5. Do not attack, steal, craft, drop items, open long inventory workflows, save-and-quit, or confirm irreversible prompts.
6. Before each action, inspect the current screen. After each action, inspect again before deciding the next step.
7. If the screen becomes ambiguous or dangerous, stop early and document why.
8. Only edit files under `tmp/autoplay/current/`.
9. Create `tmp/autoplay/current/agent-note.md`.
10. The first line of that file must be exactly `cdda-autoplay-ok`.
11. The second line must summarize the final visible in-game place and situation in one sentence.
12. The third line must name the last key sequence you used.
13. The fourth line must briefly describe what changed during this autoplay run.
14. Keep the final terminal reply to at most two short sentences.
