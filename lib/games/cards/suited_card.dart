import 'package:equatable/equatable.dart';

class SuitedCard extends Equatable {
  final CardSuit suit;
  final SuitedCardValue value;

  const SuitedCard({required this.suit, required this.value});

  static List<SuitedCard> get deck => CardSuit.values
      .expand((suit) => <SuitedCardValue>[
            ...List.generate(10 - 2 + 1, (i) => 2 + i).map((value) => NumberSuitedCardValue(value: value)),
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
