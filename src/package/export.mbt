///|
/// A shareable package keeps export-facing metadata separate from runtime state.
pub struct ShareablePackage {
  manifest : PackageManifest
  display_name : String
  export_ref : String
  checkpoint_id : String
  durable_ref : @provenance.LineageRef
}

///|
/// Construct a first-wave shareable package object for export/import flows.
pub fn shareable_package(
  manifest : PackageManifest,
  display_name : String,
  export_ref : String,
  checkpoint_id : String,
  durable_ref : @provenance.LineageRef,
) -> ShareablePackage {
  { manifest, display_name, export_ref, checkpoint_id, durable_ref }
}

///|
/// Stable key for export/import assertions.
pub fn shareable_package_key(bundle : ShareablePackage) -> String {
  "\{package_manifest_key(bundle.manifest)}|\{bundle.display_name}|\{bundle.export_ref}|\{bundle.checkpoint_id}|\{@provenance.lineage_ref_value(bundle.durable_ref)}"
}

///|
/// Whether the package object has enough durable metadata to be exported safely.
pub fn shareable_package_is_valid(bundle : ShareablePackage) -> Bool {
  manifest_is_valid(bundle.manifest) &&
  bundle.display_name != "" &&
  bundle.export_ref != "" &&
  bundle.checkpoint_id != "" &&
  @provenance.lineage_ref_value(bundle.durable_ref) != ""
}

///|
/// Restore the manifest from a validated shareable package object.
pub fn imported_manifest(bundle : ShareablePackage) -> PackageManifest? {
  if shareable_package_is_valid(bundle) {
    Some(bundle.manifest)
  } else {
    None
  }
}

///|
/// Stable subject kind exposed by the shareable package wrapper.
pub fn shareable_package_subject_kind(bundle : ShareablePackage) -> String {
  package_subject_kind_name(bundle.manifest.subject)
}

///|
/// Stable durable reference linked to the package export.
pub fn shareable_package_durable_ref(bundle : ShareablePackage) -> String {
  @provenance.lineage_ref_value(bundle.durable_ref)
}
