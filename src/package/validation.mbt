///|
/// Validation stays boundary-oriented so CEP-1 can freeze semantics separately.
pub enum ValidationBoundary {
  PublicShape
  RuntimeCompatibility
  ProvenanceLinkage
}

///|
/// Public constructor for the public-format validation boundary.
pub fn public_shape_boundary() -> ValidationBoundary {
  PublicShape
}

///|
/// Public constructor for the runtime-compatibility validation boundary.
pub fn runtime_compatibility_boundary() -> ValidationBoundary {
  RuntimeCompatibility
}

///|
/// Public constructor for the provenance-linkage validation boundary.
pub fn provenance_linkage_boundary() -> ValidationBoundary {
  ProvenanceLinkage
}

///|
/// Stable name for reporting which boundary is being checked.
pub fn validation_boundary_name(boundary : ValidationBoundary) -> String {
  match boundary {
    PublicShape => "public-shape"
    RuntimeCompatibility => "runtime-compatibility"
    ProvenanceLinkage => "provenance-linkage"
  }
}

///|
/// Check whether a manifest satisfies one frozen validation boundary.
pub fn validate_manifest_boundary(
  manifest : PackageManifest,
  boundary : ValidationBoundary,
) -> Bool {
  match boundary {
    PublicShape =>
      manifest.package_id != "" &&
      manifest.version != "" &&
      package_subject_ref(manifest.subject) != ""
    RuntimeCompatibility =>
      match manifest.subject {
        Skill(_) => manifest.profile_ref != "" && manifest.topology_ref != ""
        Profile(_) => manifest.topology_ref != ""
        Topology(_) => true
      }
    ProvenanceLinkage => manifest.provenance_ref != ""
  }
}

///|
/// The first-proof loop requires every boundary to pass before export/import.
pub fn manifest_is_valid(manifest : PackageManifest) -> Bool {
  validate_manifest_boundary(manifest, PublicShape) &&
  validate_manifest_boundary(manifest, RuntimeCompatibility) &&
  validate_manifest_boundary(manifest, ProvenanceLinkage)
}
