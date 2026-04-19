///|
/// A compact graph summary for the first connected proof slice.
pub struct TopologyGraph {
  session_count : Int
  channel_count : Int
  projection_count : Int
  subscription_count : Int
  root_session : SessionId
  root_channel : ChannelId
}

///|
/// Build a graph summary from a minimal connected topology slice.
pub fn topology_graph(
  session : SessionDescriptor,
  channel : ChannelDescriptor,
  _projection : ProjectionDescriptor,
  _subscription : Subscription,
) -> TopologyGraph {
  {
    session_count: 1,
    channel_count: 1,
    projection_count: 1,
    subscription_count: 1,
    root_session: session.id,
    root_channel: channel.id,
  }
}

///|
/// Stable key for graph-level assertions and summaries.
pub fn topology_graph_key(graph : TopologyGraph) -> String {
  "sessions=\{graph.session_count};channels=\{graph.channel_count};projections=\{graph.projection_count};subscriptions=\{graph.subscription_count};root=\{graph.root_session}/\{graph.root_channel}"
}
