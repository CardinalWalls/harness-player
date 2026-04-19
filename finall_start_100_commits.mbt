///|
/// Return a short description of the repository runtime contract.
pub fn runtime_contract() -> String {
  "OMX orchestrates; MoonBit validates."
}

///|
/// A compact end-to-end proof slice that ties runtime descriptors, generic topology,
/// control routing, durable assets, and provenance together.
pub struct ProofSliceSummary {
  session_key : String
  graph_key : String
  projection_source : String
  control_targeted : Bool
  skill_id : String
  commit_kind : String
  lineage_branch : String
  provenance_key : String
  adapter_channel_kind : String
}

///|
/// Construct the first proof slice summary from the current package boundaries.
pub fn proof_slice_summary() -> ProofSliceSummary {
  let session = @topology.session("exec-1", "default", "hermes")
  let execution = @topology.channel(
    "channel-exec-1",
    @topology.session_id_of(session),
    @topology.execution_channel_kind(),
  )
  let projection = @topology.projection(
    "projection-story-1",
    @topology.channel_id_of(execution),
    "story-lane",
  )
  let command = @control.route_input(
    @control.projection_target("projection-story-1"),
    "focus on story beats",
    10,
  )
  let observer = @topology.subscription(
    "observer-1",
    @topology.channel_id_of(execution),
    "story",
    @topology.targeted_delivery(),
  )
  let skill = @asset.skill_asset(
    "story-distiller", "v1", "distill execution into narrative beats", "proof-slice",
  )
  let commit = @asset.asset_commit(
    "commit-skill-1",
    @asset.skill_commit_kind(),
    @asset.skill_asset_id(skill),
    "captured the first story skill",
  )
  let lineage = @provenance.child_lineage_node("commit-skill-1", "main", "seed")
  let record = @provenance.provenance_record(commit, lineage)
  let hermes = @hermes.hermes_descriptor("exec-1", "channel-exec-1", "default")
  let adapter_event = @hermes.to_topology_event(hermes)
  let graph = @topology.topology_graph(session, execution, projection, observer)

  {
    session_key: @topology.session_descriptor_key(session),
    graph_key: @topology.topology_graph_key(graph),
    projection_source: @topology.projection_source(projection),
    control_targeted: @control.command_is_targeted(command),
    skill_id: @asset.skill_asset_id(skill),
    commit_kind: @asset.commit_kind_name(commit),
    lineage_branch: lineage.branch,
    provenance_key: @provenance.provenance_record_key(record),
    adapter_channel_kind: @topology.channel_kind_name(adapter_event),
  }
}

///|
/// Human-readable sentence for the current proof slice.
pub fn proof_slice_story() -> String {
  let summary = proof_slice_summary()
  "proof-slice[\{summary.session_key}] graph=\{summary.graph_key} asset=\{summary.skill_id} commit=\{summary.commit_kind} branch=\{summary.lineage_branch} provenance=\{summary.provenance_key} channel=\{summary.adapter_channel_kind}"
}
