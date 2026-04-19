///|
/// Reference descriptor for the first runnable Hermes integration path.
pub struct HermesDescriptor {
  session_id : @topology.SessionId
  channel_id : @topology.ChannelId
  profile : String
}

///|
/// Construct a Hermes adapter descriptor without leaking Hermes roles into the kernel.
pub fn hermes_descriptor(
  session_id : @topology.SessionId,
  channel_id : @topology.ChannelId,
  profile : String,
) -> HermesDescriptor {
  { session_id, channel_id, profile }
}

///|
/// Return the configured profile label for assertions and logs.
pub fn hermes_profile(descriptor : HermesDescriptor) -> String {
  descriptor.profile
}

///|
/// Translate the adapter descriptor into a generic topology channel descriptor.
pub fn to_topology_event(
  descriptor : HermesDescriptor,
) -> @topology.ChannelDescriptor {
  @topology.channel(
    descriptor.channel_id,
    descriptor.session_id,
    @topology.execution_channel_kind(),
  )
}
