///|
/// Provenance owns the relationship between asset commits and lineage nodes.
pub struct ProvenanceRecord {
  asset_id : String
  commit_id : String
  branch : String
  lineage_parent : String
}

///|
/// Build a provenance record from a durable asset commit and lineage node.
pub fn provenance_record(
  commit : @asset.AssetCommit,
  lineage : LineageNode,
) -> ProvenanceRecord {
  {
    asset_id: @asset.commit_asset_id(commit),
    commit_id: lineage.id,
    branch: lineage.branch,
    lineage_parent: lineage.parent_id,
  }
}

///|
/// Stable key for linkage-level assertions and proof summaries.
pub fn provenance_record_key(record : ProvenanceRecord) -> String {
  "\{record.asset_id}|\{record.commit_id}|\{record.branch}|\{record.lineage_parent}"
}
