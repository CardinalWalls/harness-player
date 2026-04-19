///|
/// A lineage node records durable provenance semantics for an asset record.
pub struct LineageNode {
  id : String
  branch : String
  parent_id : String
}

///|
/// A minimal graph summary for lineage-oriented assertions.
pub struct HistoryGraph {
  head_id : String
  branch : String
  node_count : Int
}

///|
/// Construct a root lineage node.
pub fn root_lineage_node(id : String, branch : String) -> LineageNode {
  { id, branch, parent_id: "" }
}

///|
/// Construct a child lineage node linked to an earlier identifier.
pub fn child_lineage_node(
  id : String,
  branch : String,
  parent_id : String,
) -> LineageNode {
  { id, branch, parent_id }
}

///|
/// Construct a compact history graph summary.
pub fn history_graph(
  head_id : String,
  branch : String,
  node_count : Int,
) -> HistoryGraph {
  { head_id, branch, node_count }
}

///|
/// Whether a lineage node references a parent.
pub fn has_parent(node : LineageNode) -> Bool {
  node.parent_id != ""
}

///|
/// Return the number of nodes represented by the graph summary.
pub fn graph_node_count(graph : HistoryGraph) -> Int {
  graph.node_count
}
