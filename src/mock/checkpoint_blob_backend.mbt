///|
/// Local mock storage contract for checkpoint payload lookups.
pub struct MockCheckpointBlobBackend {
  available_payload_refs : Array[String]
}

///|
/// Response for resolving a checkpoint payload reference into a blob boundary.
pub struct PayloadResolution {
  blob_id : String
  availability : String
}

///|
/// Response for attaching lineage metadata to a durable checkpoint record.
pub struct LineageAttachment {
  attached : Bool
  durable_ref : String
}

///|
/// Seed backend values that mimic a small set of durable payload references.
pub fn first_wave_checkpoint_blob_backend() -> MockCheckpointBlobBackend {
  {
    available_payload_refs: [
      "payload://checkpoint-1/story-distiller", "payload://checkpoint-2/story-loop",
    ],
  }
}

///|
/// Resolve a mock payload reference without binding the contract to real blob storage.
pub fn resolve_payload_ref(
  backend : MockCheckpointBlobBackend,
  payload_ref : String,
) -> PayloadResolution {
  if backend.available_payload_refs.contains(payload_ref) {
    { blob_id: "blob://available/\{payload_ref}", availability: "available" }
  } else {
    { blob_id: "blob://missing/\{payload_ref}", availability: "missing" }
  }
}

///|
/// Attach lineage metadata to a durable checkpoint boundary in mock form.
pub fn attach_lineage_metadata(
  _backend : MockCheckpointBlobBackend,
  checkpoint_id : String,
  lineage_ref : String,
) -> LineageAttachment {
  let attached = checkpoint_id != "" && lineage_ref != ""
  let durable_ref = if attached {
    "durable://checkpoint/\{checkpoint_id}/lineage/\{lineage_ref}"
  } else {
    ""
  }
  { attached, durable_ref }
}
