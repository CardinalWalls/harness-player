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
  inspect(
    config.report_mode,
    content=@finall_start_100_commits.summary_report_mode(),
  )
}

///|
test "surface config accepts a routed control override" {
  let config = @finall_start_100_commits.parse_surface_config([
    "--route-body", "hold on lineage review",
  ])

  inspect(config.route_body, content="hold on lineage review")
  inspect(
    config.report_mode,
    content=@finall_start_100_commits.summary_report_mode(),
  )
}

///|
test "surface config accepts the materialized export report mode" {
  let config = @finall_start_100_commits.parse_surface_config([
    "--route-body", "pause on lineage review", "--report-mode", "materialized-export",
  ])

  inspect(config.route_body, content="pause on lineage review")
  inspect(
    config.report_mode,
    content=@finall_start_100_commits.materialized_export_report_mode(),
  )
}

///|
test "surface config accepts the persisted export flag" {
  let config = @finall_start_100_commits.parse_surface_config([
    "--report-mode", "materialized-export", "--write-export",
  ])

  inspect(config.write_export, content="true")
  inspect(
    @finall_start_100_commits.should_write_materialized_export(config),
    content="true",
  )
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

///|
test "materialized export snapshot exposes the deeper export path" {
  let snapshot = @finall_start_100_commits.materialized_export_snapshot(
    @finall_start_100_commits.surface_config_with_mode(
      "pause on lineage review", "materialized-export",
    ),
  )

  inspect(
    snapshot.package_summary,
    content="pkg-story-distiller@v1|skill|story-distiller@v1|profile/default|topology/story-loop|story-distiller@v1|commit-skill-1|main|seed",
  )
  inspect(
    snapshot.control_summary,
    content="projection:projection-story-1|pause on lineage review|10|true",
  )
  inspect(
    snapshot.export_summary,
    content="pkg-story-distiller@v1|skill|story-distiller@v1|profile/default|topology/story-loop|story-distiller@v1|commit-skill-1|main|seed|Story Distiller|export://packages/pkg-story-distiller/v1|checkpoint-1|commit-9",
  )
  inspect(
    snapshot.checkpoint_summary,
    content="checkpoint-1|story-distiller@v1|main|exec-1|channel-exec-1|projection-story-1|snapshot-1|commit-9|checkpoint-0",
  )
  inspect(
    snapshot.capture_summary,
    content="capture://hermes|exec-1|channel-exec-1|skill-export-requested|payload://checkpoint-1/story-distiller|default|checkpoint-1|commit-9",
  )
  inspect(
    snapshot.materialization_summary,
    content="package-export-write|moonbit-native|package export writing remains on the MoonBit-native path by default",
  )
  inspect(
    snapshot.payload_summary,
    content="available|blob://available/payload://checkpoint-1/story-distiller|true|durable://checkpoint/checkpoint-1/lineage/commit-9",
  )
  inspect(
    snapshot.registry_summary,
    content="pkg-story-distiller|v1|Story distiller skill bundle for the proof slice.",
  )
  inspect(
    snapshot.manifest_summary,
    content="mock://registry/pkg-story-distiller/v1/manifest|sha256:mock-story-distiller-v1",
  )
  inspect(
    snapshot.activation_summary,
    content="activation://story-distiller@v1|profile/default|topology/story-loop|sessions=1;channels=1;projections=1;subscriptions=1;root=activation://story-distiller@v1|profile/default|topology/story-loop/channel://topology/story-loop",
  )
  inspect(
    snapshot.surface_summary,
    content="channels=2|activation://story-distiller@v1|profile/default|topology/story-loop#execution:1|activation://story-distiller@v1|profile/default|topology/story-loop#control:0|controls=2|inspect:inspect-visible-surfaces|export:request-export",
  )
}

///|
test "surface report switches to the materialized export mode" {
  inspect(
    @finall_start_100_commits.surface_report(
      @finall_start_100_commits.surface_config_with_mode(
        "pause on lineage review", "materialized-export",
      ),
    ),
    content="package=pkg-story-distiller@v1|skill|story-distiller@v1|profile/default|topology/story-loop|story-distiller@v1|commit-skill-1|main|seed\ncontrol=projection:projection-story-1|pause on lineage review|10|true\nexport=pkg-story-distiller@v1|skill|story-distiller@v1|profile/default|topology/story-loop|story-distiller@v1|commit-skill-1|main|seed|Story Distiller|export://packages/pkg-story-distiller/v1|checkpoint-1|commit-9\ncheckpoint=checkpoint-1|story-distiller@v1|main|exec-1|channel-exec-1|projection-story-1|snapshot-1|commit-9|checkpoint-0\ncapture=capture://hermes|exec-1|channel-exec-1|skill-export-requested|payload://checkpoint-1/story-distiller|default|checkpoint-1|commit-9\nmaterialization=package-export-write|moonbit-native|package export writing remains on the MoonBit-native path by default\npayload=available|blob://available/payload://checkpoint-1/story-distiller|true|durable://checkpoint/checkpoint-1/lineage/commit-9\nregistry=pkg-story-distiller|v1|Story distiller skill bundle for the proof slice.\nmanifest=mock://registry/pkg-story-distiller/v1/manifest|sha256:mock-story-distiller-v1\nactivation=activation://story-distiller@v1|profile/default|topology/story-loop|sessions=1;channels=1;projections=1;subscriptions=1;root=activation://story-distiller@v1|profile/default|topology/story-loop/channel://topology/story-loop\nsurface=channels=2|activation://story-distiller@v1|profile/default|topology/story-loop#execution:1|activation://story-distiller@v1|profile/default|topology/story-loop#control:0|controls=2|inspect:inspect-visible-surfaces|export:request-export",
  )
}

///|
test "persisted export uses the repo-local default path" {
  inspect(
    @finall_start_100_commits.materialized_export_file_name(
      @finall_start_100_commits.with_export_write(
        @finall_start_100_commits.surface_config_with_mode(
          "pause on lineage review", "materialized-export",
        ),
      ),
    ),
    content="pkg-story-distiller-v1-checkpoint-1.txt",
  )
  inspect(
    @finall_start_100_commits.persisted_materialized_export_key(
      @finall_start_100_commits.planned_materialized_export(
        "artifacts/materialized-exports/test-proof.txt",
        @finall_start_100_commits.with_export_write(
          @finall_start_100_commits.surface_config_with_mode(
            "pause on lineage review", "materialized-export",
          ),
        ),
      ),
    ),
    content="artifacts/materialized-exports/test-proof.txt|checkpoint-1|export://packages/pkg-story-distiller/v1|commit-9",
  )
}

///|
test "persisted materialized export plan carries the current report body" {
  let config = @finall_start_100_commits.with_export_write(
    @finall_start_100_commits.surface_config_with_mode(
      "pause on lineage review", "materialized-export",
    ),
  )
  let persisted = @finall_start_100_commits.planned_materialized_export(
    "artifacts/materialized-exports/pkg-story-distiller-v1-checkpoint-1.txt", config,
  )

  inspect(
    @finall_start_100_commits.persisted_materialized_export_key(persisted),
    content="artifacts/materialized-exports/pkg-story-distiller-v1-checkpoint-1.txt|checkpoint-1|export://packages/pkg-story-distiller/v1|commit-9",
  )
  inspect(
    persisted.report_body,
    content=@finall_start_100_commits.materialized_export_report(config),
  )
}
