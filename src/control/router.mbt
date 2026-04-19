///|
/// Control targets remain generic and can point to sessions, channels, or projections.
pub enum ControlTarget {
  Broadcast
  Session(@topology.SessionId)
  Channel(@topology.ChannelId)
  Projection(@topology.ProjectionId)
}

///|
/// A routed control command keeps targeting separate from content payload.
pub struct ControlCommand {
  target : ControlTarget
  body : String
  priority : Int
}

///|
/// Construct a control command without binding it to a runtime-specific message bus.
pub fn route_input(
  target : ControlTarget,
  body : String,
  priority : Int,
) -> ControlCommand {
  { target, body, priority }
}

///|
/// Whether the routed command is targeted to a specific sink instead of broadcast.
pub fn command_is_targeted(command : ControlCommand) -> Bool {
  match command.target {
    Broadcast => false
    Session(_) => true
    Channel(_) => true
    Projection(_) => true
  }
}

///|
/// Return the body of a control command.
pub fn command_body(command : ControlCommand) -> String {
  command.body
}

///|
/// Public constructor for a session-targeted control route.
pub fn session_target(session_id : @topology.SessionId) -> ControlTarget {
  Session(session_id)
}

///|
/// Public constructor for a broadcast control route.
pub fn broadcast_target() -> ControlTarget {
  Broadcast
}

///|
/// Public constructor for a channel-targeted control route.
pub fn channel_target(channel_id : @topology.ChannelId) -> ControlTarget {
  Channel(channel_id)
}

///|
/// Public constructor for a projection-targeted control route.
pub fn projection_target(
  projection_id : @topology.ProjectionId,
) -> ControlTarget {
  Projection(projection_id)
}
