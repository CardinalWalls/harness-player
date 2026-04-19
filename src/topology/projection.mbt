///|
/// Runtime-agnostic identifier for a projection.
pub type ProjectionId = String

///|
/// Descriptor for a projection derived from a source channel.
pub struct ProjectionDescriptor {
  id : ProjectionId
  source_channel : ChannelId
  summary : String
}

///|
/// Construct a projection descriptor for a derived view of a source channel.
pub fn projection(
  id : ProjectionId,
  source_channel : ChannelId,
  summary : String,
) -> ProjectionDescriptor {
  { id, source_channel, summary }
}

///|
/// Return the source channel that feeds a projection.
pub fn projection_source(descriptor : ProjectionDescriptor) -> ChannelId {
  descriptor.source_channel
}
