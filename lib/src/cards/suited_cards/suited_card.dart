import 'package:equatable/equatable.dart';

/// Represents a standard playing card with a suit and value.
///
/// Each card has a unique combination of [suit] and [value].
class SuitedCard extends Equatable {
  /// The suit of the card (hearts, diamonds, clubs, or spades).
  final CardSuit suit;

  /// The value of the card (ace, number 2-10, jack, queen, or king).
  final SuitedCardValue value;

  const SuitedCard({required this.suit, required this.value});

  /// Returns a complete standard deck of 52 cards (no jokers).
  static List<SuitedCard> get deck =>
      CardSuit.values.expand((suit) => values.map((value) => SuitedCard(suit: suit, value: value))).toList();

  /// Returns all possible card values in order (ace through king).
  static List<SuitedCardValue> get values => [
        ...List.generate(10 - 2 + 1, (i) => 2 + i).map((value) => NumberSuitedCardValue(value: value)),
        JackSuitedCardValue(),
        QueenSuitedCardValue(),
        KingSuitedCardValue(),
        AceSuitedCardValue(),
      ];

  @override
  List<Object?> get props => [suit, value];
}

/// Represents the color of a playing card suit.
enum CardSuitColor { black, red }

/// Represents the four standard playing card suits.
enum CardSuit {
  hearts(CardSuitColor.red),
  diamonds(CardSuitColor.red),
  clubs(CardSuitColor.black),
  spades(CardSuitColor.black);

  final CardSuitColor color;
  const CardSuit(this.color);
}

/// Base class for playing card values.
///
/// This is a sealed class with implementations for number cards (2-10),
/// face cards (jack, queen, king), and ace.
sealed class SuitedCardValue {}

class NumberSuitedCardValue extends SuitedCardValue with EquatableMixin {
  final int value;

  NumberSuitedCardValue({required this.value});

  @override
  List<Object?> get props => [value];
}

class JackSuitedCardValue extends SuitedCardValue with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class QueenSuitedCardValue extends SuitedCardValue with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class KingSuitedCardValue extends SuitedCardValue with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class AceSuitedCardValue extends SuitedCardValue with EquatableMixin {
  @override
  List<Object?> get props => [];
}
