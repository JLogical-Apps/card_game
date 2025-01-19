import 'package:equatable/equatable.dart';

class SuitedCard extends Equatable {
  final CardSuit suit;
  final SuitedCardValue value;

  const SuitedCard({required this.suit, required this.value});

  static List<SuitedCard> get deck => CardSuit.values
      .expand((suit) => [
            ...List.generate(10 - 2, (i) => 2 + i).map((value) => NumberSuitedCardValue(value: value)),
            JackSuitedCardValue(),
            QueenSuitedCardValue(),
            KingSuitedCardValue(),
            AceSuitedCardValue(),
          ].map((value) => SuitedCard(suit: suit, value: value)))
      .toList();

  @override
  List<Object?> get props => [suit, value];
}

enum CardSuit { hearts, diamonds, clubs, spades }

sealed class SuitedCardValue {}

class NumberSuitedCardValue extends SuitedCardValue with EquatableMixin {
  final int value;

  NumberSuitedCardValue({required this.value});

  @override
  List<Object?> get props => [value];
}

class JackSuitedCardValue extends SuitedCardValue {}

class QueenSuitedCardValue extends SuitedCardValue {}

class KingSuitedCardValue extends SuitedCardValue {}

class AceSuitedCardValue extends SuitedCardValue {}
