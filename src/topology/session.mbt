///|
/// Runtime-agnostic identifier for a session host.
pub type SessionId = String

///|
/// Stable descriptor for a session exposed through the kernel.
pub struct SessionDescriptor {
  id : SessionId
  profile : String
  runtime : String
}

///|
/// Construct a generic session descriptor without encoding runtime roles.
pub fn session(
  id : SessionId,
  profile : String,
  runtime : String,
) -> SessionDescriptor {
  { id, profile, runtime }
}

///|
/// Produce a stable display key for logs, assertions, and provenance traces.
pub fn session_descriptor_key(descriptor : SessionDescriptor) -> String {
  "\{descriptor.runtime}:\{descriptor.profile}:\{descriptor.id}"
}

///|
/// Return the identifier of a session descriptor.
pub fn session_id_of(descriptor : SessionDescriptor) -> SessionId {
  descriptor.id
}
