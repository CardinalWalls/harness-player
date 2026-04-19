///|
/// The external package subject stays explicit so skill, profile, and topology
/// can evolve without collapsing into a single opaque blob.
pub enum PackageSubject {
  Skill(String)
  Profile(String)
  Topology(String)
}

///|
/// The first explicit external package manifest for the vertical proof loop.
pub struct PackageManifest {
  package_id : String
  version : String
  subject : PackageSubject
  profile_ref : String
  topology_ref : String
  provenance_ref : String
}

///|
/// Construct a package manifest without embedding raw runtime state.
pub fn package_manifest(
  package_id : String,
  version : String,
  subject : PackageSubject,
  profile_ref : String,
  topology_ref : String,
  provenance_ref : String,
) -> PackageManifest {
  { package_id, version, subject, profile_ref, topology_ref, provenance_ref }
}

///|
/// Public constructor for skill package subjects.
pub fn skill_subject(asset_ref : String) -> PackageSubject {
  Skill(asset_ref)
}

///|
/// Public constructor for profile package subjects.
pub fn profile_subject(profile_ref : String) -> PackageSubject {
  Profile(profile_ref)
}

///|
/// Public constructor for topology package subjects.
pub fn topology_subject(topology_ref : String) -> PackageSubject {
  Topology(topology_ref)
}

///|
/// Stable string form for package subject kind decisions and assertions.
pub fn package_subject_kind_name(subject : PackageSubject) -> String {
  match subject {
    Skill(_) => "skill"
    Profile(_) => "profile"
    Topology(_) => "topology"
  }
}

///|
/// Stable reference value for the package subject.
pub fn package_subject_ref(subject : PackageSubject) -> String {
  match subject {
    Skill(value) => value
    Profile(value) => value
    Topology(value) => value
  }
}

///|
/// Stable key for export, import, and fixture assertions.
pub fn package_manifest_key(manifest : PackageManifest) -> String {
  "\{manifest.package_id}@\{manifest.version}|\{package_subject_kind_name(manifest.subject)}|\{package_subject_ref(manifest.subject)}|\{manifest.profile_ref}|\{manifest.topology_ref}|\{manifest.provenance_ref}"
}
