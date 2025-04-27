import 'package:card_game/src/cards/card_state.dart';
import 'package:flutter/material.dart';

/// Defines the visual appearance of cards and empty card groups in a [CardGame].
///
/// This class controls how cards are rendered, their size, and how empty card groups appear.
/// The type parameter [T] must match the card value type used in the corresponding [CardGame].
class CardGameStyle<T, G> {
  /// The size of each card in logical pixels.
  final Size cardSize;

  /// Builds the widget representation of a card with the given value and state.
  ///
  /// `value` is the card's value of type [T].
  /// `flipped` determines if the card should show its back face.
  /// `state` indicates the card's current interaction state.
  final Widget Function(T value, G group, bool flipped, CardState state) cardBuilder;

  /// Builds the widget representation of an empty card group.
  ///
  /// `state` indicates the group's current interaction state, useful for
  /// showing different appearances during drag-and-drop operations.
  final Widget Function(G group, CardState state) emptyGroupBuilder;

  CardGameStyle({
    required this.cardSize,
    required this.cardBuilder,
    required this.emptyGroupBuilder,
  });

  Widget buildEmptyGroup(G group, CardState state) => emptyGroupBuilder(group, state);

  Widget buildCardContent(T value, G group, bool flipped, CardState state) => cardBuilder(value, group, flipped, state);
}
