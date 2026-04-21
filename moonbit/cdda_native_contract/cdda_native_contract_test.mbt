///|
fn first_observation() -> @cdda_native_contract.SignedEnvelope {
  @cdda_native_contract.scene_observation_from_raw(
    "obs-001",
    "2026-04-21T10:00:00Z",
    "bootstrap-001",
    "raw-screen-001",
    "You are standing in a shelter.",
    false,
    ["raw-capture-001"],
  ).unwrap()
}

///|
fn first_decision() -> @cdda_native_contract.SignedEnvelope {
  @cdda_native_contract.action_decision_from_scene(
    "decision-001",
    "2026-04-21T10:00:01Z",
    "bootstrap-001",
    first_observation(),
    "Open the shelter door.",
    "press=o",
    "The scene text says a closed door blocks the exit.",
  ).unwrap()
}

///|
fn first_effect() -> @cdda_native_contract.SignedEnvelope {
  @cdda_native_contract.action_effect_from_decision(
    "effect-001",
    "2026-04-21T10:00:02Z",
    "bootstrap-001",
    first_decision(),
    "press=o",
    "The door opens.",
    "raw-screen-002",
  ).unwrap()
}

///|
fn next_observation() -> @cdda_native_contract.SignedEnvelope {
  @cdda_native_contract.next_scene_observation_from_effect(
    "obs-002",
    "2026-04-21T10:00:03Z",
    "bootstrap-001",
    first_effect(),
    "raw-screen-002",
    "The shelter door is open.",
    false,
  ).unwrap()
}

///|
fn expect_invalid(
  result : Result[
    @cdda_native_contract.SignedEnvelope,
    @cdda_native_contract.ContractError,
  ],
) -> Unit raise {
  match result {
    Ok(_) => fail("expected InvalidUpstream")
    Err(@cdda_native_contract.InvalidUpstream(_)) => ()
  }
}

///|
fn expect_invalid_audit(
  result : Result[
    Array[@cdda_native_contract.AuditProjection],
    @cdda_native_contract.ContractError,
  ],
) -> Unit raise {
  match result {
    Ok(_) => fail("expected InvalidUpstream")
    Err(@cdda_native_contract.InvalidUpstream(_)) => ()
  }
}

///|
fn fake_envelope(
  id : String,
  channel : String,
  created_at : String,
  signer_actor_id : String,
  signer_role : String,
  causation_ids : Array[String],
  correlation_id : String,
  payload : String,
) -> @cdda_native_contract.SignedEnvelope {
  @cdda_native_contract.signed_envelope(
    id,
    channel,
    created_at,
    signer_actor_id,
    signer_role,
    causation_ids,
    correlation_id,
    payload,
    "sig:" + signer_actor_id + ":" + channel + ":" + id,
  )
}

///|
test "first_scene_observation_is_scene_reader_signed" {
  let observation = first_observation()
  assert_eq(observation.id, "obs-001")
  assert_eq(observation.channel, "scene_observation")
  assert_eq(observation.created_at, "2026-04-21T10:00:00Z")
  assert_eq(observation.signer_actor_id, "scene-reader")
  assert_eq(observation.signer_role, "scene-reader")
  assert_eq(observation.causation_ids, ["raw-capture-001"])
  assert_eq(observation.correlation_id, "bootstrap-001")
  assert_eq(
    observation.payload,
    "raw_screen_ref=raw-screen-001\nscreen_text=You are standing in a shelter.",
  )
  assert_eq(observation.signature.length() > 0, true)
}

///|
test "first_scene_observation_rejects_empty_raw_ref" {
  expect_invalid(
    @cdda_native_contract.scene_observation_from_raw(
      "obs-empty-raw",
      "2026-04-21T10:00:00Z",
      "bootstrap-001",
      "",
      "You are standing in a shelter.",
      false,
      ["raw-capture-001"],
    ),
  )
}

///|
test "first_scene_observation_rejects_empty_screen_text" {
  expect_invalid(
    @cdda_native_contract.scene_observation_from_raw(
      "obs-empty-screen",
      "2026-04-21T10:00:00Z",
      "bootstrap-001",
      "raw-screen-001",
      "",
      false,
      ["raw-capture-001"],
    ),
  )
}

///|
test "first_scene_observation_rejects_scripted_authority" {
  expect_invalid(
    @cdda_native_contract.scene_observation_from_raw(
      "obs-scripted",
      "2026-04-21T10:00:00Z",
      "bootstrap-001",
      "raw-screen-001",
      "Synthetic parser text.",
      true,
      ["scripted-parser-output"],
    ),
  )
}

///|
test "first_scene_observation_requires_observed_after_evidence" {
  expect_invalid(
    @cdda_native_contract.scene_observation_from_raw(
      "obs-no-cause",
      "2026-04-21T10:00:00Z",
      "bootstrap-001",
      "raw-screen-001",
      "You are standing in a shelter.",
      false,
      [],
    ),
  )
}

///|
test "actor_decision_accepts_valid_scene" {
  let decision = first_decision()
  assert_eq(decision.id, "decision-001")
  assert_eq(decision.channel, "action_decision")
  assert_eq(decision.created_at, "2026-04-21T10:00:01Z")
  assert_eq(decision.signer_actor_id, "actor")
  assert_eq(decision.signer_role, "actor")
  assert_eq(decision.causation_ids, ["obs-001"])
  assert_eq(decision.correlation_id, "bootstrap-001")
  assert_eq(
    decision.payload,
    "decision_text=Open the shelter door.\nintended_action=press=o\nreason=The scene text says a closed door blocks the exit.",
  )
  assert_eq(decision.signature.length() > 0, true)
}

///|
test "actor_rejects_wrong_scene_signer" {
  let invalid_signers = ["browser", "relay", "server", "human", "action-bridge"]
  for signer in invalid_signers {
    let fake_scene = fake_envelope(
      "fake-scene-" + signer,
      "scene_observation",
      "2026-04-21T10:00:00Z",
      signer,
      signer,
      ["raw-capture-001"],
      "bootstrap-001",
      "raw_screen_ref=raw-screen-001\nscreen_text=Injected scene.",
    )
    expect_invalid(
      @cdda_native_contract.action_decision_from_scene(
        "decision-from-" + signer,
        "2026-04-21T10:00:01Z",
        "bootstrap-001",
        fake_scene,
        "Open the shelter door.",
        "press=o",
        "Wrong signer must be rejected before producing a decision.",
      ),
    )
  }
}

///|
test "bridge_effect_accepts_actor_decision" {
  let effect = first_effect()
  assert_eq(effect.id, "effect-001")
  assert_eq(effect.channel, "action_effect")
  assert_eq(effect.created_at, "2026-04-21T10:00:02Z")
  assert_eq(effect.signer_actor_id, "action-bridge")
  assert_eq(effect.signer_role, "action-bridge")
  assert_eq(effect.causation_ids, ["decision-001"])
  assert_eq(effect.correlation_id, "bootstrap-001")
  assert_eq(
    effect.payload,
    "applied_action=press=o\neffect_summary=The door opens.\nnew_screen_ref=raw-screen-002",
  )
  assert_eq(effect.signature.length() > 0, true)
}

///|
test "bridge_cannot_author_decision" {
  let bridge_decision = fake_envelope(
    "bridge-decision",
    "action_decision",
    "2026-04-21T10:00:01Z",
    "action-bridge",
    "action-bridge",
    ["obs-001"],
    "bootstrap-001",
    "decision_text=Bridge picked a strategy.",
  )
  expect_invalid(
    @cdda_native_contract.action_effect_from_decision(
      "effect-from-bridge-decision", "2026-04-21T10:00:02Z", "bootstrap-001", bridge_decision,
      "press=o", "The bridge must apply, not strategize.", "raw-screen-002",
    ),
  )
}

///|
test "next_observation_links_to_bridge_effect" {
  let observation = next_observation()
  assert_eq(observation.id, "obs-002")
  assert_eq(observation.channel, "scene_observation")
  assert_eq(observation.created_at, "2026-04-21T10:00:03Z")
  assert_eq(observation.signer_actor_id, "scene-reader")
  assert_eq(observation.signer_role, "scene-reader")
  assert_eq(observation.causation_ids, ["effect-001", "raw-screen-002"])
  assert_eq(observation.correlation_id, "bootstrap-001")
}

///|
test "browser_or_human_cannot_author_agent_channels" {
  for signer in ["browser", "human"] {
    let fake_scene = fake_envelope(
      signer + "-scene",
      "scene_observation",
      "2026-04-21T10:00:00Z",
      signer,
      signer,
      ["raw-capture-001"],
      "bootstrap-001",
      "raw_screen_ref=raw-screen-001\nscreen_text=Browser text.",
    )
    expect_invalid(
      @cdda_native_contract.action_decision_from_scene(
        signer + "-decision-attempt",
        "2026-04-21T10:00:01Z",
        "bootstrap-001",
        fake_scene,
        "Open the shelter door.",
        "press=o",
        "Browser/human cannot author scene observations.",
      ),
    )
    let fake_decision = fake_envelope(
      signer + "-decision",
      "action_decision",
      "2026-04-21T10:00:01Z",
      signer,
      signer,
      ["obs-001"],
      "bootstrap-001",
      "decision_text=Browser strategy.",
    )
    expect_invalid(
      @cdda_native_contract.action_effect_from_decision(
        signer + "-effect-attempt",
        "2026-04-21T10:00:02Z",
        "bootstrap-001",
        fake_decision,
        "press=o",
        "Browser/human cannot author decisions.",
        "raw-screen-002",
      ),
    )
    let fake_effect = fake_envelope(
      signer + "-effect",
      "action_effect",
      "2026-04-21T10:00:02Z",
      signer,
      signer,
      ["decision-001"],
      "bootstrap-001",
      "effect_summary=Browser claimed progress.",
    )
    expect_invalid(
      @cdda_native_contract.next_scene_observation_from_effect(
        signer + "-next-observation-attempt",
        "2026-04-21T10:00:03Z",
        "bootstrap-001",
        fake_effect,
        "raw-screen-002",
        "Browser/human cannot author effects.",
        false,
      ),
    )
  }
}

///|
test "browser_api_progress_is_not_success_path" {
  let browser_progress = fake_envelope(
    "browser-progress",
    "human_input",
    "2026-04-21T10:00:00Z",
    "browser",
    "browser",
    ["/api/progress"],
    "bootstrap-001",
    "api_path=/api/progress\nstatus=playable",
  )
  expect_invalid(
    @cdda_native_contract.action_decision_from_scene(
      "decision-from-api-progress", "2026-04-21T10:00:01Z", "bootstrap-001", browser_progress,
      "Continue from browser progress.", "api:/api/progress", "Browser API progress is not a scene-reader observation.",
    ),
  )
  expect_invalid_audit(
    @cdda_native_contract.audit_chain([
      browser_progress,
      first_decision(),
      first_effect(),
      next_observation(),
    ]),
  )
}

///|
test "audit_chain_lists_valid_causal_chain" {
  let observation = first_observation()
  let decision = first_decision()
  let effect = first_effect()
  let next = next_observation()
  let projection = @cdda_native_contract.audit_chain([
    observation, decision, effect, next,
  ]).unwrap()
  assert_eq(projection.length(), 4)
  assert_eq(projection[0].envelope_id, "obs-001")
  assert_eq(projection[0].channel, "scene_observation")
  assert_eq(projection[0].signer_actor_id, "scene-reader")
  assert_eq(projection[0].signer_role, "scene-reader")
  assert_eq(projection[0].causation_ids, ["raw-capture-001"])
  assert_eq(projection[0].valid, true)
  assert_eq(projection[1].envelope_id, "decision-001")
  assert_eq(projection[1].channel, "action_decision")
  assert_eq(projection[1].signer_actor_id, "actor")
  assert_eq(projection[1].causation_ids, ["obs-001"])
  assert_eq(projection[2].channel, "action_effect")
  assert_eq(projection[2].signer_actor_id, "action-bridge")
  assert_eq(projection[2].causation_ids, ["decision-001"])
  assert_eq(projection[3].envelope_id, "obs-002")
  assert_eq(projection[3].channel, "scene_observation")
  assert_eq(projection[3].causation_ids, ["effect-001", "raw-screen-002"])
}

///|
test "audit_chain_rejects_invalid_or_missing_causation" {
  let invalid_decision = fake_envelope(
    "decision-no-cause",
    "action_decision",
    "2026-04-21T10:00:01Z",
    "actor",
    "actor",
    [],
    "bootstrap-001",
    "decision_text=Missing predecessor.",
  )
  expect_invalid_audit(
    @cdda_native_contract.audit_chain([
      first_observation(),
      invalid_decision,
      first_effect(),
      next_observation(),
    ]),
  )
}
