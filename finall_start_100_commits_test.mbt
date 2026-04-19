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
