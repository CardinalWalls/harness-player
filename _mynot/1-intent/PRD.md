# PRD — CDDA demo as a signed-message test bench

**Status**: Draft for Design freeze  
**Layer**: 1 Intent — WHAT & WHY only  
**Current story**: STORY-000-bootstrap

## 1. Summary

### Problem

The current CDDA demo line has drifted from the intended architecture. It contains paths where the system can appear to work even when the core architecture is not being exercised: browser/API shortcuts, server-authored messages, scripted game interpretation, and runtime-control backdoors. That makes the demo unable to prove the real project claim.

### Product intent

The CDDA demo is a **test bench**, not the product. Its job is to put pressure on the project’s real core: preserving, managing, replaying, and verifying agent software assets through signed messages, agent skills, profiles, topology, and recent information flow.

The demo succeeds only when the visible game experience is produced by agents and humans exchanging signed messages in one-way flows. The browser is a display and human input surface; it is not a hidden control plane.

### Success criteria

A reviewer can run the demo and observe all five user outcomes below while confirming that:

- every system-relevant message is signed by the real sender;
- each function is one-way: it consumes prior messages and emits its own next message;
- the game screen is interpreted by an agent, not by a scripted parser or server shortcut;
- the browser does not call `/api/*`, does not read the game screen directly, and does not act as a privileged controller;
- a saved version records enough signed, machine-readable state to restore the agent configuration, skills, topology, and recent message flow.

## 2. Users and use cases

### Use case 1 — Watch agents play CDDA

**User**: human observer  
**Goal**: open the browser and watch the game state plus agent narration update over time.

**Machine-checkable acceptance**:

- the browser shows changing game-visible state and narration;
- the narration is attributable to an agent-signed message;
- there is evidence that the narration came after an agent observed the current game screen;
- no server-authored substitute narration is accepted as success.

### Use case 2 — Speak into the system

**User**: human observer/operator  
**Goal**: type an instruction in the browser and see the system route it to the appropriate agent path.

**Machine-checkable acceptance**:

- the human instruction becomes a human-signed message;
- a later agent-signed response or action decision references that instruction;
- the browser does not send the instruction through a privileged `/api/*` command path;
- the system can reject or explain an instruction without faking game progress.

### Use case 3 — Save the current software asset state

**User**: human observer/operator or an agent  
**Goal**: create a versioned save point of the current agent system.

**Machine-checkable acceptance**:

- a new signed version record appears;
- the record identifies the signer as the real initiator;
- the record covers agent configuration, skills, topology, and a bounded recent message flow;
- the saved state is machine-readable enough to be validated and restored later.

### Use case 4 — Restore a previous version

**User**: human observer/operator  
**Goal**: choose a saved version and restore the agent system to that version’s state.

**Machine-checkable acceptance**:

- after deliberate drift, restore returns the agent configuration, skills, topology, and message-flow boundary to the saved version;
- two restores from the same saved version produce the same restored state;
- restore does not depend on hidden browser state or server-authored replacement messages.

### Use case 5 — Prove the demo is replaceable

**User**: evaluator  
**Goal**: see that CDDA is only a pressure test for the architecture, not a hard-coded product identity.

**Machine-checkable acceptance**:

- the core proof is phrased in terms of agents, humans, signed messages, topology, skills, profiles, and saved versions;
- CDDA-specific knowledge is isolated as replaceable scenario knowledge;
- the demo’s success does not require a fixed number of agents or a fixed UI layout;
- a different text-heavy scenario could reuse the same product requirements without changing the core claim.

## 3. Functional requirements

### 3.1 Signed-message communication

All communication that affects system state must be represented as a signed message from the real sender. A relay, display server, or browser may carry or show a message, but must not become the author of another actor’s message.

### 3.2 One-way agent processing

Each functional step is one-way: consume prior signed messages, produce a new signed message, and stop there. The requirement is about causal flow, not about a fixed agent count or fixed role names.

### 3.3 Agent-read game screen

The game screen must be interpreted by an agent. The demo must not pass because a script, parser, server shortcut, or MCP-style tool read the screen and converted it into authoritative game state on the agent’s behalf.

### 3.4 Browser as display and human input surface

The browser shows subscribed messages and lets the human emit human-authored messages. It does not call privileged command APIs, read the game screen directly, synthesize system messages, or become the central controller.

### 3.5 Versioned asset save

A save operation creates a signed, machine-readable version record covering the agent system’s reusable assets: configuration, skills, topology, and bounded recent information flow.

### 3.6 Versioned asset restore

A restore operation uses a saved version record to recreate the agent system state represented by that version. Restore must be deterministic for the same version record.

### 3.7 Scenario replaceability

CDDA-specific content may exist only as scenario pressure. The product claim must remain about reusable agent software assets and signed-message coordination.

## 4. Non-functional requirements specific to this test bench

- **Auditability**: success evidence must expose who signed each meaningful message.
- **Anti-shortcut visibility**: known invalid paths such as `/api/*`, MCP-style game tools, server-authored messages, and scripted screen interpretation must be detectable as failures.
- **Local-demo orientation**: the first proof runs locally; cloud deployment and hosted multi-user operation are not part of this PRD.
- **Deterministic restore check**: repeated restore from the same saved version must produce the same restored asset state.

## 5. Out of scope

- Building a general game-playing product.
- Optimizing CDDA play quality or survival strategy.
- Requiring a fixed number of agents or fixed visual layout.
- Defining channel schema, component boundaries, file paths, launch commands, profiles, or implementation modules.
- Using browser `/api/*`, MCP, server-authored messages, scripted screen parsing, or server-side game progression as valid success paths.
- Treating any one implementation runtime, orchestration tool, terminal/session mechanism, or environment detail as the product identity.

## 6. Testing strategy at PRD level

The downstream architecture and story phases must produce tests or checks for:

1. each use case’s observable success path;
2. each anti-shortcut failure path;
3. sender authenticity for meaningful messages;
4. browser non-privilege;
5. agent-only interpretation of the game screen;
6. save and restore determinism;
7. scenario replaceability of the core claim.

This PRD intentionally does not define the technical mechanisms for those checks; Layer 2 and Layer 3 must do that without weakening the requirements above.

## 7. MVP Phase 1 acceptance criteria

- [ ] A browser can show game-visible progress and narration produced through signed messages.
- [ ] A human browser instruction becomes a human-signed message and receives a later agent-signed response or action effect.
- [ ] A save point records reusable agent assets and recent signed message flow.
- [ ] A restore from that save point recreates the saved agent asset state deterministically.
- [ ] The demo can be audited to show no `/api/*`, MCP-style game tool, server-authored message, or scripted screen interpreter was used as the success path.

## 8. Phase 2 acceptance criteria

- [ ] The same product requirements can be applied to a non-CDDA text-heavy scenario without changing the core proof.
- [ ] Multiple agent decompositions can satisfy the requirements without rewriting Layer 1.
- [ ] Saved-version records can be compared across runs to identify asset-level differences.

## 9. Risks and mitigation requirements

| Risk | Required mitigation in downstream layers |
|---|---|
| The demo appears to work through hidden control shortcuts | Add explicit negative checks for forbidden paths. |
| The browser becomes a privileged frontend | Define browser success only as display plus human-authored messages. |
| The server or relay silently authors messages | Require real-sender signatures for all meaningful state changes. |
| CDDA-specific code becomes the product | Keep success criteria scenario-replaceable. |
| Save/restore records are not reconstructable | Require machine-readable asset coverage and deterministic restore checks. |
