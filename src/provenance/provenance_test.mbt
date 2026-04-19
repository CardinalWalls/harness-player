///|
test "provenance models lineage semantics without git cli coupling" {
  let root = @provenance.root_lineage_node("skill-1", "main")
  let child = @provenance.child_lineage_node("skill-2", "main", "skill-1")
  let graph = @provenance.history_graph("skill-2", "main", 2)
  let branch_ref = @provenance.branch_ref("main")

  inspect(@provenance.has_parent(root), content="false")
  inspect(@provenance.has_parent(child), content="true")
  inspect(@provenance.graph_node_count(graph), content="2")
  inspect(@provenance.lineage_ref_value(branch_ref), content="main")
  inspect(@provenance.is_branch_ref(branch_ref), content="true")
}

///|
test "provenance refs support commit and snapshot variants" {
  let commit_ref = @provenance.commit_ref("commit-1")
  let snapshot_ref = @provenance.snapshot_ref("snapshot-1")

  inspect(@provenance.lineage_ref_value(commit_ref), content="commit-1")
  inspect(@provenance.lineage_ref_value(snapshot_ref), content="snapshot-1")
  inspect(@provenance.is_branch_ref(commit_ref), content="false")
}

///|
test "provenance records link asset commits to lineage nodes" {
  let commit = @asset.asset_commit(
    "commit-1",
    @asset.skill_commit_kind(),
    "story-distiller@v1",
    "captured a skill asset",
  )
  let lineage = @provenance.child_lineage_node("commit-1", "main", "seed")
  let record = @provenance.provenance_record(commit, lineage)

  inspect(
    @provenance.provenance_record_key(record),
    content="story-distiller@v1|commit-1|main|seed",
  )
}

///|
test "checkpoint metadata links capture surfaces to durable lineage refs" {
  let metadata = @provenance.checkpoint_metadata(
    "checkpoint-1",
    "coach-survival@v1",
    "main",
    "session-1",
    "channel-1",
    "projection-1",
    @provenance.snapshot_ref("snapshot-1"),
    @provenance.commit_ref("commit-9"),
    "checkpoint-0",
  )

  inspect(
    @provenance.checkpoint_metadata_key(metadata),
    content="checkpoint-1|coach-survival@v1|main|session-1|channel-1|projection-1|snapshot-1|commit-9|checkpoint-0",
  )
  inspect(@provenance.checkpoint_has_parent(metadata), content="true")
}

///|
test "checkpoint materialization keeps provenance on the MoonBit-native Git path" {
  let commit = @asset.asset_commit(
    "commit-9",
    @asset.checkpoint_commit_kind(),
    "coach-survival@v1",
    "saved a durable checkpoint",
  )
  let lineage = @provenance.child_lineage_node("commit-9", "main", "commit-8")
  let metadata = @provenance.checkpoint_metadata(
    "checkpoint-9",
    "coach-survival@v1",
    "main",
    "session-9",
    "channel-9",
    "projection-9",
    @provenance.snapshot_ref("snapshot-9"),
    @provenance.commit_ref("commit-9"),
    "checkpoint-8",
  )
  let materialized = @provenance.materialize_checkpoint(
    commit, lineage, metadata,
  )

  inspect(
    @provenance.materialized_checkpoint_key(materialized),
    content="coach-survival@v1|commit-9|main|commit-8|checkpoint-9|coach-survival@v1|main|session-9|channel-9|projection-9|snapshot-9|commit-9|checkpoint-8|metadata-branch-write|moonbit-native|commit-9",
  )
}

///|
test "host bridge sync routes to compatibility fallback explicitly" {
  let route = @provenance.route_materialization(
    @provenance.host_bridge_sync_operation(),
  )

  inspect(
    @provenance.materialization_operation_name(route.operation),
    content="host-bridge-sync",
  )
  inspect(
    @provenance.git_backend_name(route.backend),
    content="compatibility-fallback",
  )
  inspect(@provenance.route_uses_fallback(route), content="true")
}
