import 'package:card_game/src/cards/suited_cards/suited_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A widget that renders a visual representation of a [SuitedCard].
///
/// Creates a standard playing card appearance with suit and value symbols.
class SuitedCardBuilder extends StatelessWidget {
  final SuitedCard card;

  const SuitedCardBuilder({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      padding: EdgeInsets.all(1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: SvgPicture.asset(
            'assets/${getValueName(card)}_of_${card.suit.name}.svg',
            package: 'card_game',
            width: 64,
            height: 89,
          ),
        ),
      ),
    );
  }

  String getValueName(SuitedCard card) => switch (card.value) {
        NumberSuitedCardValue(:final value) => value.toString(),
        JackSuitedCardValue() => 'jack',
        QueenSuitedCardValue() => 'queen',
        KingSuitedCardValue() => 'king',
        AceSuitedCardValue() => 'ace',
      };
}
