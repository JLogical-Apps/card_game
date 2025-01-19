import 'package:cards/cards/cards.dart';
import 'package:cards/games/cards/suited_card.dart';
import 'package:cards/games/cards/suited_card_builder.dart';
import 'package:cards/games/cards/suited_card_distance_mapper.dart';
import 'package:cards/widgets/animated_flippable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class GolfSolitaireState {
  final List<List<SuitedCard>> cards;
  final List<SuitedCard> deck;
  final List<SuitedCard> completedCards;

  GolfSolitaireState({
    required this.cards,
    required this.deck,
    required this.completedCards,
  });

  static GolfSolitaireState get initialState {
    var deck = SuitedCard.deck.shuffled();

    final cards = List.generate(7, (i) {
      final column = deck.take(5).toList();
      deck = deck.skip(5).toList();
      return column;
    });

    return GolfSolitaireState(
      cards: cards,
      deck: deck.skip(1).toList(),
      completedCards: [deck.first],
    );
  }

  bool canSelect(SuitedCard card) {
    return SuitedCardDistanceMapper.rollover.getDistance(completedCards.last, card) == 1;
  }

  GolfSolitaireState withSelection(SuitedCard card) => GolfSolitaireState(
        cards: cards.map((column) => [...column]..remove(card)).toList(),
        deck: deck,
        completedCards: completedCards + [card],
      );

  bool get canDraw => deck.isNotEmpty;

  GolfSolitaireState withDraw() => GolfSolitaireState(
        cards: cards,
        deck: deck.sublist(0, deck.length - 1),
        completedCards: completedCards + [deck.last],
      );
}

class GolfSolitiare extends HookWidget {
  const GolfSolitiare({super.key});

  @override
  Widget build(BuildContext context) {
    final state = useState(GolfSolitaireState.initialState);

    return Stack(
      children: [
        CardGame<SuitedCard, dynamic>(
          cardGroups: [
            ...state.value.cards.mapIndexed((i, column) => CardRow(
                  value: i,
                  values: column,
                  position: Offset(10, i * 115),
              spacing: 30,
                )),
            CardDeck(
              value: 'deck',
              values: state.value.deck,
              position: Offset(300, 250),
              isCardFlipped: (_, __) => true,
            ),
            CardDeck(
              value: 'completed',
              values: state.value.completedCards,
              position: Offset(300, 400),
            ),
          ],
          cardSize: Size(64, 89) * 1.2,
          emptyGroupBuilder: (state) => AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          cardBuilder: (value, flipped, cardState) => GestureDetector(
            onTap: () {
              if (!state.value.deck.contains(value) &&
                  !state.value.completedCards.contains(value) &&
                  state.value.canSelect(value)) {
                state.value = state.value.withSelection(value);
              } else if (state.value.canDraw && state.value.deck.contains(value)) {
                state.value = state.value.withDraw();
              }
            },
            child: AnimatedFlippable(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              isFlipped: flipped,
              front: SuitedCardBuilder(card: value),
              back: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
