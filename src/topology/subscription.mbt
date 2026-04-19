///|
/// Delivery mode stays generic so runtime integrations can map to their own semantics.
pub enum DeliveryMode {
  Broadcast
  Targeted
}

///|
/// A subscription links a subscriber session to a channel with a lightweight filter.
pub struct Subscription {
  subscriber : SessionId
  channel : ChannelId
  filter : String
  delivery : DeliveryMode
}

///|
/// Construct a subscription tuple for the topology graph.
pub fn subscription(
  subscriber : SessionId,
  channel : ChannelId,
  filter : String,
  delivery : DeliveryMode,
) -> Subscription {
  { subscriber, channel, filter, delivery }
}

///|
/// Whether a subscription is targeted instead of broadcast.
pub fn subscription_is_targeted(subscription : Subscription) -> Bool {
  match subscription.delivery {
    Broadcast => false
    Targeted => true
  }
}

///|
/// Public constructor for broadcast delivery across package boundaries.
pub fn broadcast_delivery() -> DeliveryMode {
  Broadcast
}

///|
/// Public constructor for targeted delivery across package boundaries.
pub fn targeted_delivery() -> DeliveryMode {
  Targeted
}
