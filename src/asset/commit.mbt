///|
/// Durable asset commits stay semantic even if the provenance substrate changes.
pub enum CommitKind {
  Checkpoint
  Story
  Skill
}

///|
/// Minimal asset commit record that can be attached to lineage metadata.
pub struct AssetCommit {
  id : String
  kind : CommitKind
  asset_id : String
  summary : String
}

///|
/// Construct a durable asset commit.
pub fn asset_commit(
  id : String,
  kind : CommitKind,
  asset_id : String,
  summary : String,
) -> AssetCommit {
  { id, kind, asset_id, summary }
}

///|
/// Return the kind of a commit as a stable string for logs and tests.
pub fn commit_kind_name(commit : AssetCommit) -> String {
  match commit.kind {
    Checkpoint => "checkpoint"
    Story => "story"
    Skill => "skill"
  }
}

///|
/// Return the asset id linked to a durable commit.
pub fn commit_asset_id(commit : AssetCommit) -> String {
  commit.asset_id
}

///|
/// Public constructor for a skill-oriented commit kind.
pub fn skill_commit_kind() -> CommitKind {
  Skill
}

///|
/// Public constructor for checkpoint-oriented commit kinds.
pub fn checkpoint_commit_kind() -> CommitKind {
  Checkpoint
}

///|
/// Public constructor for story-oriented commit kinds.
pub fn story_commit_kind() -> CommitKind {
  Story
}
