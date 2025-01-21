/// Represents the interactive state of a card or card group.
///
/// Used to determine the visual appearance during different interaction states.
enum CardState {
  /// Normal, non-interactive state
  regular,

  /// Highlighted state, typically used when a valid drag operation is possible
  highlighted,

  /// Error state, typically used when an invalid drag operation is attempted
  error,
}
