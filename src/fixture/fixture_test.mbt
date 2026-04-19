///|
test "first-wave corpus preserves the six approved fixture ids locally" {
  let corpus = @fixture.first_wave_corpus()

  inspect(@fixture.first_wave_fixture_count(), content="12")
  inspect(
    @fixture.first_wave_fixture_ids(),
    content="skill-template-minimal|algorithmic-art-minimal-real|pdf-reference-rich|slack-gif-creator-dependency|theme-factory-static-asset|entire-checkpoint-metadata|orchestrator-subagent-baseline|generator-verifier-loop|shared-state-research-slate|message-bus-event-routing|agent-teams-partitioned-work|custom-hybrid-composition",
  )
  inspect(corpus.skill_template_minimal.status, content="approved-first-wave")
  inspect(
    corpus.algorithmic_art_minimal_real.status,
    content="approved-first-wave",
  )
  inspect(corpus.pdf_reference_rich.status, content="approved-first-wave")
  inspect(
    corpus.slack_gif_creator_dependency.status,
    content="approved-first-wave",
  )
  inspect(
    corpus.theme_factory_static_asset.status,
    content="approved-first-wave",
  )
  inspect(
    corpus.entire_checkpoint_metadata.status,
    content="approved-first-wave",
  )
  inspect(
    corpus.orchestrator_subagent_baseline.status,
    content="approved-first-wave",
  )
  inspect(corpus.generator_verifier_loop.status, content="approved-first-wave")
  inspect(
    corpus.shared_state_research_slate.status,
    content="approved-first-wave",
  )
  inspect(
    corpus.message_bus_event_routing.status,
    content="approved-first-wave",
  )
  inspect(
    corpus.agent_teams_partitioned_work.status,
    content="approved-first-wave",
  )
  inspect(
    corpus.custom_hybrid_composition.status,
    content="approved-first-wave",
  )
}

///|
test "skill fixtures keep representative local layouts for validation pressure" {
  let corpus = @fixture.first_wave_corpus()

  inspect(
    @fixture.skill_fixture_materialization_key(corpus.skill_template_minimal),
    content="skill-template-minimal|canonical-skill|mirror-selected-file|approved-first-wave|1|skill-template-minimal/SKILL.md||",
  )
  inspect(
    @fixture.skill_fixture_materialization_key(corpus.pdf_reference_rich),
    content="pdf-reference-rich|reference-rich-skill|mirror-folder-subset|approved-first-wave|3|pdf-reference-rich/SKILL.md|pdf-reference-rich/forms.md|pdf-reference-rich/reference.md",
  )
  inspect(
    corpus.slack_gif_creator_dependency.secondary_path,
    content="slack-gif-creator-dependency/requirements.txt",
  )
  inspect(
    corpus.slack_gif_creator_dependency.secondary_body,
    content="Pillow==10.4.0\nslack-sdk==3.31.0\n",
  )
  inspect(
    corpus.theme_factory_static_asset.secondary_body,
    content="%PDF-1.4\n% fixture theme showcase\n1 0 obj\n<< /Type /Catalog >>\nendobj\ntrailer\n<<>>\n%%EOF\n",
  )
}

///|
test "fixture skill manifests stay compatible with the current package contract" {
  let corpus = @fixture.first_wave_corpus()
  let manifest = @fixture.fixture_package_manifest(
    corpus.skill_template_minimal,
    "profile/default",
    "topology/fixture-corpus",
    "fixture/skill-template-minimal",
  )

  inspect(
    @package.package_manifest_key(manifest),
    content="pkg-skill-template-minimal@v1|skill|skill-template-minimal@v1|profile/default|topology/fixture-corpus|fixture/skill-template-minimal",
  )
  inspect(@package.manifest_is_valid(manifest), content="true")
}

///|
test "provenance fixture yields durable checkpoint metadata without network access" {
  let corpus = @fixture.first_wave_corpus()
  let metadata = @fixture.materialized_checkpoint_metadata(
    corpus.entire_checkpoint_metadata,
  )

  inspect(
    @fixture.provenance_fixture_materialization_key(
      corpus.entire_checkpoint_metadata,
    ),
    content="entire-checkpoint-metadata|provenance-metadata-sample|derive-metadata-fixture|approved-first-wave|entire-checkpoint-metadata/checkpoint-metadata.json|snapshot-entire-1|commit-entire-9",
  )
  inspect(
    @provenance.checkpoint_metadata_key(metadata),
    content="checkpoint-entire-1|skill-template-minimal@v1|main|session-entire-1|channel-entire-1|projection-entire-1|snapshot-entire-1|commit-entire-9|checkpoint-entire-0",
  )
  inspect(@provenance.checkpoint_has_parent(metadata), content="true")
}

///|
test "topology fixtures preserve first-wave structural defaults locally" {
  let corpus = @fixture.first_wave_corpus()

  inspect(
    @fixture.topology_fixture_materialization_key(
      corpus.orchestrator_subagent_baseline,
    ),
    content="orchestrator-subagent-baseline|orchestrator-subagent|derive-structural-fixture|approved-first-wave|topology/orchestrator-subagent-baseline|bounded subtask decomposition|coordinator-to-worker handoff modeling|final synthesis ownership",
  )
  inspect(
    @fixture.topology_fixture_materialization_key(
      corpus.custom_hybrid_composition,
    ),
    content="custom-hybrid-composition|custom-hybrid|synthesize-from-primitives|approved-first-wave|topology/custom-hybrid-composition|mixed edge vocabulary|template-plus-custom coexistence|topology extensibility without schema breakage",
  )
}

///|
test "topology fixtures remain compatible with topology package subjects" {
  let corpus = @fixture.first_wave_corpus()
  let manifest = @fixture.topology_fixture_package_manifest(
    corpus.message_bus_event_routing,
    "fixture/message-bus-event-routing",
  )

  inspect(
    @package.package_manifest_key(manifest),
    content="pkg-message-bus-event-routing@v1|topology|topology/message-bus-event-routing|||fixture/message-bus-event-routing",
  )
  inspect(@package.manifest_is_valid(manifest), content="true")
}

///|
test "topology fixtures derive graph keys without runtime-owned state" {
  let corpus = @fixture.first_wave_corpus()

  inspect(
    @fixture.topology_fixture_graph_key(corpus.agent_teams_partitioned_work),
    content="sessions=1;channels=1;projections=1;subscriptions=1;root=agent-teams-partitioned-work/channel://topology/agent-teams-partitioned-work",
  )
  inspect(
    @fixture.topology_fixture_graph_key(corpus.shared_state_research_slate),
    content="sessions=1;channels=1;projections=1;subscriptions=1;root=shared-state-research-slate/channel://topology/shared-state-research-slate",
  )
}
