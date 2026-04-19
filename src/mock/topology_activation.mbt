///|
/// Mock topology activation boundary kept separate from the real runtime adapter path.
pub struct MockTopologyActivation {
  runtime : String
}

///|
/// Response returned when a shareable bundle is loaded into the mock activation surface.
pub struct LoadBundleResponse {
  activation_id : String
  channel_graph_ref : String
}

///|
/// Visible channel projection counts exposed by the activation boundary.
pub struct VisibleChannel {
  channel_id : String
  projection_count : Int
}

///|
/// Control entries exposed to the thin control surface after activation.
pub struct ControlEntry {
  entry_id : String
  action : String
}

///|
/// Response returned when the mock activation surface is inspected.
pub struct VisibleSurfacesResponse {
  channels : Array[VisibleChannel]
  control_entries : Array[ControlEntry]
}

///|
/// Seed activation boundary for local tests.
pub fn first_wave_topology_activation() -> MockTopologyActivation {
  { runtime: "mock-topology" }
}

///|
/// Load a shareable bundle through the mock activation contract and derive a graph key.
pub fn load_bundle(
  activation : MockTopologyActivation,
  skill_ref : String,
  profile_ref : String,
  topology_ref : String,
) -> LoadBundleResponse {
  let activation_id = "activation://\{skill_ref}|\{profile_ref}|\{topology_ref}"
  let session = @topology.session(
    activation_id,
    profile_ref,
    activation.runtime,
  )
  let channel = @topology.channel(
    "channel://\{topology_ref}",
    @topology.session_id_of(session),
    @topology.execution_channel_kind(),
  )
  let projection = @topology.projection(
    "projection://\{skill_ref}",
    @topology.channel_id_of(channel),
    topology_ref,
  )
  let subscription = @topology.subscription(
    @topology.session_id_of(session),
    @topology.channel_id_of(channel),
    skill_ref,
    @topology.targeted_delivery(),
  )
  let graph = @topology.topology_graph(
    session, channel, projection, subscription,
  )
  { activation_id, channel_graph_ref: @topology.topology_graph_key(graph) }
}

///|
/// Inspect the visible channels and control entries surfaced by a mock activation.
pub fn inspect_visible_surfaces(
  _activation : MockTopologyActivation,
  activation_id : String,
) -> VisibleSurfacesResponse {
  {
    channels: [
      { channel_id: "\{activation_id}#execution", projection_count: 1 },
      { channel_id: "\{activation_id}#control", projection_count: 0 },
    ],
    control_entries: [
      { entry_id: "inspect", action: "inspect-visible-surfaces" },
      { entry_id: "export", action: "request-export" },
    ],
  }
}
