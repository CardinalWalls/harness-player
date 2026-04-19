///|
/// A durable, shareable skill asset produced by the control plane.
pub struct SkillAsset {
  name : String
  version : String
  body : String
  source : String
}

///|
/// Construct a skill asset from durable metadata.
pub fn skill_asset(
  name : String,
  version : String,
  body : String,
  source : String,
) -> SkillAsset {
  { name, version, body, source }
}

///|
/// Stable identifier for skill-oriented provenance and commits.
pub fn skill_asset_id(asset : SkillAsset) -> String {
  "\{asset.name}@\{asset.version}"
}
