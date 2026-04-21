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
pub fn scene_observation_from_raw(
  _id : String,
  _created_at : String,
  _correlation_id : String,
  _raw_screen_ref : String,
  _screen_text : String,
  _scripted_authority : Bool,
  _observed_after : Array[String],
) -> Result[SignedEnvelope, ContractError] {
  Err(InvalidUpstream("scene_observation_from_raw not implemented"))
}

///|
pub fn action_decision_from_scene(
  _id : String,
  _created_at : String,
  _correlation_id : String,
  _scene : SignedEnvelope,
  _decision_text : String,
  _intended_action : String,
  _reason : String,
) -> Result[SignedEnvelope, ContractError] {
  Err(InvalidUpstream("action_decision_from_scene not implemented"))
}

///|
pub fn action_effect_from_decision(
  _id : String,
  _created_at : String,
  _correlation_id : String,
  _decision : SignedEnvelope,
  _applied_action : String,
  _effect_summary : String,
  _new_screen_ref : String,
) -> Result[SignedEnvelope, ContractError] {
  Err(InvalidUpstream("action_effect_from_decision not implemented"))
}

///|
pub fn next_scene_observation_from_effect(
  _id : String,
  _created_at : String,
  _correlation_id : String,
  _effect : SignedEnvelope,
  _raw_screen_ref : String,
  _screen_text : String,
  _scripted_authority : Bool,
) -> Result[SignedEnvelope, ContractError] {
  Err(InvalidUpstream("next_scene_observation_from_effect not implemented"))
}

///|
pub fn audit_chain(
  _envelopes : Array[SignedEnvelope],
) -> Result[Array[AuditProjection], ContractError] {
  Err(InvalidUpstream("audit_chain not implemented"))
}
