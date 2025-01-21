import 'package:card_game/src/cards/suited_cards/suited_card.dart';

/// Utility class for converting card values to comparable integers.
///
/// Provides different mappings based on whether ace is considered high or low.
class SuitedCardValueMapper {
  final int Function(SuitedCard card) valueMapper;

  SuitedCardValueMapper._({required this.valueMapper});

  /// Converts a card to its numeric value based on the mapping strategy.
  int getValue(SuitedCard card) => valueMapper(card);

  /// Returns a mapper where ace is valued at 1 (lowest).
  static SuitedCardValueMapper get aceAsLowest => SuitedCardValueMapper._(
        valueMapper: (card) => switch (card.value) {
          AceSuitedCardValue() => 1,
          NumberSuitedCardValue(:final value) => value,
          JackSuitedCardValue() => 11,
          QueenSuitedCardValue() => 12,
          KingSuitedCardValue() => 13,
        },
      );

  /// Returns a mapper where ace is valued at 14 (highest).
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
