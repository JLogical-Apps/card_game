import 'package:card_game/src/cards/suited_cards/suited_card.dart';
import 'package:card_game/src/cards/suited_cards/suited_card_value_mapper.dart';

class SuitedCardDistanceMapper {
  final int Function(SuitedCard card1, SuitedCard card2) distanceMapper;

  SuitedCardDistanceMapper._({required this.distanceMapper});

  int getDistance(SuitedCard card1, SuitedCard card2) => distanceMapper(card1, card2);

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
