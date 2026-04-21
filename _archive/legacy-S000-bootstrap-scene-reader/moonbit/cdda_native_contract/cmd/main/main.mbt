///|
fn main {
  let raw = @lib.raw_truth("raw-tui", "CDDA Raw TUI", 41, "You see a zombie.")
  let scene = @lib.scene_state_from_raw(
    raw, 107, "mode=combat-risk", "source_capture_id=raw-00041",
  )
  let intent = @lib.action_intent_from_scene(
    scene, 32, "next_action=move_west", "input_scene_sequence=107",
  ).unwrap()
  let result = @lib.action_result_from_intent(
    intent, 32, "success=true", "result_capture_id=raw-00042",
  ).unwrap()
  let supervisor = @lib.supervisor_reflection_from_intent(
    intent, 9, "verdict=ok", "intent_sequence=32",
  ).unwrap()
  let human = @lib.human_instruction(
    4, "instruction=keep distance", "operator=human",
  )
  let sections = @lib.default_sections(
    raw,
    scene,
    intent,
    result,
    supervisor,
    Some(human),
  )
  println("sections=" + sections.length().to_string())
  println(
    "scene-state reused in=" +
    @lib.section_ids_for_channel(sections, "scene-state").join(", "),
  )
}
