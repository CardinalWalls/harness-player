///|
test "hermes adapter maps to generic topology events" {
  let descriptor = @hermes.hermes_descriptor("exec-1", "channel-1", "default")
  let event = @hermes.to_topology_event(descriptor)

  inspect(@hermes.hermes_profile(descriptor), content="default")
  inspect(@topology.channel_id_of(event), content="channel-1")
  inspect(@topology.channel_kind_name(event), content="execution")
}
