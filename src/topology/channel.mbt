///|
/// Runtime-agnostic identifier for a channel.
pub type ChannelId = String

///|
/// Channels carry either raw execution flow, derived projections, or control input.
pub enum ChannelKind {
  Execution
  Projection
  Control
}

///|
/// Descriptor for a channel surfaced through the topology layer.
pub struct ChannelDescriptor {
  id : ChannelId
  source_session : SessionId
  kind : ChannelKind
}

///|
/// Construct a channel descriptor from generic topology data.
pub fn channel(
  id : ChannelId,
  source_session : SessionId,
  kind : ChannelKind,
) -> ChannelDescriptor {
  { id, source_session, kind }
}

///|
/// Return the identifier of a channel descriptor.
pub fn channel_id_of(descriptor : ChannelDescriptor) -> ChannelId {
  descriptor.id
}

///|
/// Return the channel kind as a stable string for tests and logs.
pub fn channel_kind_name(descriptor : ChannelDescriptor) -> String {
  match descriptor.kind {
    Execution => "execution"
    Projection => "projection"
    Control => "control"
  }
}

///|
/// Public constructor for execution channels across package boundaries.
pub fn execution_channel_kind() -> ChannelKind {
  Execution
}

///|
/// Public constructor for projection channels across package boundaries.
pub fn projection_channel_kind() -> ChannelKind {
  Projection
}

///|
/// Public constructor for control channels across package boundaries.
pub fn control_channel_kind() -> ChannelKind {
  Control
}
