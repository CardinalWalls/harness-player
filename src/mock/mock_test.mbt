///|
test "mock share registry discovers first-wave seeded packages" {
  let registry = @mock.first_wave_share_registry()
  let matches = @mock.discover_packages(registry, "story", [
    @mock.skill_kind(),
    @mock.topology_kind(),
  ])

  inspect(matches.length(), content="2")
  inspect(matches[0].package_id, content="pkg-story-distiller")
  inspect(matches[0].latest_version, content="v1")
  inspect(matches[1].package_id, content="pkg-story-loop")
}

///|
test "mock share registry fetches exact manifest metadata" {
  let registry = @mock.first_wave_share_registry()
  let manifest = @mock.fetch_manifest(registry, "pkg-default-profile", "v1")

  match manifest {
    Some(found) => {
      inspect(
        found.manifest_ref,
        content="mock://registry/pkg-default-profile/v1/manifest",
      )
      inspect(found.integrity_hash, content="sha256:mock-default-profile-v1")
    }
    None => fail("expected seeded manifest lookup to succeed")
  }
}

///|
test "mock checkpoint blob backend resolves availability and lineage attachment" {
  let backend = @mock.first_wave_checkpoint_blob_backend()
  let resolved = @mock.resolve_payload_ref(
    backend, "payload://checkpoint-1/story-distiller",
  )
  let missing = @mock.resolve_payload_ref(
    backend, "payload://checkpoint-9/unknown",
  )
  let attachment = @mock.attach_lineage_metadata(
    backend, "checkpoint-1", "commit-9",
  )

  inspect(resolved.availability, content="available")
  inspect(
    resolved.blob_id,
    content="blob://available/payload://checkpoint-1/story-distiller",
  )
  inspect(missing.availability, content="missing")
  inspect(attachment.attached, content="true")
  inspect(
    attachment.durable_ref,
    content="durable://checkpoint/checkpoint-1/lineage/commit-9",
  )
}

///|
test "mock topology activation derives a graph ref and visible control surface" {
  let activation = @mock.first_wave_topology_activation()
  let loaded = @mock.load_bundle(
    activation, "story-distiller@v1", "profile/default", "topology/story-loop",
  )
  let surfaces = @mock.inspect_visible_surfaces(
    activation,
    loaded.activation_id,
  )

  inspect(
    loaded.activation_id,
    content="activation://story-distiller@v1|profile/default|topology/story-loop",
  )
  inspect(
    loaded.channel_graph_ref,
    content="sessions=1;channels=1;projections=1;subscriptions=1;root=activation://story-distiller@v1|profile/default|topology/story-loop/channel://topology/story-loop",
  )
  inspect(surfaces.channels.length(), content="2")
  inspect(surfaces.channels[0].projection_count, content="1")
  inspect(surfaces.control_entries[1].action, content="request-export")
}
