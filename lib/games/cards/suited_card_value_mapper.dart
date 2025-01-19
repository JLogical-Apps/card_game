import 'package:cards/games/cards/suited_card.dart';

class SuitedCardValueMapper {
  final int Function(SuitedCard card) valueMapper;

  SuitedCardValueMapper._({required this.valueMapper});

  int getValue(SuitedCard card) => valueMapper(card);

  static SuitedCardValueMapper get aceAsLowest => SuitedCardValueMapper._(
        valueMapper: (card) => switch (card.value) {
          AceSuitedCardValue() => 1,
          NumberSuitedCardValue(:final value) => value,
          JackSuitedCardValue() => 11,
          QueenSuitedCardValue() => 12,
          KingSuitedCardValue() => 13,
        },
      );

  static SuitedCardValueMapper get aceAsHighest => SuitedCardValueMapper._(
        valueMapper: (card) => switch (card.value) {
          NumberSuitedCardValue(:final value) => value,
          JackSuitedCardValue() => 11,
          QueenSuitedCardValue() => 12,
          KingSuitedCardValue() => 13,
          AceSuitedCardValue() => 14,
        },
      );
}
