///|
/// Lineage references encode semantic relationships instead of substrate-specific commands.
pub enum LineageRef {
  Commit(String)
  Branch(String)
  Snapshot(String)
}

///|
/// Return the stable value stored by a lineage reference.
pub fn lineage_ref_value(reference : LineageRef) -> String {
  match reference {
    Commit(value) => value
    Branch(value) => value
    Snapshot(value) => value
  }
}

///|
/// Whether the reference points to a branch boundary.
pub fn is_branch_ref(reference : LineageRef) -> Bool {
  match reference {
    Branch(_) => true
    _ => false
  }
}

///|
/// Public constructor for branch-oriented lineage refs.
pub fn branch_ref(value : String) -> LineageRef {
  Branch(value)
}

///|
/// Public constructor for commit-oriented lineage refs.
pub fn commit_ref(value : String) -> LineageRef {
  Commit(value)
}

///|
/// Public constructor for snapshot-oriented lineage refs.
pub fn snapshot_ref(value : String) -> LineageRef {
  Snapshot(value)
}
