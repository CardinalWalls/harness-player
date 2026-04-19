///|
/// The first backend split stays explicit across Git-oriented provenance work.
pub enum GitBackend {
  MoonBitNative
  CompatibilityFallback
}

///|
/// The first routed operations that cross the provenance/materialization boundary.
pub enum MaterializationOperation {
  MetadataBranchWrite
  PackageExportWrite
  HostBridgeSync
}

///|
/// Route summary for a Git-oriented provenance operation.
pub struct MaterializationRoute {
  operation : MaterializationOperation
  backend : GitBackend
  reason : String
}

///|
/// Materialized provenance joins asset lineage, checkpoint metadata, and backend routing.
pub struct MaterializedCheckpoint {
  record : ProvenanceRecord
  metadata : CheckpointMetadata
  route : MaterializationRoute
}

///|
/// Stable name for backend assertions and reporting.
pub fn git_backend_name(backend : GitBackend) -> String {
  match backend {
    MoonBitNative => "moonbit-native"
    CompatibilityFallback => "compatibility-fallback"
  }
}

///|
/// Stable name for the routed provenance/materialization operation.
pub fn materialization_operation_name(
  operation : MaterializationOperation,
) -> String {
  match operation {
    MetadataBranchWrite => "metadata-branch-write"
    PackageExportWrite => "package-export-write"
    HostBridgeSync => "host-bridge-sync"
  }
}

///|
/// Public constructor for the metadata-branch write path.
pub fn metadata_branch_write_operation() -> MaterializationOperation {
  MetadataBranchWrite
}

///|
/// Public constructor for the package export write path.
pub fn package_export_write_operation() -> MaterializationOperation {
  PackageExportWrite
}

///|
/// Public constructor for the compatibility-oriented host bridge path.
pub fn host_bridge_sync_operation() -> MaterializationOperation {
  HostBridgeSync
}

///|
/// Route the first Git-facing provenance operations onto an explicit backend.
pub fn route_materialization(
  operation : MaterializationOperation,
) -> MaterializationRoute {
  match operation {
    MetadataBranchWrite =>
      {
        operation,
        backend: MoonBitNative,
        reason: "checkpoint metadata branch writing is part of the MoonBit-native provenance substrate",
      }
    PackageExportWrite =>
      {
        operation,
        backend: MoonBitNative,
        reason: "package export writing remains on the MoonBit-native path by default",
      }
    HostBridgeSync =>
      {
        operation,
        backend: CompatibilityFallback,
        reason: "host-specific bridge sync stays on the compatibility fallback path",
      }
  }
}

///|
/// Build the first durable checkpoint materialization record.
pub fn materialize_checkpoint(
  commit : @asset.AssetCommit,
  lineage : LineageNode,
  metadata : CheckpointMetadata,
) -> MaterializedCheckpoint {
  {
    record: provenance_record(commit, lineage),
    metadata,
    route: route_materialization(MetadataBranchWrite),
  }
}

///|
/// Stable key for materialization-level assertions.
pub fn materialized_checkpoint_key(
  materialized : MaterializedCheckpoint,
) -> String {
  "\{provenance_record_key(materialized.record)}|\{checkpoint_metadata_key(materialized.metadata)}|\{materialization_operation_name(materialized.route.operation)}|\{git_backend_name(materialized.route.backend)}|\{lineage_ref_value(materialized.metadata.durable_ref)}"
}

///|
/// Whether the routed operation uses the compatibility fallback.
pub fn route_uses_fallback(route : MaterializationRoute) -> Bool {
  match route.backend {
    CompatibilityFallback => true
    MoonBitNative => false
  }
}
