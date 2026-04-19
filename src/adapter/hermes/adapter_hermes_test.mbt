///|
test "hermes adapter maps to generic topology events" {
  let descriptor = @hermes.hermes_descriptor("exec-1", "channel-1", "default")
  let event = @hermes.to_topology_event(descriptor)

  inspect(@hermes.hermes_profile(descriptor), content="default")
  inspect(@topology.channel_id_of(event), content="channel-1")
  inspect(@topology.channel_kind_name(event), content="execution")
}

///|
test "hermes adapter emits runtime events for capture normalization" {
  let descriptor = @hermes.hermes_descriptor("exec-2", "channel-2", "authoring")
  let event = @hermes.emit_runtime_event(
    descriptor, "skill-export-requested", "payload://checkpoint-2/story-distiller",
  )

  inspect(@capture.runtime_event_runtime(event), content="hermes")
  inspect(@capture.runtime_event_profile(event), content="authoring")
  inspect(
    @capture.runtime_event_key(event),
    content="hermes|authoring|exec-2|channel-2|skill-export-requested|payload://checkpoint-2/story-distiller",
  )
}
