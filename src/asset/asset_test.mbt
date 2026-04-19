///|
test "skill assets and commits keep stable identifiers" {
  let skill = @asset.skill_asset(
    "coach-survival", "v1", "prefer intent-level guidance", "seed-corpus",
  )
  let commit = @asset.asset_commit(
    "commit-1",
    @asset.skill_commit_kind(),
    @asset.skill_asset_id(skill),
    "learned a reusable coaching patch",
  )

  inspect(@asset.skill_asset_id(skill), content="coach-survival@v1")
  inspect(@asset.commit_kind_name(commit), content="skill")
  inspect(@asset.commit_asset_id(commit), content="coach-survival@v1")
}

///|
test "checkpoint and story commit kinds remain semantic" {
  let checkpoint = @asset.asset_commit(
    "commit-2",
    @asset.checkpoint_commit_kind(),
    "save-42",
    "manual checkpoint",
  )
  let story = @asset.asset_commit(
    "commit-3",
    @asset.story_commit_kind(),
    "chapter-7",
    "narrative highlight",
  )

  inspect(@asset.commit_kind_name(checkpoint), content="checkpoint")
  inspect(@asset.commit_kind_name(story), content="story")
}
