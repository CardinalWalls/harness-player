///|
/// Return a short description of the repository runtime contract.
pub fn runtime_contract() -> String {
  "OMX orchestrates; MoonBit validates."
}

///|
/// Configuration for the first thin CLI surface.
pub struct SurfaceConfig {
  route_body : String
}

///|
/// Stable snapshot surfaced by the first CLI-oriented control plane proof.
pub struct ThinSurfaceSnapshot {
  package_summary : String
  session_summary : String
  channel_summary : String
  topology_summary : String
  projection_summary : String
  lineage_summary : String
  capture_summary : String
  control_summary : String
  export_summary : String
}

///|
/// Construct the first thin-surface config from a routed control body.
pub fn surface_config(route_body : String) -> SurfaceConfig {
  { route_body, }
}

///|
/// Default routed control message for the thin local surface.
pub fn default_surface_config() -> SurfaceConfig {
  surface_config("focus on story beats")
}

///|
/// Define the CLI contract for the first thin local surface.
pub fn surface_command() -> @argparse.Command {
  @argparse.Command::new(
    "proof-surface",
    about="Inspect the current proof slice and route one control input",
    options=[
      @argparse.OptionArg::new(
        "route-body",
        short='r',
        about="Control input to route into the proof slice",
      ),
    ],
  )
}

///|
/// Parse the thin local surface configuration from CLI argv.
pub fn parse_surface_config(argv : ArrayView[String]) -> SurfaceConfig raise {
  let matches = @argparse.parse(surface_command(), argv~)
  let values : Map[String, Array[String]] = matches.values
  let route_body = match values.get("route-body") {
    Some([value, ..]) => value
    Some(_) => default_surface_config().route_body
    _ => default_surface_config().route_body
  }
  surface_config(route_body)
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
/// Build the first thin local control-plane surface around the verified proof slice.
pub fn thin_surface_snapshot(config : SurfaceConfig) -> ThinSurfaceSnapshot {
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
    @control.projection_target(projection.id),
    config.route_body,
    10,
  )
  let observer = @topology.subscription(
    "observer-1",
    @topology.channel_id_of(execution),
    "story",
    @topology.targeted_delivery(),
  )
  let graph = @topology.topology_graph(session, execution, projection, observer)
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
  let metadata = @provenance.checkpoint_metadata(
    "checkpoint-1",
    @asset.skill_asset_id(skill),
    "main",
    session.id,
    execution.id,
    projection.id,
    @provenance.snapshot_ref("snapshot-1"),
    @provenance.commit_ref("commit-9"),
    "checkpoint-0",
  )
  let manifest = @pkg.package_manifest(
    "pkg-story-distiller",
    "v1",
    @pkg.skill_subject(@asset.skill_asset_id(skill)),
    "profile/default",
    "topology/story-loop",
    @provenance.provenance_record_key(record),
  )
  let bundle = @pkg.shareable_package(
    manifest,
    "Story Distiller",
    "export://packages/pkg-story-distiller/v1",
    @provenance.checkpoint_id_of(metadata),
    @provenance.checkpoint_durable_ref(metadata),
  )
  let hermes = @hermes.hermes_descriptor(
    session.id,
    execution.id,
    session.profile,
  )
  let event = @hermes.emit_runtime_event(
    hermes, "skill-export-requested", "payload://checkpoint-1/story-distiller",
  )
  let capture = @capture.normalize_runtime_event(event, metadata)
  let target_summary = match command.target {
    @control.Broadcast => "broadcast"
    @control.Session(session_id) => "session:\{session_id}"
    @control.Channel(channel_id) => "channel:\{channel_id}"
    @control.Projection(projection_id) => "projection:\{projection_id}"
  }
  {
    package_summary: @pkg.package_manifest_key(manifest),
    session_summary: @topology.session_descriptor_key(session),
    channel_summary: "\{execution.id}|\{@topology.channel_kind_name(execution)}|\{execution.source_session}",
    topology_summary: @topology.topology_graph_key(graph),
    projection_summary: "\{projection.id}|\{projection.source_channel}|\{projection.summary}",
    lineage_summary: @provenance.provenance_record_key(record),
    capture_summary: @capture.capture_record_key(capture),
    control_summary: "\{target_summary}|\{@control.command_body(command)}|\{command.priority}|\{@control.command_is_targeted(command)}",
    export_summary: @pkg.shareable_package_key(bundle),
  }
}

///|
/// Render the first thin local surface as a compact multiline CLI report.
pub fn thin_surface_report(config : SurfaceConfig) -> String {
  let snapshot = thin_surface_snapshot(config)
  "package=\{snapshot.package_summary}\nsession=\{snapshot.session_summary}\nchannel=\{snapshot.channel_summary}\ntopology=\{snapshot.topology_summary}\nprojection=\{snapshot.projection_summary}\nlineage=\{snapshot.lineage_summary}\ncapture=\{snapshot.capture_summary}\ncontrol=\{snapshot.control_summary}\nexport=\{snapshot.export_summary}"
}

///|
/// Human-readable sentence for the current proof slice.
pub fn proof_slice_story() -> String {
  let summary = proof_slice_summary()
  "proof-slice[\{summary.session_key}] graph=\{summary.graph_key} asset=\{summary.skill_id} commit=\{summary.commit_kind} branch=\{summary.lineage_branch} provenance=\{summary.provenance_key} channel=\{summary.adapter_channel_kind}"
}
