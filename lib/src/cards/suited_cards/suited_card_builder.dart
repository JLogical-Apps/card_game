import 'package:card_game/src/cards/suited_cards/suited_card.dart';
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

/// A widget that renders a visual representation of a [SuitedCard].
///
/// Creates a standard playing card appearance with suit and value symbols.
class SuitedCardBuilder extends StatelessWidget {
  final SuitedCard card;

  const SuitedCardBuilder({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return CardTheme(
      data: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
        ),
        padding: EdgeInsets.all(1),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PlayingCardView(
            card: PlayingCard(getSuit(card), getValue(card)),
          ),
        ),
      ),
    );
  }

  Suit getSuit(SuitedCard card) => switch (card.suit) {
        CardSuit.hearts => Suit.hearts,
        CardSuit.diamonds => Suit.diamonds,
        CardSuit.clubs => Suit.clubs,
        CardSuit.spades => Suit.spades,
      };

  CardValue getValue(SuitedCard card) => switch (card.value) {
        NumberSuitedCardValue(:final value) => switch (value) {
            2 => CardValue.two,
            3 => CardValue.three,
            4 => CardValue.four,
            5 => CardValue.five,
            6 => CardValue.six,
            7 => CardValue.seven,
            8 => CardValue.eight,
            9 => CardValue.nine,
            10 => CardValue.ten,
            _ => throw UnimplementedError(),
          },
        JackSuitedCardValue() => CardValue.jack,
        QueenSuitedCardValue() => CardValue.queen,
        KingSuitedCardValue() => CardValue.king,
        AceSuitedCardValue() => CardValue.ace,
      };
}
