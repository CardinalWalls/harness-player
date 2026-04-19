///|
/// Checkpoint metadata records the durable summary while leaving runtime-owned
/// payload bytes outside the exported package contract.
pub struct CheckpointMetadata {
  checkpoint_id : String
  asset_id : String
  branch : String
  session_id : @topology.SessionId
  channel_id : @topology.ChannelId
  projection_id : @topology.ProjectionId
  snapshot_ref : LineageRef
  durable_ref : LineageRef
  parent_checkpoint_id : String
}

///|
/// Construct the first durable checkpoint metadata model.
pub fn checkpoint_metadata(
  checkpoint_id : String,
  asset_id : String,
  branch : String,
  session_id : @topology.SessionId,
  channel_id : @topology.ChannelId,
  projection_id : @topology.ProjectionId,
  snapshot_ref : LineageRef,
  durable_ref : LineageRef,
  parent_checkpoint_id : String,
) -> CheckpointMetadata {
  {
    checkpoint_id,
    asset_id,
    branch,
    session_id,
    channel_id,
    projection_id,
    snapshot_ref,
    durable_ref,
    parent_checkpoint_id,
  }
}

///|
/// Stable key for assertions and export/import traces.
pub fn checkpoint_metadata_key(metadata : CheckpointMetadata) -> String {
  "\{metadata.checkpoint_id}|\{metadata.asset_id}|\{metadata.branch}|\{metadata.session_id}|\{metadata.channel_id}|\{metadata.projection_id}|\{lineage_ref_value(metadata.snapshot_ref)}|\{lineage_ref_value(metadata.durable_ref)}|\{metadata.parent_checkpoint_id}"
}

///|
/// Whether the checkpoint metadata has an explicit parent link.
pub fn checkpoint_has_parent(metadata : CheckpointMetadata) -> Bool {
  metadata.parent_checkpoint_id != ""
}
