///|
pub(all) struct RawTruth {
  truth_id : String
  title : String
  sequence : Int
  body : String
} derive(Debug, Eq)

///|
pub fn raw_truth(
  truth_id : String,
  title : String,
  sequence : Int,
  body : String,
) -> RawTruth {
  { truth_id, title, sequence, body }
}

///|
pub(all) enum ContractError {
  InvalidUpstream(String)
} derive(Debug, Eq)

///|
pub(all) struct SignedEnvelope {
  id : String
  channel : String
  signer_actor_id : String
  signer_role : String
  causation_ids : Array[String]
  correlation_id : String
  payload : String
  signature : String
} derive(Debug, Eq)

///|
pub(all) struct AuditProjection {
  envelope_id : String
  channel : String
  signer_actor_id : String
  causation_ids : Array[String]
  valid : Bool
} derive(Debug, Eq)

///|
pub fn signed_envelope(
  id : String,
  channel : String,
  signer_actor_id : String,
  signer_role : String,
  causation_ids : Array[String],
  correlation_id : String,
  payload : String,
  signature : String,
) -> SignedEnvelope {
  {
    id,
    channel,
    signer_actor_id,
    signer_role,
    causation_ids,
    correlation_id,
    payload,
    signature,
  }
}

///|
fn envelope_signature(
  channel : String,
  signer_actor_id : String,
  id : String,
) -> String {
  "sig:" + signer_actor_id + ":" + channel + ":" + id
}

///|
fn scene_observation_payload(
  raw_screen_ref : String,
  screen_text : String,
) -> String {
  "raw_ref=" + raw_screen_ref + "\nscreen=" + screen_text
}

///|
fn scene_observation_with_causation(
  id : String,
  correlation_id : String,
  raw_screen_ref : String,
  screen_text : String,
  scripted_authority : Bool,
  causation_ids : Array[String],
) -> Result[SignedEnvelope, ContractError] {
  if scripted_authority {
    return Err(
      InvalidUpstream(
        "scene_observation must cite raw screen evidence, not scripted authority",
      ),
    )
  }
  if raw_screen_ref.length() == 0 || causation_ids.length() == 0 {
    return Err(
      InvalidUpstream(
        "scene_observation requires raw screen evidence causation",
      ),
    )
  }
  Ok(
    signed_envelope(
      id,
      "scene_observation",
      "scene-reader",
      "scene-reader",
      causation_ids,
      correlation_id,
      scene_observation_payload(raw_screen_ref, screen_text),
      envelope_signature("scene_observation", "scene-reader", id),
    ),
  )
}

///|
pub fn scene_observation_from_raw(
  id : String,
  correlation_id : String,
  raw_screen_ref : String,
  screen_text : String,
  scripted_authority : Bool,
) -> Result[SignedEnvelope, ContractError] {
  scene_observation_with_causation(
    id,
    correlation_id,
    raw_screen_ref,
    screen_text,
    scripted_authority,
    [raw_screen_ref],
  )
}

///|
fn is_scene_reader_observation(envelope : SignedEnvelope) -> Bool {
  envelope.channel == "scene_observation" &&
  envelope.signer_actor_id == "scene-reader" &&
  envelope.signer_role == "scene-reader" &&
  envelope.causation_ids.length() > 0 &&
  envelope.signature.length() > 0
}

///|
fn is_actor_decision(envelope : SignedEnvelope) -> Bool {
  envelope.channel == "action_decision" &&
  envelope.signer_actor_id == "actor" &&
  envelope.signer_role == "actor" &&
  envelope.causation_ids.length() > 0 &&
  envelope.signature.length() > 0
}

///|
fn is_bridge_effect(envelope : SignedEnvelope) -> Bool {
  envelope.channel == "action_effect" &&
  envelope.signer_actor_id == "action-bridge" &&
  envelope.signer_role == "action-bridge" &&
  envelope.causation_ids.length() > 0 &&
  envelope.signature.length() > 0
}

///|
fn is_valid_story_envelope(envelope : SignedEnvelope) -> Bool {
  match envelope.channel {
    "scene_observation" => is_scene_reader_observation(envelope)
    "action_decision" => is_actor_decision(envelope)
    "action_effect" => is_bridge_effect(envelope)
    _ => false
  }
}

///|
pub fn action_decision_from_scene_as(
  scene_observation : SignedEnvelope,
  id : String,
  decision_payload : String,
  signer_actor_id : String,
  signer_role : String,
) -> Result[SignedEnvelope, ContractError] {
  if signer_actor_id != "actor" || signer_role != "actor" {
    return Err(
      InvalidUpstream(
        "action_decision must be authored by the actor, not a bridge/browser/human",
      ),
    )
  }
  if !is_scene_reader_observation(scene_observation) {
    return Err(
      InvalidUpstream(
        "action_decision must consume a scene-reader signed scene_observation",
      ),
    )
  }
  Ok(
    signed_envelope(
      id,
      "action_decision",
      signer_actor_id,
      signer_role,
      [scene_observation.id],
      scene_observation.correlation_id,
      decision_payload,
      envelope_signature("action_decision", signer_actor_id, id),
    ),
  )
}

///|
pub fn action_decision_from_scene(
  scene_observation : SignedEnvelope,
  id : String,
  decision_payload : String,
) -> Result[SignedEnvelope, ContractError] {
  action_decision_from_scene_as(
    scene_observation, id, decision_payload, "actor", "actor",
  )
}

///|
pub fn action_effect_from_decision(
  action_decision : SignedEnvelope,
  id : String,
  effect_payload : String,
) -> Result[SignedEnvelope, ContractError] {
  if !is_actor_decision(action_decision) {
    return Err(
      InvalidUpstream(
        "action_effect must consume an actor signed action_decision",
      ),
    )
  }
  Ok(
    signed_envelope(
      id,
      "action_effect",
      "action-bridge",
      "action-bridge",
      [action_decision.id],
      action_decision.correlation_id,
      effect_payload,
      envelope_signature("action_effect", "action-bridge", id),
    ),
  )
}

///|
pub fn next_scene_observation_from_effect(
  action_effect : SignedEnvelope,
  id : String,
  correlation_id : String,
  raw_screen_ref : String,
  screen_text : String,
  scripted_authority : Bool,
) -> Result[SignedEnvelope, ContractError] {
  if !is_bridge_effect(action_effect) {
    return Err(
      InvalidUpstream(
        "next scene_observation must consume an action-bridge signed action_effect",
      ),
    )
  }
  scene_observation_with_causation(
    id,
    correlation_id,
    raw_screen_ref,
    screen_text,
    scripted_authority,
    [action_effect.id, raw_screen_ref],
  )
}

///|
fn audit_projection(envelope : SignedEnvelope) -> AuditProjection {
  {
    envelope_id: envelope.id,
    channel: envelope.channel,
    signer_actor_id: envelope.signer_actor_id,
    causation_ids: envelope.causation_ids,
    valid: is_valid_story_envelope(envelope),
  }
}

///|
pub fn audit_chain(
  envelopes : Array[SignedEnvelope],
) -> Result[Array[AuditProjection], ContractError] {
  if envelopes.length() != 4 {
    return Err(
      InvalidUpstream(
        "bootstrap audit chain requires exactly four accepted envelopes",
      ),
    )
  }
  if !is_scene_reader_observation(envelopes[0]) ||
    !is_actor_decision(envelopes[1]) ||
    !is_bridge_effect(envelopes[2]) ||
    !is_scene_reader_observation(envelopes[3]) {
    return Err(
      InvalidUpstream(
        "bootstrap audit chain contains an invalid channel signer mapping",
      ),
    )
  }
  if envelopes[1].causation_ids != [envelopes[0].id] ||
    envelopes[2].causation_ids != [envelopes[1].id] ||
    envelopes[3].causation_ids[0] != envelopes[2].id {
    return Err(
      InvalidUpstream("bootstrap audit chain has broken causal predecessors"),
    )
  }
  let rows : Array[AuditProjection] = []
  for envelope in envelopes {
    rows.push(audit_projection(envelope))
  }
  Ok(rows)
}

///|
pub(all) struct ChannelSnapshot {
  channel_id : String
  title : String
  owner : String
  sequence : Int
  status : String
  body : String
  evidence_note : String
  upstream_channel_ids : Array[String]
  upstream_sequences : Array[Int]
} derive(Debug, Eq)

///|
fn make_channel(
  channel_id : String,
  title : String,
  owner : String,
  sequence : Int,
  status : String,
  body : String,
  evidence_note : String,
  upstream_channel_ids : Array[String],
  upstream_sequences : Array[Int],
) -> ChannelSnapshot {
  {
    channel_id,
    title,
    owner,
    sequence,
    status,
    body,
    evidence_note,
    upstream_channel_ids,
    upstream_sequences,
  }
}

///|
pub fn human_instruction(
  sequence : Int,
  body : String,
  evidence_note : String,
) -> ChannelSnapshot {
  make_channel(
    "human-instruction",
    "Human Instruction",
    "human-operator",
    sequence,
    "live",
    body,
    evidence_note,
    [],
    [],
  )
}

///|
pub fn scene_state_from_raw(
  raw : RawTruth,
  sequence : Int,
  body : String,
  evidence_note : String,
) -> ChannelSnapshot {
  make_channel(
    "scene-state",
    "Scene State",
    "scene-reader",
    sequence,
    "live",
    body,
    evidence_note,
    [raw.truth_id],
    [raw.sequence],
  )
}

///|
pub fn action_intent_from_scene(
  scene_state : ChannelSnapshot,
  sequence : Int,
  body : String,
  evidence_note : String,
) -> Result[ChannelSnapshot, ContractError] {
  if scene_state.channel_id != "scene-state" ||
    scene_state.owner != "scene-reader" {
    return Err(
      InvalidUpstream(
        "action-intent must come from scene-state written by scene-reader",
      ),
    )
  }
  Ok(
    make_channel(
      "action-intent",
      "Action Intent",
      "navigator",
      sequence,
      "live",
      body,
      evidence_note,
      [scene_state.channel_id],
      [scene_state.sequence],
    ),
  )
}

///|
pub fn action_result_from_intent(
  action_intent : ChannelSnapshot,
  sequence : Int,
  body : String,
  evidence_note : String,
) -> Result[ChannelSnapshot, ContractError] {
  if action_intent.channel_id != "action-intent" ||
    action_intent.owner != "navigator" {
    return Err(
      InvalidUpstream(
        "action-result must come from action-intent written by navigator",
      ),
    )
  }
  Ok(
    make_channel(
      "action-result",
      "Action Result",
      "runtime-executor",
      sequence,
      "live",
      body,
      evidence_note,
      [action_intent.channel_id],
      [action_intent.sequence],
    ),
  )
}

///|
pub fn supervisor_reflection_from_intent(
  action_intent : ChannelSnapshot,
  sequence : Int,
  body : String,
  evidence_note : String,
) -> Result[ChannelSnapshot, ContractError] {
  if action_intent.channel_id != "action-intent" ||
    action_intent.owner != "navigator" {
    return Err(
      InvalidUpstream(
        "supervisor-reflection must evaluate navigator-owned action-intent",
      ),
    )
  }
  Ok(
    make_channel(
      "supervisor-reflection",
      "Supervisor Reflection",
      "supervisor",
      sequence,
      "live",
      body,
      evidence_note,
      [action_intent.channel_id],
      [action_intent.sequence],
    ),
  )
}

///|
pub(all) enum ParticipantView {
  Raw(RawTruth)
  Channel(ChannelSnapshot)
} derive(Debug, Eq)

///|
pub fn participant_id_of(view : ParticipantView) -> String {
  match view {
    Raw(raw) => raw.truth_id
    Channel(channel) => channel.channel_id
  }
}

///|
pub fn participant_sequence_of(view : ParticipantView) -> Int {
  match view {
    Raw(raw) => raw.sequence
    Channel(channel) => channel.sequence
  }
}

///|
pub(all) struct RelationContract {
  relation_id : String
  title : String
  kind : String
  source : String
  target : String
  owner : String
  status : String
  explanation : String
} derive(Debug, Eq)

///|
pub fn relation_contract(
  relation_id : String,
  title : String,
  kind : String,
  source : String,
  target : String,
  owner : String,
  status : String,
  explanation : String,
) -> RelationContract {
  { relation_id, title, kind, source, target, owner, status, explanation }
}

///|
pub(all) struct SectionView {
  section_id : String
  title : String
  left : ParticipantView
  relation : RelationContract
  right : ParticipantView
} derive(Debug, Eq)

///|
pub fn section_view(
  section_id : String,
  title : String,
  left : ParticipantView,
  relation : RelationContract,
  right : ParticipantView,
) -> SectionView {
  { section_id, title, left, relation, right }
}

///|
pub fn section_contains_channel(
  section : SectionView,
  channel_id : String,
) -> Bool {
  participant_id_of(section.left) == channel_id ||
  participant_id_of(section.right) == channel_id
}

///|
pub fn section_ids_for_channel(
  sections : Array[SectionView],
  channel_id : String,
) -> Array[String] {
  let ids : Array[String] = []
  for section in sections {
    if section_contains_channel(section, channel_id) {
      ids.push(section.section_id)
    }
  }
  ids
}

///|
pub fn default_sections(
  raw_tui : RawTruth,
  scene_state : ChannelSnapshot,
  action_intent : ChannelSnapshot,
  action_result : ChannelSnapshot,
  supervisor_reflection : ChannelSnapshot,
  human_instruction : ChannelSnapshot?,
) -> Array[SectionView] {
  let sections : Array[SectionView] = []
  sections.push(
    section_view(
      "raw-tui-to-scene-state",
      "Raw TUI is interpreted into Scene State",
      Raw(raw_tui),
      relation_contract(
        "raw-tui-to-scene-state",
        "Raw TUI is interpreted into Scene State",
        "observation-contract",
        raw_tui.truth_id,
        scene_state.channel_id,
        "scene-reader",
        "live",
        "scene-reader 只读取 raw-tui，并把结果写成原生 scene-state。",
      ),
      Channel(scene_state),
    ),
  )
  sections.push(
    section_view(
      "scene-state-to-action-intent",
      "Scene State drives Action Intent",
      Channel(scene_state),
      relation_contract(
        "scene-state-to-action-intent",
        "Scene State drives Action Intent",
        "decision-contract",
        scene_state.channel_id,
        action_intent.channel_id,
        "navigator",
        "live",
        "navigator 只能消费 scene-state，然后写出 action-intent。",
      ),
      Channel(action_intent),
    ),
  )
  sections.push(
    section_view(
      "action-intent-to-action-result",
      "Action Intent is executed into Action Result",
      Channel(action_intent),
      relation_contract(
        "action-intent-to-action-result",
        "Action Intent is executed into Action Result",
        "execution-contract",
        action_intent.channel_id,
        action_result.channel_id,
        "runtime-executor",
        "live",
        "runtime-executor 只执行动作意图，并写出 action-result。",
      ),
      Channel(action_result),
    ),
  )
  sections.push(
    section_view(
      "action-result-to-scene-state",
      "Action Result feeds back into Scene State",
      Channel(action_result),
      relation_contract(
        "action-result-to-scene-state",
        "Action Result feeds back into Scene State",
        "feedback-contract",
        action_result.channel_id,
        scene_state.channel_id,
        "scene-reader",
        "live",
        "动作改变世界之后，scene-reader 必须基于新证据更新 scene-state。",
      ),
      Channel(scene_state),
    ),
  )
  sections.push(
    section_view(
      "supervisor-reflection-to-action-intent",
      "Supervisor reflects on Action Intent",
      Channel(supervisor_reflection),
      relation_contract(
        "supervisor-reflection-to-action-intent",
        "Supervisor reflects on Action Intent",
        "governance-contract",
        supervisor_reflection.channel_id,
        action_intent.channel_id,
        "supervisor",
        "live",
        "supervisor 只做治理与纠偏，不直接冒充 navigator。",
      ),
      Channel(action_intent),
    ),
  )
  match human_instruction {
    Some(human) =>
      sections.push(
        section_view(
          "human-instruction-to-supervisor-reflection",
          "Human Instruction influences Supervisor",
          Channel(human),
          relation_contract(
            "human-instruction-to-supervisor-reflection",
            "Human Instruction influences Supervisor",
            "instruction-contract",
            human.channel_id,
            supervisor_reflection.channel_id,
            "human-operator",
            "live",
            "人类指令进入系统时，应该通过独立 contract 影响监督层。",
          ),
          Channel(supervisor_reflection),
        ),
      )
    None => ()
  }
  sections
}
