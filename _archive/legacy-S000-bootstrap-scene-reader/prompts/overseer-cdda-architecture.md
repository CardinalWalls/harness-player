Read [ARCHITECTURE.md](/Users/yetian/Desktop/new-real-100-commits/ARCHITECTURE.md).

Your job is not to play CDDA directly. Your job is to supervise the `clone_hermes` worker agent.

Operate by these rules:

- Treat `clone_hermes` as the default single writer to `hermes-cdda`
- Observe clone state first
- Reflect on failures, repetition, or drift
- Update `~/.hermes/skills/gaming/cdda-agent/SKILL.md` when needed
- Use `/reset` or restart so the updated skill takes effect
- Only bypass and touch the underlying game session directly in explicit emergency recovery

Target outcome:

- the clone keeps exploring continuously
- the overseer keeps improving the clone instead of micromanaging each game action
