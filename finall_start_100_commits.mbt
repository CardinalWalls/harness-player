///|
/// Return a short description of the repository runtime contract.
pub fn runtime_contract() -> String {
  "OMX orchestrates; MoonBit validates."
}

///|
/// Configuration for the first thin CLI surface.
pub struct SurfaceConfig {
  route_body : String
  report_mode : String
  write_export : Bool
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
/// Stable snapshot for the first CLI-visible materialized export path.
pub struct MaterializedExportSnapshot {
  package_summary : String
  control_summary : String
  export_summary : String
  checkpoint_summary : String
  capture_summary : String
  materialization_summary : String
  payload_summary : String
  registry_summary : String
  manifest_summary : String
  activation_summary : String
  surface_summary : String
}

///|
/// Planned on-disk artifact for the first persisted materialized export path.
pub struct PersistedMaterializedExport {
  output_path : String
  checkpoint_id : String
  export_ref : String
  durable_ref : String
  report_body : String
}

///|
priv struct MaterializedExportDerived {
  package_id : String
  package_version : String
  snapshot : MaterializedExportSnapshot
  checkpoint_id : String
  export_ref : String
  durable_ref : String
}

///|
/// Default thin-surface report mode.
pub fn summary_report_mode() -> String {
  "summary"
}

///|
/// Report mode for the first CLI-visible materialized export surface.
pub fn materialized_export_report_mode() -> String {
  "materialized-export"
}

///|
/// Normalize CLI report-mode input onto the supported surface modes.
pub fn normalize_report_mode(mode : String) -> String {
  if mode == materialized_export_report_mode() {
    materialized_export_report_mode()
  } else {
    summary_report_mode()
  }
}

///|
/// Construct the first thin-surface config from a routed control body.
pub fn surface_config(route_body : String) -> SurfaceConfig {
  surface_config_with_mode(route_body, summary_report_mode())
}

///|
/// Construct the CLI surface config from a routed control body and report mode.
pub fn surface_config_with_mode(
  route_body : String,
  report_mode : String,
) -> SurfaceConfig {
  surface_config_with_options(route_body, report_mode, false)
}

///|
/// Construct the CLI surface config from routed input, report mode, and write intent.
pub fn surface_config_with_options(
  route_body : String,
  report_mode : String,
  write_export : Bool,
) -> SurfaceConfig {
  { route_body, report_mode: normalize_report_mode(report_mode), write_export }
}

///|
/// Enable the persisted materialized export write on an existing config.
pub fn with_export_write(config : SurfaceConfig) -> SurfaceConfig {
  {
    route_body: config.route_body,
    report_mode: config.report_mode,
    write_export: true,
  }
}

///|
/// Default routed control message for the thin local surface.
pub fn default_surface_config() -> SurfaceConfig {
  surface_config_with_mode("focus on story beats", summary_report_mode())
}

///|
/// Define the CLI contract for the first thin local surface.
pub fn surface_command() -> @argparse.Command {
  @argparse.Command::new(
    "proof-surface",
    about="Inspect the current proof slice and route one control input",
    flags=[
      @argparse.FlagArg(
        "write-export",
        long="write-export",
        about="Persist the materialized export report to disk",
      ),
    ],
    options=[
      @argparse.OptionArg::new(
        "route-body",
        short='r',
        about="Control input to route into the proof slice",
      ),
      @argparse.OptionArg::new(
        "report-mode",
        about="Report mode: summary or materialized-export",
      ),
    ],
  )
}

///|
/// Parse the thin local surface configuration from CLI argv.
pub fn parse_surface_config(argv : ArrayView[String]) -> SurfaceConfig raise {
  let matches = @argparse.parse(surface_command(), argv~)
  let values : Map[String, Array[String]] = matches.values
  let flags : Map[String, Bool] = matches.flags
  let route_body = match values.get("route-body") {
    Some([value, ..]) => value
    Some(_) => default_surface_config().route_body
    _ => default_surface_config().route_body
  }
  let report_mode = match values.get("report-mode") {
    Some([value, ..]) => normalize_report_mode(value)
    Some(_) => default_surface_config().report_mode
    _ => default_surface_config().report_mode
  }
  let write_export = match flags.get("write-export") {
    Some(value) => value
    None => false
  }
  surface_config_with_options(route_body, report_mode, write_export)
}

///|
/// Whether the current surface request should materialize a persisted export.
pub fn should_write_materialized_export(config : SurfaceConfig) -> Bool {
  config.write_export && config.report_mode == materialized_export_report_mode()
}

///|
/// Stable key for CLI and test assertions over a persisted export artifact.
pub fn persisted_materialized_export_key(
  persisted : PersistedMaterializedExport,
) -> String {
  "\{persisted.output_path}|\{persisted.checkpoint_id}|\{persisted.export_ref}|\{persisted.durable_ref}"
}

///|
/// Suggested filename for the first persisted materialized export artifact.
pub fn materialized_export_file_name(config : SurfaceConfig) -> String {
  let derived = materialized_export_derived(config)
  "\{derived.package_id}-\{derived.package_version}-\{derived.checkpoint_id}.txt"
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
fn control_target_summary(command : @control.ControlCommand) -> String {
  match command.target {
    @control.Broadcast => "broadcast"
    @control.Session(session_id) => "session:\{session_id}"
    @control.Channel(channel_id) => "channel:\{channel_id}"
    @control.Projection(projection_id) => "projection:\{projection_id}"
  }
}

///|
fn registry_match_summary(matches : Array[@mock.SharePackageSummary]) -> String {
  match matches {
    [first, ..] =>
      "\{first.package_id}|\{first.latest_version}|\{first.summary}"
    [] => "none"
  }
}

///|
fn manifest_fetch_summary(response : @mock.FetchManifestResponse?) -> String {
  match response {
    Some(found) => "\{found.manifest_ref}|\{found.integrity_hash}"
    None => "missing"
  }
}

///|
fn visible_channels_summary(surfaces : @mock.VisibleSurfacesResponse) -> String {
  match surfaces.channels {
    [first, second, ..] =>
      "channels=\{surfaces.channels.length()}|\{first.channel_id}:\{first.projection_count}|\{second.channel_id}:\{second.projection_count}"
    [first] => "channels=1|\{first.channel_id}:\{first.projection_count}"
    [] => "channels=0"
  }
}

///|
fn control_entries_summary(surfaces : @mock.VisibleSurfacesResponse) -> String {
  match surfaces.control_entries {
    [first, second, ..] =>
      "controls=\{surfaces.control_entries.length()}|\{first.entry_id}:\{first.action}|\{second.entry_id}:\{second.action}"
    [first] => "controls=1|\{first.entry_id}:\{first.action}"
    [] => "controls=0"
  }
}

///|
fn materialized_export_derived(
  config : SurfaceConfig,
) -> MaterializedExportDerived {
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
  let route = @provenance.route_materialization(
    @provenance.package_export_write_operation(),
  )
  let registry = @mock.first_wave_share_registry()
  let registry_matches = @mock.discover_packages(registry, "story-distiller", [
    @mock.skill_kind(),
  ])
  let manifest_fetch = @mock.fetch_manifest(
    registry,
    manifest.package_id,
    manifest.version,
  )
  let backend = @mock.first_wave_checkpoint_blob_backend()
  let payload_resolution = @mock.resolve_payload_ref(backend, event.payload_ref)
  let lineage_attachment = @mock.attach_lineage_metadata(
    backend,
    metadata.checkpoint_id,
    @provenance.lineage_ref_value(metadata.durable_ref),
  )
  let activation = @mock.first_wave_topology_activation()
  let activation_load = @mock.load_bundle(
    activation,
    @pkg.package_subject_ref(manifest.subject),
    manifest.profile_ref,
    manifest.topology_ref,
  )
  let surfaces = @mock.inspect_visible_surfaces(
    activation,
    activation_load.activation_id,
  )
  {
    package_id: manifest.package_id,
    package_version: manifest.version,
    snapshot: {
      package_summary: @pkg.package_manifest_key(manifest),
      control_summary: "\{control_target_summary(command)}|\{@control.command_body(command)}|\{command.priority}|\{@control.command_is_targeted(command)}",
      export_summary: @pkg.shareable_package_key(bundle),
      checkpoint_summary: @provenance.checkpoint_metadata_key(metadata),
      capture_summary: @capture.capture_record_key(capture),
      materialization_summary: "\{@provenance.materialization_operation_name(route.operation)}|\{@provenance.git_backend_name(route.backend)}|\{route.reason}",
      payload_summary: "\{payload_resolution.availability}|\{payload_resolution.blob_id}|\{lineage_attachment.attached}|\{lineage_attachment.durable_ref}",
      registry_summary: registry_match_summary(registry_matches),
      manifest_summary: manifest_fetch_summary(manifest_fetch),
      activation_summary: "\{activation_load.activation_id}|\{activation_load.channel_graph_ref}",
      surface_summary: "\{visible_channels_summary(surfaces)}|\{control_entries_summary(surfaces)}",
    },
    checkpoint_id: metadata.checkpoint_id,
    export_ref: bundle.export_ref,
    durable_ref: @provenance.lineage_ref_value(bundle.durable_ref),
  }
}

///|
/// Build the first materialized export report around the verified proof slice.
pub fn materialized_export_snapshot(
  config : SurfaceConfig,
) -> MaterializedExportSnapshot {
  materialized_export_derived(config).snapshot
}

///|
fn render_materialized_export_snapshot(
  snapshot : MaterializedExportSnapshot,
) -> String {
  "package=\{snapshot.package_summary}\ncontrol=\{snapshot.control_summary}\nexport=\{snapshot.export_summary}\ncheckpoint=\{snapshot.checkpoint_summary}\ncapture=\{snapshot.capture_summary}\nmaterialization=\{snapshot.materialization_summary}\npayload=\{snapshot.payload_summary}\nregistry=\{snapshot.registry_summary}\nmanifest=\{snapshot.manifest_summary}\nactivation=\{snapshot.activation_summary}\nsurface=\{snapshot.surface_summary}"
}

///|
/// Render the first thin local surface as a compact multiline CLI report.
pub fn thin_surface_report(config : SurfaceConfig) -> String {
  let snapshot = thin_surface_snapshot(config)
  "package=\{snapshot.package_summary}\nsession=\{snapshot.session_summary}\nchannel=\{snapshot.channel_summary}\ntopology=\{snapshot.topology_summary}\nprojection=\{snapshot.projection_summary}\nlineage=\{snapshot.lineage_summary}\ncapture=\{snapshot.capture_summary}\ncontrol=\{snapshot.control_summary}\nexport=\{snapshot.export_summary}"
}

///|
/// Render the first CLI-visible materialized export report.
pub fn materialized_export_report(config : SurfaceConfig) -> String {
  render_materialized_export_snapshot(materialized_export_snapshot(config))
}

///|
/// Build the first persisted materialized export artifact without writing it yet.
pub fn planned_materialized_export(
  output_path : String,
  config : SurfaceConfig,
) -> PersistedMaterializedExport {
  let derived = materialized_export_derived(config)
  {
    output_path,
    checkpoint_id: derived.checkpoint_id,
    export_ref: derived.export_ref,
    durable_ref: derived.durable_ref,
    report_body: render_materialized_export_snapshot(derived.snapshot),
  }
}

///|
/// Render the requested CLI surface report without changing the default summary mode.
pub fn surface_report(config : SurfaceConfig) -> String {
  if config.report_mode == materialized_export_report_mode() {
    materialized_export_report(config)
  } else {
    thin_surface_report(config)
  }
}

///|
/// Human-readable sentence for the current proof slice.
pub fn proof_slice_story() -> String {
  let summary = proof_slice_summary()
  "proof-slice[\{summary.session_key}] graph=\{summary.graph_key} asset=\{summary.skill_id} commit=\{summary.commit_kind} branch=\{summary.lineage_branch} provenance=\{summary.provenance_key} channel=\{summary.adapter_channel_kind}"
}
