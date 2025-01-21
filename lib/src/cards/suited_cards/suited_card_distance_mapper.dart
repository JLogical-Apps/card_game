import 'package:card_game/src/cards/suited_cards/suited_card.dart';
import 'package:card_game/src/cards/suited_cards/suited_card_value_mapper.dart';

/// Utility class for calculating the distance between card values.
///
/// Used in games where sequential card values are important.
class SuitedCardDistanceMapper {
  final int Function(SuitedCard card1, SuitedCard card2) distanceMapper;

  SuitedCardDistanceMapper._({required this.distanceMapper});

  /// Calculates the distance between two cards' values.
  ///
  /// In the default rollover implementation, ace and king have a distance of 1.
  int getDistance(SuitedCard card1, SuitedCard card2) => distanceMapper(card1, card2);

  /// Returns a mapper where ace and king are considered adjacent (distance of 1).
  ///
  /// Useful for games like Golf Solitaire where cards can wrap around.
  static SuitedCardDistanceMapper get rollover => SuitedCardDistanceMapper._(
        distanceMapper: (card1, card2) => (_getValue(card1, card2) - _getValue(card2, card1)).abs(),
      );

  static int _getValue(SuitedCard card1, SuitedCard card2) => switch (card1.value) {
        AceSuitedCardValue() => switch (card2.value) {
            KingSuitedCardValue() => 14,
            _ => 1,
          },
        _ => SuitedCardValueMapper.aceAsLowest.getValue(card1),
      };
}
