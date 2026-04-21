# Mock expected result — CDDA signed-message test bench

**Status**: Draft companion artifact for Design freeze  
**Layer**: 1 Intent mock / expected result

This is not an implementation design. It is the user-visible and audit-visible result that downstream layers must preserve.

## Happy-path demonstration

1. A human opens the browser.
2. The browser shows current game-visible state and a narration message.
3. The audit view shows the narration was signed by an agent, not by the browser or server.
4. The human types: "go pick up the weapon".
5. The audit view shows a human-signed instruction message.
6. A later agent-signed message responds to the instruction and either acts or explains why it will not act.
7. The human or an agent creates a save point.
8. The audit view shows a signed version record covering agent configuration, skills, topology, and recent message flow.
9. The system is deliberately disturbed.
10. The human restores the saved version.
11. The restored agent asset state matches the saved version, and repeating restore gives the same result.

## Invalid demonstration examples

The demonstration must be treated as failed if any of these are the success path:

- browser calls `/api/*` to command game progress;
- MCP-style tools expose game observe/act as the authoritative path;
- a server or relay writes another actor’s message;
- a script/parser reads the game screen and authors authoritative state for the agent;
- a fixed UI layout or fixed agent count is required for the product claim;
- save/restore records cannot reconstruct the signed asset state.
