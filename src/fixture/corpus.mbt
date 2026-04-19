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
/// The locally materialized first-wave fixture set from the frozen corpus manifest.
pub struct FirstWaveCorpus {
  skill_template_minimal : SkillFixture
  algorithmic_art_minimal_real : SkillFixture
  pdf_reference_rich : SkillFixture
  slack_gif_creator_dependency : SkillFixture
  theme_factory_static_asset : SkillFixture
  entire_checkpoint_metadata : ProvenanceFixture
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
/// Stable summary of the approved first-wave ids preserved in local fixtures.
pub fn first_wave_fixture_ids() -> String {
  "skill-template-minimal|algorithmic-art-minimal-real|pdf-reference-rich|slack-gif-creator-dependency|theme-factory-static-asset|entire-checkpoint-metadata"
}

///|
/// The frozen first-wave fixture count.
pub fn first_wave_fixture_count() -> Int {
  6
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
