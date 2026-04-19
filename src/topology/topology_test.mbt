///|
test "topology descriptors stay runtime agnostic" {
  let session = @topology.session("exec-1", "default", "reference-runtime")
  let channel = @topology.channel(
    "channel-1",
    @topology.session_id_of(session),
    @topology.execution_channel_kind(),
  )
  let projection = @topology.projection(
    "projection-1",
    @topology.channel_id_of(channel),
    "story-lane",
  )
  let broadcast = @topology.subscription(
    @topology.session_id_of(session),
    @topology.channel_id_of(channel),
    "all",
    @topology.broadcast_delivery(),
  )

  inspect(
    @topology.session_descriptor_key(session),
    content="reference-runtime:default:exec-1",
  )
  inspect(@topology.channel_kind_name(channel), content="execution")
  inspect(@topology.projection_source(projection), content="channel-1")
  inspect(@topology.subscription_is_targeted(broadcast), content="false")
}

///|
test "topology graph summarizes the first connected slice" {
  let session = @topology.session("exec-1", "default", "reference-runtime")
  let channel = @topology.channel(
    "channel-1",
    @topology.session_id_of(session),
    @topology.execution_channel_kind(),
  )
  let projection = @topology.projection(
    "projection-1", "channel-1", "story-lane",
  )
  let subscription = @topology.subscription(
    "observer-1",
    "channel-1",
    "story",
    @topology.targeted_delivery(),
  )
  let graph = @topology.topology_graph(
    session, channel, projection, subscription,
  )

  inspect(
    @topology.topology_graph_key(graph),
    content="sessions=1;channels=1;projections=1;subscriptions=1;root=exec-1/channel-1",
  )
}
