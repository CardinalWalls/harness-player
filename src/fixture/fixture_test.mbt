///|
test "first-wave corpus preserves the six approved fixture ids locally" {
  let corpus = @fixture.first_wave_corpus()

  inspect(@fixture.first_wave_fixture_count(), content="6")
  inspect(
    @fixture.first_wave_fixture_ids(),
    content="skill-template-minimal|algorithmic-art-minimal-real|pdf-reference-rich|slack-gif-creator-dependency|theme-factory-static-asset|entire-checkpoint-metadata",
  )
  inspect(corpus.skill_template_minimal.status, content="approved-first-wave")
  inspect(corpus.algorithmic_art_minimal_real.status, content="approved-first-wave")
  inspect(corpus.pdf_reference_rich.status, content="approved-first-wave")
  inspect(corpus.slack_gif_creator_dependency.status, content="approved-first-wave")
  inspect(corpus.theme_factory_static_asset.status, content="approved-first-wave")
  inspect(corpus.entire_checkpoint_metadata.status, content="approved-first-wave")
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
