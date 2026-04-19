///|
test "runtime contract string is stable" {
  inspect(
    @finall_start_100_commits.runtime_contract(),
    content="OMX orchestrates; MoonBit validates.",
  )
}

///|
test "proof slice summary ties the first packages together" {
  let summary = @finall_start_100_commits.proof_slice_summary()

  inspect(summary.session_key, content="hermes:default:exec-1")
  inspect(
    summary.graph_key,
    content="sessions=1;channels=1;projections=1;subscriptions=1;root=exec-1/channel-exec-1",
  )
  inspect(summary.projection_source, content="channel-exec-1")
  inspect(summary.control_targeted, content="true")
  inspect(summary.skill_id, content="story-distiller@v1")
  inspect(summary.commit_kind, content="skill")
  inspect(summary.lineage_branch, content="main")
  inspect(
    summary.provenance_key,
    content="story-distiller@v1|commit-skill-1|main|seed",
  )
  inspect(summary.adapter_channel_kind, content="execution")
}

///|
test "proof slice story is stable" {
  inspect(
    @finall_start_100_commits.proof_slice_story(),
    content="proof-slice[hermes:default:exec-1] graph=sessions=1;channels=1;projections=1;subscriptions=1;root=exec-1/channel-exec-1 asset=story-distiller@v1 commit=skill branch=main provenance=story-distiller@v1|commit-skill-1|main|seed channel=execution",
  )
}

///|
test "surface config falls back to the default route body" {
  let config = @finall_start_100_commits.parse_surface_config([])

  inspect(config.route_body, content="focus on story beats")
}

///|
test "surface config accepts a routed control override" {
  let config = @finall_start_100_commits.parse_surface_config([
    "--route-body", "hold on lineage review",
  ])

  inspect(config.route_body, content="hold on lineage review")
}

///|
test "thin surface snapshot exposes the phase 4 inspection checkpoints" {
  let snapshot = @finall_start_100_commits.thin_surface_snapshot(
    @finall_start_100_commits.default_surface_config(),
  )

  inspect(
    snapshot.package_summary,
    content="pkg-story-distiller@v1|skill|story-distiller@v1|profile/default|topology/story-loop|story-distiller@v1|commit-skill-1|main|seed",
  )
  inspect(snapshot.session_summary, content="hermes:default:exec-1")
  inspect(snapshot.channel_summary, content="channel-exec-1|execution|exec-1")
  inspect(
    snapshot.topology_summary,
    content="sessions=1;channels=1;projections=1;subscriptions=1;root=exec-1/channel-exec-1",
  )
  inspect(
    snapshot.projection_summary,
    content="projection-story-1|channel-exec-1|story-lane",
  )
  inspect(
    snapshot.lineage_summary,
    content="story-distiller@v1|commit-skill-1|main|seed",
  )
  inspect(
    snapshot.capture_summary,
    content="capture://hermes|exec-1|channel-exec-1|skill-export-requested|payload://checkpoint-1/story-distiller|default|checkpoint-1|commit-9",
  )
  inspect(
    snapshot.control_summary,
    content="projection:projection-story-1|focus on story beats|10|true",
  )
  inspect(
    snapshot.export_summary,
    content="pkg-story-distiller@v1|skill|story-distiller@v1|profile/default|topology/story-loop|story-distiller@v1|commit-skill-1|main|seed|Story Distiller|export://packages/pkg-story-distiller/v1|checkpoint-1|commit-9",
  )
}

///|
test "thin surface report carries a custom routed control body" {
  inspect(
    @finall_start_100_commits.thin_surface_report(
      @finall_start_100_commits.surface_config("pause on lineage review"),
    ),
    content="package=pkg-story-distiller@v1|skill|story-distiller@v1|profile/default|topology/story-loop|story-distiller@v1|commit-skill-1|main|seed\nsession=hermes:default:exec-1\nchannel=channel-exec-1|execution|exec-1\ntopology=sessions=1;channels=1;projections=1;subscriptions=1;root=exec-1/channel-exec-1\nprojection=projection-story-1|channel-exec-1|story-lane\nlineage=story-distiller@v1|commit-skill-1|main|seed\ncapture=capture://hermes|exec-1|channel-exec-1|skill-export-requested|payload://checkpoint-1/story-distiller|default|checkpoint-1|commit-9\ncontrol=projection:projection-story-1|pause on lineage review|10|true\nexport=pkg-story-distiller@v1|skill|story-distiller@v1|profile/default|topology/story-loop|story-distiller@v1|commit-skill-1|main|seed|Story Distiller|export://packages/pkg-story-distiller/v1|checkpoint-1|commit-9",
  )
}
