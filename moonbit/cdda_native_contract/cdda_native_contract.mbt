///|
pub(all) enum ContractError {
  InvalidUpstream(String)
} derive(Debug, Eq)

///|
pub(all) struct SignedEnvelope {
  id : String
  channel : String
  created_at : String
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
  signer_role : String
  causation_ids : Array[String]
  valid : Bool
} derive(Debug, Eq)

///|
pub fn signed_envelope(
  id : String,
  channel : String,
  created_at : String,
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
    created_at,
    signer_actor_id,
    signer_role,
    causation_ids,
    correlation_id,
    payload,
    signature,
  }
}

///|
fn invalid(message : String) -> Result[SignedEnvelope, ContractError] {
  Err(InvalidUpstream(message))
}

///|
fn invalid_audit(
  message : String,
) -> Result[Array[AuditProjection], ContractError] {
  Err(InvalidUpstream(message))
}

///|
fn signature_for(
  channel : String,
  signer_actor_id : String,
  id : String,
) -> String {
  "sig:" + signer_actor_id + ":" + channel + ":" + id
}

///|
fn common_fields_present(envelope : SignedEnvelope) -> Bool {
  envelope.id.length() > 0 &&
  envelope.channel.length() > 0 &&
  envelope.created_at.length() > 0 &&
  envelope.signer_actor_id.length() > 0 &&
  envelope.signer_role.length() > 0 &&
  envelope.correlation_id.length() > 0 &&
  envelope.payload.length() > 0 &&
  envelope.signature.length() > 0
}

///|
fn scene_payload(raw_screen_ref : String, screen_text : String) -> String {
  "raw_screen_ref=" + raw_screen_ref + "\nscreen_text=" + screen_text
}

///|
fn human_payload(text : String, visible_context_ref : String) -> String {
  "text=" + text + "\nvisible_context_ref=" + visible_context_ref
}

///|
fn decision_payload(
  decision_text : String,
  intended_action : String,
  reason : String,
) -> String {
  "decision_text=" +
  decision_text +
  "\nintended_action=" +
  intended_action +
  "\nreason=" +
  reason
}

///|
fn effect_payload(
  applied_action : String,
  effect_summary : String,
  new_screen_ref : String,
) -> String {
  "applied_action=" +
  applied_action +
  "\neffect_summary=" +
  effect_summary +
  "\nnew_screen_ref=" +
  new_screen_ref
}

///|
fn scene_payload_cites_raw(envelope : SignedEnvelope) -> Bool {
  envelope.payload.contains("raw_screen_ref=") &&
  envelope.payload.contains("\nscreen_text=") &&
  !envelope.payload.contains("scripted_authority=true") &&
  !envelope.payload.contains("parser_authoritative=true")
}

///|
fn is_scene_reader_observation(envelope : SignedEnvelope) -> Bool {
  common_fields_present(envelope) &&
  envelope.channel == "scene_observation" &&
  envelope.signer_actor_id == "scene-reader" &&
  envelope.signer_role == "scene-reader" &&
  envelope.causation_ids.length() > 0 &&
  scene_payload_cites_raw(envelope)
}

///|
fn human_payload_is_safe(envelope : SignedEnvelope) -> Bool {
  envelope.payload.contains("text=") &&
  envelope.payload.contains("\nvisible_context_ref=") &&
  !envelope.payload.contains("/api/")
}

///|
fn is_human_input(envelope : SignedEnvelope) -> Bool {
  common_fields_present(envelope) &&
  envelope.channel == "human_input" &&
  envelope.signer_actor_id == "human" &&
  envelope.signer_role == "human" &&
  envelope.causation_ids.length() > 0 &&
  human_payload_is_safe(envelope)
}

///|
fn is_actor_decision(envelope : SignedEnvelope) -> Bool {
  common_fields_present(envelope) &&
  envelope.channel == "action_decision" &&
  envelope.signer_actor_id == "actor" &&
  envelope.signer_role == "actor" &&
  envelope.causation_ids.length() > 0
}

///|
fn is_bridge_effect(envelope : SignedEnvelope) -> Bool {
  common_fields_present(envelope) &&
  envelope.channel == "action_effect" &&
  envelope.signer_actor_id == "action-bridge" &&
  envelope.signer_role == "action-bridge" &&
  envelope.causation_ids.length() > 0
}

///|
fn is_story_envelope(envelope : SignedEnvelope) -> Bool {
  match envelope.channel {
    "human_input" => is_human_input(envelope)
    "scene_observation" => is_scene_reader_observation(envelope)
    "action_decision" => is_actor_decision(envelope)
    "action_effect" => is_bridge_effect(envelope)
    _ => false
  }
}

///|
pub fn human_input_from_text(
  id : String,
  created_at : String,
  correlation_id : String,
  text : String,
  visible_context_ref : String,
) -> Result[SignedEnvelope, ContractError] {
  if id.length() == 0 ||
    created_at.length() == 0 ||
    correlation_id.length() == 0 {
    return invalid("human_input requires id, created_at, and correlation_id")
  }
  if text.length() == 0 {
    return invalid("human_input requires non-empty human text")
  }
  if text.contains("/api/") || visible_context_ref.contains("/api/") {
    return invalid("human_input cannot be a privileged browser API command")
  }
  if visible_context_ref.length() == 0 {
    return invalid("human_input requires a visible context reference")
  }
  Ok(
    signed_envelope(
      id,
      "human_input",
      created_at,
      "human",
      "human",
      [visible_context_ref],
      correlation_id,
      human_payload(text, visible_context_ref),
      signature_for("human_input", "human", id),
    ),
  )
}

///|
pub fn scene_observation_from_raw(
  id : String,
  created_at : String,
  correlation_id : String,
  raw_screen_ref : String,
  screen_text : String,
  scripted_authority : Bool,
  observed_after : Array[String],
) -> Result[SignedEnvelope, ContractError] {
  if id.length() == 0 ||
    created_at.length() == 0 ||
    correlation_id.length() == 0 {
    return invalid(
      "scene_observation requires id, created_at, and correlation_id",
    )
  }
  if raw_screen_ref.length() == 0 {
    return invalid("scene_observation requires a raw screen reference")
  }
  if screen_text.length() == 0 {
    return invalid("scene_observation requires screen text from the raw screen")
  }
  if scripted_authority {
    return invalid("scene_observation cannot rely on scripted/parser authority")
  }
  if observed_after.length() == 0 {
    return invalid(
      "scene_observation requires first-observation evidence causation",
    )
  }
  Ok(
    signed_envelope(
      id,
      "scene_observation",
      created_at,
      "scene-reader",
      "scene-reader",
      observed_after,
      correlation_id,
      scene_payload(raw_screen_ref, screen_text),
      signature_for("scene_observation", "scene-reader", id),
    ),
  )
}

///|
pub fn action_decision_from_scene(
  id : String,
  created_at : String,
  correlation_id : String,
  scene : SignedEnvelope,
  decision_text : String,
  intended_action : String,
  reason : String,
) -> Result[SignedEnvelope, ContractError] {
  if id.length() == 0 ||
    created_at.length() == 0 ||
    correlation_id.length() == 0 {
    return invalid(
      "action_decision requires id, created_at, and correlation_id",
    )
  }
  if correlation_id != scene.correlation_id {
    return invalid(
      "action_decision correlation_id must match the scene observation",
    )
  }
  if !is_scene_reader_observation(scene) {
    return invalid(
      "action_decision must consume a scene-reader signed scene_observation",
    )
  }
  if decision_text.length() == 0 ||
    intended_action.length() == 0 ||
    reason.length() == 0 {
    return invalid(
      "action_decision requires decision text, intended action, and reason",
    )
  }
  Ok(
    signed_envelope(
      id,
      "action_decision",
      created_at,
      "actor",
      "actor",
      [scene.id],
      correlation_id,
      decision_payload(decision_text, intended_action, reason),
      signature_for("action_decision", "actor", id),
    ),
  )
}

///|
pub fn action_decision_from_human_input(
  id : String,
  created_at : String,
  correlation_id : String,
  human_input : SignedEnvelope,
  decision_text : String,
  intended_action : String,
  reason : String,
) -> Result[SignedEnvelope, ContractError] {
  if id.length() == 0 ||
    created_at.length() == 0 ||
    correlation_id.length() == 0 {
    return invalid(
      "action_decision requires id, created_at, and correlation_id",
    )
  }
  if correlation_id != human_input.correlation_id {
    return invalid("action_decision correlation_id must match human_input")
  }
  if !is_human_input(human_input) {
    return invalid("action_decision must consume human-signed human_input")
  }
  if decision_text.length() == 0 ||
    intended_action.length() == 0 ||
    reason.length() == 0 {
    return invalid(
      "action_decision requires decision text, intended action, and reason",
    )
  }
  Ok(
    signed_envelope(
      id,
      "action_decision",
      created_at,
      "actor",
      "actor",
      [human_input.id],
      correlation_id,
      decision_payload(decision_text, intended_action, reason),
      signature_for("action_decision", "actor", id),
    ),
  )
}

///|
pub fn action_effect_from_decision(
  id : String,
  created_at : String,
  correlation_id : String,
  decision : SignedEnvelope,
  applied_action : String,
  effect_summary : String,
  new_screen_ref : String,
) -> Result[SignedEnvelope, ContractError] {
  if id.length() == 0 ||
    created_at.length() == 0 ||
    correlation_id.length() == 0 {
    return invalid("action_effect requires id, created_at, and correlation_id")
  }
  if correlation_id != decision.correlation_id {
    return invalid(
      "action_effect correlation_id must match the action decision",
    )
  }
  if !is_actor_decision(decision) {
    return invalid("action_effect must consume an actor signed action_decision")
  }
  if applied_action.length() == 0 ||
    effect_summary.length() == 0 ||
    new_screen_ref.length() == 0 {
    return invalid(
      "action_effect requires applied action, effect summary, and new screen ref",
    )
  }
  Ok(
    signed_envelope(
      id,
      "action_effect",
      created_at,
      "action-bridge",
      "action-bridge",
      [decision.id],
      correlation_id,
      effect_payload(applied_action, effect_summary, new_screen_ref),
      signature_for("action_effect", "action-bridge", id),
    ),
  )
}

///|
pub fn next_scene_observation_from_effect(
  id : String,
  created_at : String,
  correlation_id : String,
  effect : SignedEnvelope,
  raw_screen_ref : String,
  screen_text : String,
  scripted_authority : Bool,
) -> Result[SignedEnvelope, ContractError] {
  if correlation_id != effect.correlation_id {
    return invalid(
      "next scene_observation correlation_id must match the action effect",
    )
  }
  if !is_bridge_effect(effect) {
    return invalid(
      "next scene_observation must consume an action-bridge signed action_effect",
    )
  }
  scene_observation_from_raw(
    id,
    created_at,
    correlation_id,
    raw_screen_ref,
    screen_text,
    scripted_authority,
    [effect.id, raw_screen_ref],
  )
}

///|
fn audit_projection(envelope : SignedEnvelope) -> AuditProjection {
  {
    envelope_id: envelope.id,
    channel: envelope.channel,
    signer_actor_id: envelope.signer_actor_id,
    signer_role: envelope.signer_role,
    causation_ids: envelope.causation_ids,
    valid: is_story_envelope(envelope),
  }
}

///|
pub fn audit_human_input(
  human_input : SignedEnvelope,
  decision : SignedEnvelope,
) -> Result[Array[AuditProjection], ContractError] {
  if !is_human_input(human_input) {
    return invalid_audit("audit_human_input requires valid human_input")
  }
  if !is_actor_decision(decision) {
    return invalid_audit("audit_human_input decision must be actor signed")
  }
  if human_input.correlation_id != decision.correlation_id {
    return invalid_audit("audit_human_input correlation ids must match")
  }
  if decision.causation_ids != [human_input.id] {
    return invalid_audit("actor decision must causally link to human_input")
  }
  Ok([audit_projection(human_input), audit_projection(decision)])
}

///|
pub fn audit_chain(
  envelopes : Array[SignedEnvelope],
) -> Result[Array[AuditProjection], ContractError] {
  if envelopes.length() != 4 {
    return invalid_audit(
      "bootstrap audit chain requires exactly four envelopes",
    )
  }
  let observation = envelopes[0]
  let decision = envelopes[1]
  let effect = envelopes[2]
  let next = envelopes[3]
  if !is_scene_reader_observation(observation) {
    return invalid_audit(
      "audit chain must start with a scene-reader scene_observation",
    )
  }
  if !is_actor_decision(decision) {
    return invalid_audit("audit chain decision must be actor signed")
  }
  if !is_bridge_effect(effect) {
    return invalid_audit("audit chain effect must be action-bridge signed")
  }
  if !is_scene_reader_observation(next) {
    return invalid_audit(
      "audit chain must end with a scene-reader scene_observation",
    )
  }
  if observation.correlation_id != decision.correlation_id ||
    decision.correlation_id != effect.correlation_id ||
    effect.correlation_id != next.correlation_id {
    return invalid_audit("audit chain correlation ids must match")
  }
  if decision.causation_ids != [observation.id] {
    return invalid_audit(
      "action_decision must causally link to the observation",
    )
  }
  if effect.causation_ids != [decision.id] {
    return invalid_audit("action_effect must causally link to the decision")
  }
  if next.causation_ids != [effect.id, "raw-screen-002"] &&
    next.causation_ids[0] != effect.id {
    return invalid_audit(
      "next scene_observation must causally link to the effect",
    )
  }
  let projections : Array[AuditProjection] = []
  for envelope in envelopes {
    projections.push(audit_projection(envelope))
  }
  Ok(projections)
}
