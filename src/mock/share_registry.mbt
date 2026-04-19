///|
/// Summary returned by the mock share-registry discovery boundary.
pub struct SharePackageSummary {
  package_id : String
  latest_version : String
  summary : String
}

///|
/// Internal registry record used to drive discovery and manifest lookup.
pub struct MockRegistryPackage {
  summary : SharePackageSummary
  manifest_ref : String
  integrity_hash : String
  kinds : Array[String]
}

///|
/// Isolated first-wave mock registry for local contract exercises.
pub struct MockShareRegistry {
  packages : Array[MockRegistryPackage]
}

///|
/// Response returned by the mock manifest-fetch operation.
pub struct FetchManifestResponse {
  manifest_ref : String
  integrity_hash : String
}

///|
fn registry_package(
  package_id : String,
  latest_version : String,
  summary : String,
  manifest_ref : String,
  integrity_hash : String,
  kinds : Array[String],
) -> MockRegistryPackage {
  {
    summary: { package_id, latest_version, summary },
    manifest_ref,
    integrity_hash,
    kinds,
  }
}

///|
/// Frozen skill kind name used by the manifest contract.
pub fn skill_kind() -> String {
  "skill"
}

///|
/// Frozen profile kind name used by the manifest contract.
pub fn profile_kind() -> String {
  "profile"
}

///|
/// Frozen topology kind name used by the manifest contract.
pub fn topology_kind() -> String {
  "topology"
}

///|
/// Seeded first-wave registry data for local tests without remote package hosting.
pub fn first_wave_share_registry() -> MockShareRegistry {
  {
    packages: [
      registry_package(
        "pkg-story-distiller",
        "v1",
        "Story distiller skill bundle for the proof slice.",
        "mock://registry/pkg-story-distiller/v1/manifest",
        "sha256:mock-story-distiller-v1",
        [skill_kind()],
      ),
      registry_package(
        "pkg-default-profile",
        "v1",
        "Default profile package used to replay the first bundle.",
        "mock://registry/pkg-default-profile/v1/manifest",
        "sha256:mock-default-profile-v1",
        [profile_kind()],
      ),
      registry_package(
        "pkg-story-loop",
        "v1",
        "Topology package for the reusable story-loop activation graph.",
        "mock://registry/pkg-story-loop/v1/manifest",
        "sha256:mock-story-loop-v1",
        [topology_kind()],
      ),
    ],
  }
}

///|
fn matches_query(candidate : MockRegistryPackage, query : String) -> Bool {
  if query == "" {
    true
  } else {
    candidate.summary.package_id.to_lower().contains(query) ||
    candidate.summary.summary.to_lower().contains(query)
  }
}

///|
fn matches_kind(
  candidate : MockRegistryPackage,
  requested_kinds : Array[String],
) -> Bool {
  if requested_kinds.is_empty() {
    true
  } else {
    for requested_kind in requested_kinds {
      if candidate.kinds.contains(requested_kind) {
        return true
      }
    }
    false
  }
}

///|
/// Discover locally-seeded packages by fuzzy query and requested manifest kinds.
pub fn discover_packages(
  registry : MockShareRegistry,
  query : String,
  requested_kinds : Array[String],
) -> Array[SharePackageSummary] {
  let normalized_query = query.to_lower()
  let matches : Array[SharePackageSummary] = []
  for candidate in registry.packages {
    if matches_query(candidate, normalized_query) &&
      matches_kind(candidate, requested_kinds) {
      matches.push(candidate.summary)
    }
  }
  matches
}

///|
/// Fetch the seeded manifest metadata for an exact package/version pair.
pub fn fetch_manifest(
  registry : MockShareRegistry,
  package_id : String,
  version : String,
) -> FetchManifestResponse? {
  for candidate in registry.packages {
    if candidate.summary.package_id == package_id &&
      candidate.summary.latest_version == version {
      return Some({
        manifest_ref: candidate.manifest_ref,
        integrity_hash: candidate.integrity_hash,
      })
    }
  }
  None
}
