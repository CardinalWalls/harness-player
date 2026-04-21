Use the local streamable HTTP MCP endpoint at `http://127.0.0.1:8766/mcp`.

The server exposes the `cdda` runtime tools:
- `session_status`
- `ensure_game`
- `observe`
- `act`
- `reach_playable`
- `stop_session`

Please attach to the shared session `hermes-cdda`.

Start by calling `reach_playable` with:

```json
{"session_name":"hermes-cdda"}
```

After the game is in a playable state, use `observe` and then `act` for the next safe step.
