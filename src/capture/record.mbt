///|
/// A runtime-linked event captured before normalization into durable records.
pub struct RuntimeEvent {
  event_type : String
  session_id : @topology.SessionId
  channel_id : @topology.ChannelId
  profile : String
  runtime : String
  payload_ref : String
}

///|
/// A normalized internal record linked to durable checkpoint provenance.
pub struct CaptureRecord {
  normalized_event_id : String
  event_type : String
  session_id : @topology.SessionId
  channel_id : @topology.ChannelId
  profile : String
  runtime : String
  payload_ref : String
  checkpoint_id : String
  durable_ref : @provenance.LineageRef
}

///|
/// Construct a runtime-linked event without coupling to one host schema.
pub fn runtime_event(
  event_type : String,
  session_id : @topology.SessionId,
  channel_id : @topology.ChannelId,
  profile : String,
  runtime : String,
  payload_ref : String,
) -> RuntimeEvent {
  { event_type, session_id, channel_id, profile, runtime, payload_ref }
}

///|
/// Stable key for assertions before normalization.
pub fn runtime_event_key(event : RuntimeEvent) -> String {
  "\{event.runtime}|\{event.profile}|\{event.session_id}|\{event.channel_id}|\{event.event_type}|\{event.payload_ref}"
}

///|
/// Normalize a runtime-linked event into an internal capture record with provenance.
pub fn normalize_runtime_event(
  event : RuntimeEvent,
  metadata : @provenance.CheckpointMetadata,
) -> CaptureRecord {
  let normalized_event_id = "capture://\{event.runtime}|\{event.session_id}|\{event.channel_id}|\{event.event_type}|\{event.payload_ref}"
  {
    normalized_event_id,
    event_type: event.event_type,
    session_id: event.session_id,
    channel_id: event.channel_id,
    profile: event.profile,
    runtime: event.runtime,
    payload_ref: event.payload_ref,
    checkpoint_id: @provenance.checkpoint_id_of(metadata),
    durable_ref: @provenance.checkpoint_durable_ref(metadata),
  }
}

///|
/// Stable key for normalized capture assertions.
pub fn capture_record_key(record : CaptureRecord) -> String {
  "\{record.normalized_event_id}|\{record.profile}|\{record.checkpoint_id}|\{@provenance.lineage_ref_value(record.durable_ref)}"
}

///|
/// Whether the normalized record links back to durable provenance.
pub fn capture_links_to_provenance(record : CaptureRecord) -> Bool {
  record.checkpoint_id != "" &&
  @provenance.lineage_ref_value(record.durable_ref) != ""
}

///|
/// Return the source runtime of a runtime-linked event.
pub fn runtime_event_runtime(event : RuntimeEvent) -> String {
  event.runtime
}

///|
/// Return the profile label attached to a runtime-linked event.
pub fn runtime_event_profile(event : RuntimeEvent) -> String {
  event.profile
}

///|
/// Return the checkpoint id linked to the normalized capture record.
pub fn capture_checkpoint_id(record : CaptureRecord) -> String {
  record.checkpoint_id
}

///|
/// Return the durable reference linked to the normalized capture record.
pub fn capture_durable_ref(record : CaptureRecord) -> String {
  @provenance.lineage_ref_value(record.durable_ref)
}
