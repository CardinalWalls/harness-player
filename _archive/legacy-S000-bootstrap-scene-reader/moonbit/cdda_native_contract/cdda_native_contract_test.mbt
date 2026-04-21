///|
fn sample_raw() -> @cdda_native_contract.RawTruth {
  @cdda_native_contract.raw_truth(
    "raw-tui", "CDDA Raw TUI", 41, "You see a zombie.",
  )
}

///|
fn sample_scene() -> @cdda_native_contract.ChannelSnapshot {
  @cdda_native_contract.scene_state_from_raw(
    sample_raw(),
    107,
    "mode=combat-risk",
    "source_capture_id=raw-00041",
  )
}

///|
fn sample_intent() -> @cdda_native_contract.ChannelSnapshot {
  @cdda_native_contract.action_intent_from_scene(
    sample_scene(),
    32,
    "next_action=move_west",
    "input_scene_sequence=107",
  ).unwrap()
}

///|
fn sample_result() -> @cdda_native_contract.ChannelSnapshot {
  @cdda_native_contract.action_result_from_intent(
    sample_intent(),
    32,
    "success=true",
    "result_capture_id=raw-00042",
  ).unwrap()
}

///|
fn sample_supervisor() -> @cdda_native_contract.ChannelSnapshot {
  @cdda_native_contract.supervisor_reflection_from_intent(
    sample_intent(),
    9,
    "verdict=ok",
    "intent_sequence=32",
  ).unwrap()
}

///|
fn sample_human() -> @cdda_native_contract.ChannelSnapshot {
  @cdda_native_contract.human_instruction(
    4, "instruction=keep distance", "operator=human",
  )
}

///|
test "default_sections: supports more than five sections" {
  let sections = @cdda_native_contract.default_sections(
    sample_raw(),
    sample_scene(),
    sample_intent(),
    sample_result(),
    sample_supervisor(),
    Some(sample_human()),
  )
  assert_eq(sections.length(), 6)
}

///|
test "section_ids_for_channel: scene-state is reused across multiple sections" {
  let sections = @cdda_native_contract.default_sections(
    sample_raw(),
    sample_scene(),
    sample_intent(),
    sample_result(),
    sample_supervisor(),
    Some(sample_human()),
  )
  let ids = @cdda_native_contract.section_ids_for_channel(
    sections, "scene-state",
  )
  assert_eq(ids, [
    "raw-tui-to-scene-state", "scene-state-to-action-intent", "action-result-to-scene-state",
  ])
}

///|
test "writer constructors: reject invalid upstream channel" {
  let invalid = @cdda_native_contract.human_instruction(
    99, "instruction=bad upstream", "operator=human",
  )
  match
    @cdda_native_contract.action_intent_from_scene(
      invalid, 1, "next_action=wait", "bad upstream",
    ) {
    Ok(_) => fail("expected invalid upstream to be rejected")
    Err(@cdda_native_contract.InvalidUpstream(_)) => ()
  }
}

///|
test "default_sections: can omit human instruction" {
  let sections = @cdda_native_contract.default_sections(
    sample_raw(),
    sample_scene(),
    sample_intent(),
    sample_result(),
    sample_supervisor(),
    None,
  )
  assert_eq(sections.length(), 5)
}

///|
test "section model: explanations stay non-empty and participant pairs are preserved" {
  let sections = @cdda_native_contract.default_sections(
    sample_raw(),
    sample_scene(),
    sample_intent(),
    sample_result(),
    sample_supervisor(),
    Some(sample_human()),
  )
  let first = sections[0]
  assert_eq(first.relation.explanation.length() > 0, true)
  assert_eq(@cdda_native_contract.participant_id_of(first.left), "raw-tui")
  assert_eq(@cdda_native_contract.participant_id_of(first.right), "scene-state")
}

///|
fn bootstrap_observation() -> @cdda_native_contract.SignedEnvelope {
  @cdda_native_contract.scene_observation_from_raw(
    "obs-001", "bootstrap-001", "raw-screen-001", "MAIN MENU", false,
  ).unwrap()
}

///|
fn bootstrap_decision() -> @cdda_native_contract.SignedEnvelope {
  @cdda_native_contract.action_decision_from_scene(
    bootstrap_observation(),
    "decision-001",
    "press=enter",
  ).unwrap()
}

///|
fn bootstrap_effect() -> @cdda_native_contract.SignedEnvelope {
  @cdda_native_contract.action_effect_from_decision(
    bootstrap_decision(),
    "effect-001",
    "applied=enter",
  ).unwrap()
}

///|
test "signed bootstrap: first observation is scene-reader authored" {
  let observation = bootstrap_observation()
  assert_eq(observation.channel, "scene_observation")
  assert_eq(observation.signer_actor_id, "scene-reader")
  assert_eq(observation.signer_role, "scene-reader")
  assert_eq(observation.causation_ids, ["raw-screen-001"])
  assert_eq(observation.payload, "raw_ref=raw-screen-001\nscreen=MAIN MENU")
  assert_eq(observation.signature.length() > 0, true)
}

///|
test "signed bootstrap: actor decision consumes valid observation" {
  let observation = bootstrap_observation()
  let decision = @cdda_native_contract.action_decision_from_scene(
    observation, "decision-001", "press=enter",
  ).unwrap()
  assert_eq(decision.channel, "action_decision")
  assert_eq(decision.signer_actor_id, "actor")
  assert_eq(decision.signer_role, "actor")
  assert_eq(decision.causation_ids, ["obs-001"])
}

///|
test "signed bootstrap: wrong scene observation authors are rejected" {
  let invalid_signers = ["browser", "relay-server", "human", "action-bridge"]
  for signer in invalid_signers {
    let fake_scene = @cdda_native_contract.signed_envelope(
      "fake-" + signer,
      "scene_observation",
      signer,
      signer,
      ["raw-screen-001"],
      "bootstrap-001",
      "raw_ref=raw-screen-001\nscreen=MAIN MENU",
      "sig:" + signer,
    )
    match
      @cdda_native_contract.action_decision_from_scene(
        fake_scene,
        "decision-" + signer,
        "press=enter",
      ) {
      Ok(_) => fail("expected wrong scene_observation signer to be rejected")
      Err(@cdda_native_contract.InvalidUpstream(_)) => ()
    }
  }
}

///|
test "signed bootstrap: bridge reports effect without becoming strategist" {
  let decision = bootstrap_decision()
  let effect = @cdda_native_contract.action_effect_from_decision(
    decision, "effect-001", "applied=enter",
  ).unwrap()
  assert_eq(effect.channel, "action_effect")
  assert_eq(effect.signer_actor_id, "action-bridge")
  assert_eq(effect.signer_role, "action-bridge")
  assert_eq(effect.causation_ids, ["decision-001"])
  match
    @cdda_native_contract.action_decision_from_scene_as(
      bootstrap_observation(),
      "bad-decision-bridge",
      "press=enter",
      "action-bridge",
      "action-bridge",
    ) {
    Ok(_) => fail("expected bridge-as-strategist to be rejected")
    Err(@cdda_native_contract.InvalidUpstream(_)) => ()
  }
}

///|
test "signed bootstrap: next observation closes loop" {
  let next_observation = @cdda_native_contract.next_scene_observation_from_effect(
    bootstrap_effect(),
    "obs-002",
    "bootstrap-001",
    "raw-screen-002",
    "WORLD VIEW",
    false,
  ).unwrap()
  assert_eq(next_observation.channel, "scene_observation")
  assert_eq(next_observation.signer_actor_id, "scene-reader")
  assert_eq(next_observation.causation_ids, ["effect-001", "raw-screen-002"])
}

///|
test "signed bootstrap: browser remains non privileged" {
  let browser_scene = @cdda_native_contract.signed_envelope(
    "browser-progress",
    "scene_observation",
    "browser",
    "browser",
    ["raw-screen-001"],
    "bootstrap-001",
    "api_path=/api/progress\nscreen=MAIN MENU",
    "sig:browser",
  )
  match
    @cdda_native_contract.action_decision_from_scene(
      browser_scene, "decision-browser", "press=enter",
    ) {
    Ok(_) => fail("expected browser-authored scene observation to be rejected")
    Err(@cdda_native_contract.InvalidUpstream(_)) => ()
  }
  match
    @cdda_native_contract.action_decision_from_scene_as(
      bootstrap_observation(),
      "decision-human",
      "press=enter",
      "human",
      "human",
    ) {
    Ok(_) => fail("expected human-authored action decision to be rejected")
    Err(@cdda_native_contract.InvalidUpstream(_)) => ()
  }
}

///|
test "signed bootstrap: scripted screen authority and missing causation rejected" {
  match
    @cdda_native_contract.scene_observation_from_raw(
      "obs-scripted", "bootstrap-001", "raw-screen-001", "scripted screen says playable",
      true,
    ) {
    Ok(_) =>
      fail("expected scripted/parser authoritative screen to be rejected")
    Err(@cdda_native_contract.InvalidUpstream(_)) => ()
  }
  let missing_scene_causation = @cdda_native_contract.signed_envelope(
    "obs-missing-cause",
    "scene_observation",
    "scene-reader",
    "scene-reader",
    [],
    "bootstrap-001",
    "raw_ref=raw-screen-001\nscreen=MAIN MENU",
    "sig:scene-reader",
  )
  match
    @cdda_native_contract.action_decision_from_scene(
      missing_scene_causation, "decision-missing-cause", "press=enter",
    ) {
    Ok(_) => fail("expected missing observation causation to be rejected")
    Err(@cdda_native_contract.InvalidUpstream(_)) => ()
  }
  let missing_decision_causation = @cdda_native_contract.signed_envelope(
    "decision-missing-cause",
    "action_decision",
    "actor",
    "actor",
    [],
    "bootstrap-001",
    "press=enter",
    "sig:actor",
  )
  match
    @cdda_native_contract.action_effect_from_decision(
      missing_decision_causation, "effect-missing-cause", "applied=enter",
    ) {
    Ok(_) => fail("expected missing decision causation to be rejected")
    Err(@cdda_native_contract.InvalidUpstream(_)) => ()
  }
}

///|
test "signed bootstrap: audit projection explains causal chain" {
  let observation = bootstrap_observation()
  let decision = @cdda_native_contract.action_decision_from_scene(
    observation, "decision-001", "press=enter",
  ).unwrap()
  let effect = @cdda_native_contract.action_effect_from_decision(
    decision, "effect-001", "applied=enter",
  ).unwrap()
  let next_observation = @cdda_native_contract.next_scene_observation_from_effect(
    effect, "obs-002", "bootstrap-001", "raw-screen-002", "WORLD VIEW", false,
  ).unwrap()
  let rows = @cdda_native_contract.audit_chain([
    observation, decision, effect, next_observation,
  ]).unwrap()
  assert_eq(rows.length(), 4)
  assert_eq(rows[0].channel, "scene_observation")
  assert_eq(rows[0].signer_actor_id, "scene-reader")
  assert_eq(rows[0].causation_ids, ["raw-screen-001"])
  assert_eq(rows[1].channel, "action_decision")
  assert_eq(rows[1].causation_ids, ["obs-001"])
  assert_eq(rows[2].channel, "action_effect")
  assert_eq(rows[2].signer_actor_id, "action-bridge")
  assert_eq(rows[3].causation_ids, ["effect-001", "raw-screen-002"])
}
