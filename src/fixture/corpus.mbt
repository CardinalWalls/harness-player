///|
/// Materialized local fixture for a first-wave skill corpus entry.
pub struct SkillFixture {
  id : String
  asset_class : String
  capture_mode : String
  status : String
  package_id : String
  version : String
  skill_ref : String
  source_path_1 : String
  source_path_2 : String
  source_path_3 : String
  primary_path : String
  primary_body : String
  secondary_path : String
  secondary_body : String
  tertiary_path : String
  tertiary_body : String
  file_count : Int
  validation_target_1 : String
  validation_target_2 : String
  validation_target_3 : String
  inclusion_reason : String
}

///|
/// Materialized local fixture for a first-wave provenance metadata sample.
pub struct ProvenanceFixture {
  id : String
  asset_class : String
  capture_mode : String
  status : String
  source_path_1 : String
  source_path_2 : String
  source_path_3 : String
  metadata_path : String
  metadata_body : String
  checkpoint_id : String
  asset_id : String
  branch : String
  session_id : String
  channel_id : String
  projection_id : String
  snapshot_ref : String
  durable_ref : String
  parent_checkpoint_id : String
  validation_target_1 : String
  validation_target_2 : String
  validation_target_3 : String
  inclusion_reason : String
}

///|
/// Materialized local fixture for a first-wave topology asset entry.
pub struct TopologyFixture {
  id : String
  pattern_family : String
  source_kind : String
  collection_mode : String
  status : String
  package_id : String
  version : String
  topology_ref : String
  source_ref_1 : String
  source_ref_2 : String
  validation_target_1 : String
  validation_target_2 : String
  validation_target_3 : String
  profile_boundary : String
  runtime_state_boundary : String
  inclusion_reason : String
}

///|
/// The locally materialized first-wave fixture set from the frozen corpus manifest.
pub struct FirstWaveCorpus {
  skill_template_minimal : SkillFixture
  algorithmic_art_minimal_real : SkillFixture
  pdf_reference_rich : SkillFixture
  slack_gif_creator_dependency : SkillFixture
  theme_factory_static_asset : SkillFixture
  entire_checkpoint_metadata : ProvenanceFixture
  orchestrator_subagent_baseline : TopologyFixture
  generator_verifier_loop : TopologyFixture
  shared_state_research_slate : TopologyFixture
  message_bus_event_routing : TopologyFixture
  agent_teams_partitioned_work : TopologyFixture
  custom_hybrid_composition : TopologyFixture
}

///|
fn skill_fixture(
  id : String,
  asset_class : String,
  capture_mode : String,
  package_id : String,
  version : String,
  skill_ref : String,
  source_path_1 : String,
  source_path_2 : String,
  source_path_3 : String,
  primary_path : String,
  primary_body : String,
  secondary_path : String,
  secondary_body : String,
  tertiary_path : String,
  tertiary_body : String,
  file_count : Int,
  validation_target_1 : String,
  validation_target_2 : String,
  validation_target_3 : String,
  inclusion_reason : String,
) -> SkillFixture {
  {
    id,
    asset_class,
    capture_mode,
    status: "approved-first-wave",
    package_id,
    version,
    skill_ref,
    source_path_1,
    source_path_2,
    source_path_3,
    primary_path,
    primary_body,
    secondary_path,
    secondary_body,
    tertiary_path,
    tertiary_body,
    file_count,
    validation_target_1,
    validation_target_2,
    validation_target_3,
    inclusion_reason,
  }
}

///|
fn provenance_fixture(
  id : String,
  asset_class : String,
  capture_mode : String,
  source_path_1 : String,
  source_path_2 : String,
  source_path_3 : String,
  metadata_path : String,
  metadata_body : String,
  checkpoint_id : String,
  asset_id : String,
  branch : String,
  session_id : String,
  channel_id : String,
  projection_id : String,
  snapshot_ref : String,
  durable_ref : String,
  parent_checkpoint_id : String,
  validation_target_1 : String,
  validation_target_2 : String,
  validation_target_3 : String,
  inclusion_reason : String,
) -> ProvenanceFixture {
  {
    id,
    asset_class,
    capture_mode,
    status: "approved-first-wave",
    source_path_1,
    source_path_2,
    source_path_3,
    metadata_path,
    metadata_body,
    checkpoint_id,
    asset_id,
    branch,
    session_id,
    channel_id,
    projection_id,
    snapshot_ref,
    durable_ref,
    parent_checkpoint_id,
    validation_target_1,
    validation_target_2,
    validation_target_3,
    inclusion_reason,
  }
}

///|
fn topology_fixture(
  id : String,
  pattern_family : String,
  source_kind : String,
  collection_mode : String,
  package_id : String,
  version : String,
  topology_ref : String,
  source_ref_1 : String,
  source_ref_2 : String,
  validation_target_1 : String,
  validation_target_2 : String,
  validation_target_3 : String,
  profile_boundary : String,
  runtime_state_boundary : String,
  inclusion_reason : String,
) -> TopologyFixture {
  {
    id,
    pattern_family,
    source_kind,
    collection_mode,
    status: "approved-first-wave",
    package_id,
    version,
    topology_ref,
    source_ref_1,
    source_ref_2,
    validation_target_1,
    validation_target_2,
    validation_target_3,
    profile_boundary,
    runtime_state_boundary,
    inclusion_reason,
  }
}

///|
/// Stable summary of the approved first-wave ids preserved in local fixtures.
pub fn first_wave_fixture_ids() -> String {
  "skill-template-minimal|algorithmic-art-minimal-real|pdf-reference-rich|slack-gif-creator-dependency|theme-factory-static-asset|entire-checkpoint-metadata|orchestrator-subagent-baseline|generator-verifier-loop|shared-state-research-slate|message-bus-event-routing|agent-teams-partitioned-work|custom-hybrid-composition"
}

///|
/// The frozen first-wave fixture count.
pub fn first_wave_fixture_count() -> Int {
  12
}

///|
/// Construct the locally materialized first-wave corpus fixture set.
pub fn first_wave_corpus() -> FirstWaveCorpus {
  {
    skill_template_minimal: skill_fixture(
      "skill-template-minimal", "canonical-skill", "mirror-selected-file", "pkg-skill-template-minimal",
      "v1", "skill-template-minimal@v1", "/tmp/omx-research/skills/template/SKILL.md",
      "", "", "skill-template-minimal/SKILL.md", "---\nname: skill-template-minimal\ndescription: Minimal canonical fixture for frontmatter and body validation.\n---\n\nOffer one stable instruction before expanding into helper resources.\n",
      "", "", "", "", 1, "minimum accepted shape", "frontmatter parsing", "name and description validation",
      "Clean baseline for the public standard.",
    ),
    algorithmic_art_minimal_real: skill_fixture(
      "algorithmic-art-minimal-real", "lightweight-public-skill", "mirror-selected-file",
      "pkg-algorithmic-art-minimal-real", "v1", "algorithmic-art-minimal-real@v1",
      "/tmp/omx-research/skills/skills/algorithmic-art/SKILL.md", "", "", "algorithmic-art-minimal-real/SKILL.md",
      "---\nname: algorithmic-art-minimal-real\ndescription: Lightweight public skill fixture with a realistic body.\n---\n\nGenerate pattern prompts, keep palette constraints explicit, and prefer deterministic seeds.\n",
      "", "", "", "", 1, "realistic lightweight skill body", "standard-compatible packaging",
      "", "Real public example with low structural complexity.",
    ),
    pdf_reference_rich: skill_fixture(
      "pdf-reference-rich", "reference-rich-skill", "mirror-folder-subset", "pkg-pdf-reference-rich",
      "v1", "pdf-reference-rich@v1", "/tmp/omx-research/skills/skills/pdf/SKILL.md",
      "/tmp/omx-research/skills/skills/pdf/forms.md", "/tmp/omx-research/skills/skills/pdf/reference.md",
      "pdf-reference-rich/SKILL.md", "---\nname: pdf-reference-rich\ndescription: Reference-rich fixture that points readers to forms and detailed notes.\n---\n\nStart with the quick PDF workflow, then read forms.md and reference.md when the task needs deeper handling.\n",
      "pdf-reference-rich/forms.md", "# forms\n\n- inspect AcroForm fields\n- preserve field names during extraction\n",
      "pdf-reference-rich/reference.md", "# reference\n\nUse OCR only after embedded text extraction fails, and record why fallback was needed.\n",
      3, "progressive disclosure", "multi-file integrity", "reference handling",
      "Strong example of a structured skill that is still standards-shaped.",
    ),
    slack_gif_creator_dependency: skill_fixture(
      "slack-gif-creator-dependency", "dependency-bearing-skill", "mirror-folder-subset",
      "pkg-slack-gif-creator-dependency", "v1", "slack-gif-creator-dependency@v1",
      "/tmp/omx-research/skills/skills/slack-gif-creator/SKILL.md", "/tmp/omx-research/skills/skills/slack-gif-creator/requirements.txt",
      "", "slack-gif-creator-dependency/SKILL.md", "---\nname: slack-gif-creator-dependency\ndescription: Fixture for skills that depend on a helper runtime outside SKILL.md.\n---\n\nRender a short animation only after the supporting Python dependencies are available.\n",
      "slack-gif-creator-dependency/requirements.txt", "Pillow==10.4.0\nslack-sdk==3.31.0\n",
      "", "", 2, "dependency metadata interpretation", "nontrivial folder validation",
      "", "Captures skills that imply runtime dependencies outside SKILL.md.",
    ),
    theme_factory_static_asset: skill_fixture(
      "theme-factory-static-asset", "static-asset-skill", "mirror-folder-subset",
      "pkg-theme-factory-static-asset", "v1", "theme-factory-static-asset@v1", "/tmp/omx-research/skills/skills/theme-factory/SKILL.md",
      "/tmp/omx-research/skills/skills/theme-factory/theme-showcase.pdf", "", "theme-factory-static-asset/SKILL.md",
      "---\nname: theme-factory-static-asset\ndescription: Fixture for skills that ship static showcase assets beside SKILL.md.\n---\n\nPresent the theme workflow summary first, then open the bundled showcase PDF when visuals matter.\n",
      "theme-factory-static-asset/theme-showcase.pdf", "%PDF-1.4\n% fixture theme showcase\n1 0 obj\n<< /Type /Catalog >>\nendobj\ntrailer\n<<>>\n%%EOF\n",
      "", "", 2, "asset packaging", "asset reference integrity", "package size assumptions",
      "Ensures the package model handles bundled binary or large side assets.",
    ),
    entire_checkpoint_metadata: provenance_fixture(
      "entire-checkpoint-metadata", "provenance-metadata-sample", "derive-metadata-fixture",
      "/tmp/omx-research/cli/docs/architecture/sessions-and-checkpoints.md", "/tmp/omx-research/cli/e2e/tests/checkpoint_metadata_test.go",
      "/tmp/omx-research/cli/e2e/testutil/metadata.go", "entire-checkpoint-metadata/checkpoint-metadata.json",
      "{\n  \"checkpoint_id\": \"checkpoint-entire-1\",\n  \"asset_id\": \"skill-template-minimal@v1\",\n  \"branch\": \"main\",\n  \"session_id\": \"session-entire-1\",\n  \"channel_id\": \"channel-entire-1\",\n  \"projection_id\": \"projection-entire-1\",\n  \"snapshot_ref\": \"snapshot-entire-1\",\n  \"durable_ref\": \"commit-entire-9\",\n  \"parent_checkpoint_id\": \"checkpoint-entire-0\"\n}\n",
      "checkpoint-entire-1", "skill-template-minimal@v1", "main", "session-entire-1",
      "channel-entire-1", "projection-entire-1", "snapshot-entire-1", "commit-entire-9",
      "checkpoint-entire-0", "checkpoint summary structure", "lineage rules", "local-vs-durable split",
      "Strongest current open reference for durable metadata tied to commits.",
    ),
    orchestrator_subagent_baseline: topology_fixture(
      "orchestrator-subagent-baseline", "orchestrator-subagent", "pattern-extraction",
      "derive-structural-fixture", "pkg-orchestrator-subagent-baseline", "v1", "topology/orchestrator-subagent-baseline",
      "https://claude.com/blog/multi-agent-coordination-patterns", "docs/discussions/2026-04-19-topology-defaults-and-test-asset-priority.md",
      "bounded subtask decomposition", "coordinator-to-worker handoff modeling",
      "final synthesis ownership", "model/provider choice stays outside topology",
      "worker session ids stay outside topology", "Best reusable baseline and likely first practical coordination shape for this repo.",
    ),
    generator_verifier_loop: topology_fixture(
      "generator-verifier-loop", "generator-verifier", "pattern-extraction", "derive-structural-fixture",
      "pkg-generator-verifier-loop", "v1", "topology/generator-verifier-loop", "https://claude.com/blog/multi-agent-coordination-patterns",
      "docs/discussions/2026-04-19-topology-defaults-and-test-asset-priority.md",
      "reviewer loop semantics", "retry and rejection termination", "explicit acceptance criteria attachment",
      "evaluator model tuning stays outside topology", "iteration counters and intermediate drafts stay outside topology",
      "Smallest crisp topology sample for evaluation loops and termination rules.",
    ),
    shared_state_research_slate: topology_fixture(
      "shared-state-research-slate", "shared-state", "pattern-extraction", "derive-structural-fixture",
      "pkg-shared-state-research-slate", "v1", "topology/shared-state-research-slate",
      "https://claude.com/blog/multi-agent-coordination-patterns", "docs/discussions/2026-04-19-synthesis-method-from-test-assets.md",
      "shared surface declaration", "agent read/write semantics", "convergence and stop conditions",
      "storage backend implementation stays outside topology", "live shared document contents stay outside topology",
      "Most directly stresses collaborative synthesis behavior and termination questions.",
    ),
    message_bus_event_routing: topology_fixture(
      "message-bus-event-routing", "message-bus", "pattern-extraction", "derive-structural-fixture",
      "pkg-message-bus-event-routing", "v1", "topology/message-bus-event-routing",
      "https://claude.com/blog/multi-agent-coordination-patterns", "docs/manifests/phase-0/mock-contract-manifest.yaml",
      "topic routing semantics", "publish/subscribe edge types", "event-driven activation entrypoints",
      "event transport implementation stays outside topology", "live event payloads and router buffers stay outside topology",
      "Aligns with runtime-event-stream and topology-activation mock boundaries.",
    ),
    agent_teams_partitioned_work: topology_fixture(
      "agent-teams-partitioned-work", "agent-teams", "pattern-extraction", "derive-structural-fixture",
      "pkg-agent-teams-partitioned-work", "v1", "topology/agent-teams-partitioned-work",
      "https://claude.com/blog/multi-agent-coordination-patterns", "docs/official-omx-usage.md",
      "persistent worker identity", "partition ownership boundaries", "completion aggregation",
      "per-worker runtime tuning stays outside topology", "worktree/session assignments stay outside topology",
      "Necessary to represent durable parallel execution rather than only bounded subagents.",
    ),
    custom_hybrid_composition: topology_fixture(
      "custom-hybrid-composition", "custom-hybrid", "synthetic-topology", "synthesize-from-primitives",
      "pkg-custom-hybrid-composition", "v1", "topology/custom-hybrid-composition",
      "docs/discussions/2026-04-19-topology-defaults-and-test-asset-priority.md",
      "docs/discussions/2026-04-19-test-assets-and-mock-boundaries.md", "mixed edge vocabulary",
      "template-plus-custom coexistence", "topology extensibility without schema breakage",
      "custom runtime wiring details stay outside topology", "one-off run context stays outside topology",
      "Captures the explicit requirement that users may go beyond the built-in pattern families.",
    ),
  }
}

///|
/// Stable key for fixture-level assertions in local tests.
pub fn skill_fixture_materialization_key(fixture : SkillFixture) -> String {
  "\{fixture.id}|\{fixture.asset_class}|\{fixture.capture_mode}|\{fixture.status}|\{fixture.file_count}|\{fixture.primary_path}|\{fixture.secondary_path}|\{fixture.tertiary_path}"
}

///|
/// Stable key for provenance fixture assertions in local tests.
pub fn provenance_fixture_materialization_key(
  fixture : ProvenanceFixture,
) -> String {
  "\{fixture.id}|\{fixture.asset_class}|\{fixture.capture_mode}|\{fixture.status}|\{fixture.metadata_path}|\{fixture.snapshot_ref}|\{fixture.durable_ref}"
}

///|
/// Stable key for topology-fixture assertions in local tests.
pub fn topology_fixture_materialization_key(
  fixture : TopologyFixture,
) -> String {
  "\{fixture.id}|\{fixture.pattern_family}|\{fixture.collection_mode}|\{fixture.status}|\{fixture.topology_ref}|\{fixture.validation_target_1}|\{fixture.validation_target_2}|\{fixture.validation_target_3}"
}

///|
/// Build a package manifest from a materialized skill fixture without changing the
/// existing package contract shapes.
pub fn fixture_package_manifest(
  fixture : SkillFixture,
  profile_ref : String,
  topology_ref : String,
  provenance_ref : String,
) -> @package.PackageManifest {
  @package.package_manifest(
    fixture.package_id,
    fixture.version,
    @package.skill_subject(fixture.skill_ref),
    profile_ref,
    topology_ref,
    provenance_ref,
  )
}

///|
/// Build a package manifest from a materialized topology fixture while keeping
/// runtime/provider concerns outside the topology package object.
pub fn topology_fixture_package_manifest(
  fixture : TopologyFixture,
  provenance_ref : String,
) -> @package.PackageManifest {
  @package.package_manifest(
    fixture.package_id,
    fixture.version,
    @package.topology_subject(fixture.topology_ref),
    "",
    "",
    provenance_ref,
  )
}

///|
/// Build one small topology-graph sample from a topology fixture so later work
/// can pressure-test topology assets without introducing runtime-owned state.
pub fn topology_fixture_graph_key(fixture : TopologyFixture) -> String {
  let session = @topology.session(fixture.id, "default", fixture.pattern_family)
  let channel = @topology.channel(
    "channel://\{fixture.topology_ref}",
    @topology.session_id_of(session),
    @topology.execution_channel_kind(),
  )
  let projection = @topology.projection(
    "projection://\{fixture.id}",
    @topology.channel_id_of(channel),
    fixture.validation_target_1,
  )
  let subscription = @topology.subscription(
    "observer://\{fixture.id}",
    @topology.channel_id_of(channel),
    fixture.validation_target_2,
    @topology.targeted_delivery(),
  )
  @topology.topology_graph_key(
    @topology.topology_graph(session, channel, projection, subscription),
  )
}

///|
/// Build durable checkpoint metadata from the materialized provenance fixture.
pub fn materialized_checkpoint_metadata(
  fixture : ProvenanceFixture,
) -> @provenance.CheckpointMetadata {
  @provenance.checkpoint_metadata(
    fixture.checkpoint_id,
    fixture.asset_id,
    fixture.branch,
    fixture.session_id,
    fixture.channel_id,
    fixture.projection_id,
    @provenance.snapshot_ref(fixture.snapshot_ref),
    @provenance.commit_ref(fixture.durable_ref),
    fixture.parent_checkpoint_id,
  )
}
