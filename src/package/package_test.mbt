///|
test "package manifest represents the first skill bundle contract" {
  let manifest = @package.package_manifest(
    "pkg-coach-survival",
    "v1",
    @package.skill_subject("coach-survival@v1"),
    "profile/default",
    "topology/story-loop",
    "commit-1",
  )

  inspect(@package.package_subject_kind_name(manifest.subject), content="skill")
  inspect(
    @package.package_manifest_key(manifest),
    content="pkg-coach-survival@v1|skill|coach-survival@v1|profile/default|topology/story-loop|commit-1",
  )
  inspect(
    @package.validation_boundary_name(@package.public_shape_boundary()),
    content="public-shape",
  )
  inspect(
    @package.validate_manifest_boundary(
      manifest,
      @package.public_shape_boundary(),
    ),
    content="true",
  )
  inspect(
    @package.validate_manifest_boundary(
      manifest,
      @package.runtime_compatibility_boundary(),
    ),
    content="true",
  )
  inspect(
    @package.validate_manifest_boundary(
      manifest,
      @package.provenance_linkage_boundary(),
    ),
    content="true",
  )
  inspect(@package.manifest_is_valid(manifest), content="true")
}

///|
test "profile and topology package subjects remain representable" {
  let profile_manifest = @package.package_manifest(
    "pkg-default-profile",
    "v1",
    @package.profile_subject("profile/default"),
    "",
    "topology/story-loop",
    "commit-2",
  )
  let topology_manifest = @package.package_manifest(
    "pkg-story-loop",
    "v1",
    @package.topology_subject("topology/story-loop"),
    "",
    "",
    "commit-3",
  )

  inspect(
    @package.package_subject_kind_name(profile_manifest.subject),
    content="profile",
  )
  inspect(
    @package.package_subject_kind_name(topology_manifest.subject),
    content="topology",
  )
  inspect(@package.manifest_is_valid(profile_manifest), content="true")
  inspect(@package.manifest_is_valid(topology_manifest), content="true")
}

///|
test "validation boundaries fail cleanly for malformed manifests" {
  let manifest = @package.package_manifest(
    "",
    "v1",
    @package.skill_subject(""),
    "",
    "",
    "",
  )

  inspect(
    @package.validate_manifest_boundary(
      manifest,
      @package.public_shape_boundary(),
    ),
    content="false",
  )
  inspect(
    @package.validate_manifest_boundary(
      manifest,
      @package.runtime_compatibility_boundary(),
    ),
    content="false",
  )
  inspect(
    @package.validate_manifest_boundary(
      manifest,
      @package.provenance_linkage_boundary(),
    ),
    content="false",
  )
  inspect(@package.manifest_is_valid(manifest), content="false")
}

///|
test "shareable package objects carry export metadata without runtime payload state" {
  let manifest = @package.package_manifest(
    "pkg-coach-survival",
    "v2",
    @package.skill_subject("coach-survival@v2"),
    "profile/default",
    "topology/story-loop",
    "commit-9",
  )
  let bundle = @package.shareable_package(
    manifest,
    "Coach Survival",
    "export://packages/pkg-coach-survival/v2",
    "checkpoint-9",
    @provenance.commit_ref("commit-9"),
  )

  inspect(
    @package.shareable_package_key(bundle),
    content="pkg-coach-survival@v2|skill|coach-survival@v2|profile/default|topology/story-loop|commit-9|Coach Survival|export://packages/pkg-coach-survival/v2|checkpoint-9|commit-9",
  )
  inspect(@package.shareable_package_subject_kind(bundle), content="skill")
  inspect(@package.shareable_package_durable_ref(bundle), content="commit-9")
  inspect(@package.shareable_package_is_valid(bundle), content="true")

  match @package.imported_manifest(bundle) {
    Some(imported) =>
      inspect(
        @package.package_manifest_key(imported),
        content="pkg-coach-survival@v2|skill|coach-survival@v2|profile/default|topology/story-loop|commit-9",
      )
    None => fail("expected shareable package import to succeed")
  }
}

///|
test "shareable package validation rejects missing export linkage" {
  let bundle = @package.shareable_package(
    @package.package_manifest(
      "pkg-default-profile",
      "v1",
      @package.profile_subject("profile/default"),
      "",
      "topology/story-loop",
      "commit-1",
    ),
    "",
    "",
    "",
    @provenance.commit_ref(""),
  )

  inspect(@package.shareable_package_is_valid(bundle), content="false")
}
