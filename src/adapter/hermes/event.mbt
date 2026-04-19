///|
/// Emit the thinnest runtime-linked event shape needed by capture normalization.
pub fn emit_runtime_event(
  descriptor : HermesDescriptor,
  event_type : String,
  payload_ref : String,
) -> @capture.RuntimeEvent {
  @capture.runtime_event(
    event_type,
    descriptor.session_id,
    descriptor.channel_id,
    descriptor.profile,
    "hermes",
    payload_ref,
  )
}
