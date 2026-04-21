# Architecture — CDDA signed-message test bench

**Status**: Frozen for Layer 2 handoff  
**Layer**: 2 Architecture — HOW only  
**Input used**: `_mynot/1-intent/PRD.md` only  
**Current story seed**: STORY-000-bootstrap

## 1. System overview

The demo is a local signed-message test bench. It proves that visible CDDA progress, human instructions, save points, and restores can be represented as one-way signed-message flows between real actors.

Layer 1 principles mapped here:

- PRD 3.1 requires every state-affecting message to be signed by the real sender.
- PRD 3.2 requires one-way processing: consume signed messages, emit a new signed message, stop.
- PRD 3.3 requires game-screen interpretation by an agent, not by a shortcut parser or relay.
- PRD 3.4 restricts the browser to display plus human-authored input.
- PRD 3.5 and 3.6 require deterministic signed asset save and restore.
- PRD 3.7 requires CDDA-specific behavior to remain replaceable scenario pressure.

### Context diagram

```text
+------------------+         signed human_input         +-------------------+
| Human in browser | ----------------------------------> | Message log/relay |
| display + input  | <---------------------------------- | append + fan-out  |
+------------------+       subscribed signed messages    +---------+---------+
                                                                  |
                                                                  | signed observations,
                                                                  | decisions, actions,
                                                                  | versions, restores
                                                                  v
+------------------+       signed scene_observation       +-------------------+
| CDDA game screen | <----------------------------------- | Scene-reader agent|
| external scenario|                                     +-------------------+
+--------+---------+                                                |
         ^                                                          | signed action_decision
         | signed action_effect                                     v
+--------+---------+                                      +-------------------+
| Action bridge    | <----------------------------------- | Actor agent       |
| applies actions  |                                      +-------------------+
+------------------+                                                |
                                                                  signed commits/restores
                                                                  v
                                                        +-------------------+
                                                        | Version agent     |
                                                        +-------------------+
```

## 2. Components and responsibilities

| Component | Role | Must do | Must not do | Derived from PRD |
|---|---|---|---|---|
| Browser surface | Display subscribed messages; collect human text input | Render signed messages and emit human-signed instructions | Call privileged `/api/*`, read the game screen directly, synthesize agent/server messages | 3.4, Use case 2 |
| Message log/relay | Append-only transport and fan-out | Store signed envelopes and deliver them to subscribers | Author another actor's message or decide game progress | 3.1, 3.2 |
| Scene-reader agent | Interpret current game-visible screen | Publish signed `scene_observation` messages | Delegate authoritative screen interpretation to a script/parser/relay | 3.3, Use case 1 |
| Actor agent | Decide what to do next | Consume human instructions and scene observations; publish signed `action_decision` | Mutate state without a signed decision | 3.2, Use case 2 |
| Action bridge | Apply a signed action decision to the scenario and report observed effect | Publish signed `action_effect` for what was applied/observed | Invent decisions or become the strategic actor | Use case 1, 3.2 |
| Version agent | Save and restore reusable agent assets | Publish signed `asset_commit` and `asset_restore` messages | Rebuild state from hidden browser/relay state | 3.5, 3.6 |
| Audit view | Verification projection | Show signer, channel, causal links, and forbidden-path status | Treat unsigned or relay-authored records as valid success | Success criteria, NFR Auditability |

## 3. Signed envelope common schema

Every channel payload is wrapped in one signed envelope. The exact cryptographic implementation is downstream, but the semantic fields are fixed here.

```text
SignedEnvelope = {
  id, channel, created_at,
  signer_actor_id, signer_role,
  causation_ids[], correlation_id,
  payload,
  signature
}
```

Rules derived from PRD 3.1 and 3.2:

1. `signer_actor_id` is the actor that made the claim in `payload`.
2. A relay or display component may append/carry an envelope only when the signature verifies for that signer.
3. A subscriber must reject any envelope where the claimed channel author and signer do not match.
4. Each actor consumes prior envelopes and emits only its own next envelope; it does not rewrite prior payloads.

## 4. Channel catalog

| Channel | Payload schema | Unique publisher | Subscribers | Signature/trust rule | PRD derivation |
|---|---|---|---|---|---|
| `human_input` | `{text, target_hint?, visible_context_ref?}` | Browser acting for the human signer | Actor agent, audit view | Human key signs; browser is carrier/input surface only | Use case 2, 3.4 |
| `scene_observation` | `{screen_ref, observation_text, uncertainty?, observed_after?}` | Scene-reader agent | Actor agent, browser, audit view, version agent | Scene-reader agent signs; no relay/server substitute accepted | Use case 1, 3.3 |
| `action_decision` | `{decision_text, intended_action?, reason, references[]}` | Actor agent | Action bridge, browser, audit view, version agent | Actor agent signs; must cite prior observation or human input | Use cases 1-2, 3.2 |
| `action_effect` | `{applied_action, effect_summary, new_screen_ref?}` | Action bridge | Scene-reader agent, browser, audit view, version agent | Action bridge signs only what it applied/observed; not strategy | Use case 1, 3.2 |
| `asset_commit` | `{version_id, assets, recent_flow_boundary, scenario_ref?}` | Version agent or human signer | Version agent, browser, audit view | Real initiator signs; record covers assets and recent flow | Use case 3, 3.5 |
| `asset_restore` | `{version_id, restored_assets, restored_flow_boundary, deterministic_check}` | Version agent | Agents, browser, audit view | Version agent signs restore result; subscribers verify against commit | Use case 4, 3.6 |
| `audit_finding` | `{finding_type, subject_ids[], status, explanation}` | Audit view/checker | Browser, developer/test harness | Audit checker signs findings; cannot make demo success true by itself | Success criteria, anti-shortcut visibility |

## 5. Trust chain

### 5.1 Sender authenticity

- Human-originated text is valid only on `human_input` and only with the human signer.
- Agent-originated claims are valid only when signed by the relevant agent.
- Relay append metadata does not transfer authorship.
- Browser rendering does not transfer authorship.

### 5.2 Subscriber rejection rules

Each subscriber verifies before acting:

| Subscriber | Rejects when |
|---|---|
| Actor agent | `human_input` is not human-signed; `scene_observation` is not scene-reader-signed; causal reference missing for a requested action |
| Action bridge | `action_decision` is not actor-agent-signed or does not reference accepted prior context |
| Scene-reader agent | `action_effect` is not bridge-signed or lacks a screen/effect reference |
| Version agent | commit/restore request lacks real initiator signature or asset coverage |
| Browser/audit view | any displayed system-relevant message is unsigned, relay-authored for another actor, or has invalid channel/signer mapping |

### 5.3 Relay/server position

The relay is append-only transport plus fan-out. It may validate envelope shape and signature before append. It is not a central arbitrator of truth and never authors channel payloads for human, agent, bridge, version, or audit actors.

## 6. Bootstrap path: main menu to playable loop

The first playable loop is a signed causal chain, not a relay-pushed shortcut:

1. Scene-reader agent observes the visible screen and publishes `scene_observation`.
2. Actor agent consumes that observation and publishes an `action_decision` for the next step.
3. Action bridge applies the signed decision and publishes `action_effect`.
4. Scene-reader agent consumes the effect/new screen and publishes the next `scene_observation`.
5. Browser subscribes to these envelopes and renders current state, signer, and causal links.

Invalid bootstrap paths:

- relay/server emits `scene_observation` or `action_decision` on behalf of an agent;
- browser calls `/api/*` to make the scenario progress;
- scripted screen parsing becomes the authoritative scene reader;
- a hidden state mutation is treated as success without signed envelope evidence.

## 7. Browser architecture

The browser has exactly two architectural capabilities:

1. Subscribe/render: display accepted envelopes from the message log/relay, including audit metadata.
2. Human publish: create a human-signed `human_input` envelope from typed text.

The browser does not call `/api/*` for privileged commands, does not read the game screen directly, does not create agent/bridge/version messages, and does not determine whether the game has progressed.

## 8. Commit and restore semantics

### 8.1 Commit as signed message

A save point is an `asset_commit` envelope. It records:

- agent configuration needed to recreate the participating actors;
- skills/capabilities exposed to those actors;
- topology: which actors subscribe/publish to which channels;
- bounded recent signed message flow used as restore context;
- scenario reference as pressure-test context, not product identity.

### 8.2 Restore from commit

A restore is an `asset_restore` envelope causally linked to an `asset_commit` envelope. Restore succeeds only when:

1. the restored asset set matches the commit's machine-readable assets;
2. restored topology matches the commit topology;
3. the recent-flow boundary is reconstructed deterministically;
4. two restores from the same commit produce the same restored asset state;
5. no hidden browser or relay-authored replacement state is required.

## 9. Failure modes required downstream

Layer 3 stories and Layer 5 tests must cover these failure modes:

| Failure mode | Expected result | Derived from PRD |
|---|---|---|
| Browser tries privileged `/api/*` progress | Rejected or absent from success path | 3.4, Out of scope |
| Relay/server authors another actor's message | Rejected by subscribers/audit | 3.1 |
| Scripted screen interpretation substitutes for scene-reader agent | Not accepted as `scene_observation` success | 3.3 |
| Unsigned or wrong-signer envelope | Rejected before subscriber action | 3.1 |
| Action without causal observation/instruction | Rejected as non-auditable | 3.2 |
| Restore depends on hidden browser/relay state | Restore fails deterministic check | 3.6 |
| CDDA-specific detail is treated as product requirement | Flagged as scenario-coupling failure | 3.7 |

## 10. Layer 3 handoff constraints

The first story should implement one causal chain only: bootstrap from initial scene observation through actor decision, action effect, browser rendering, and minimal audit proof. Save/restore can be stubbed only if the story explicitly scopes it as an acceptance criterion; otherwise it remains for a later story.

A valid story must cite the channel names and failure modes above and must not introduce new components outside this architecture.

## 11. Layer 2 freeze checklist evidence

- Channel catalog is complete for MVP channels: §4.
- Trust chain and reject authority are defined: §5.
- Bootstrap path is defined without relay/server-authored progress: §6.
- Browser role is display plus human publish only and no `/api/*`: §7.
- Commit/restore are signed channel messages: §8.
- Every conclusion above is mapped to Layer 1 PRD sections in tables or bullets.
