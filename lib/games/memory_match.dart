import 'package:cards/cards/cards.dart';
import 'package:cards/games/cards/suited_card.dart';
import 'package:cards/games/cards/suited_card_builder.dart';
import 'package:cards/widgets/animated_flippable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MemoryMatchState {
  final List<SuitedCard> cardLayout;
  final List<SuitedCard> selectedCards;
  final List<SuitedCard> completedCards;
  final int attemptedMatches;

  const MemoryMatchState({
    required this.cardLayout,
    required this.selectedCards,
    required this.completedCards,
    required this.attemptedMatches,
  });

  static MemoryMatchState get initialState {
    final deck = SuitedCard.deck.shuffled();
    return MemoryMatchState(
      cardLayout: deck,
      selectedCards: [],
      completedCards: [],
      attemptedMatches: 0,
    );
  }

  MemoryMatchState withSelection(SuitedCard card) {
    return MemoryMatchState(
      cardLayout: cardLayout,
      selectedCards: selectedCards + [card],
      completedCards: completedCards,
      attemptedMatches: attemptedMatches,
    );
  }

  bool get canSelect => completedCards.length < cardLayout.length && selectedCards.length < 2;

  MemoryMatchState withClearSelectionAndMaybeComplete() {
    final completed = selectedCards[0].value == selectedCards[1].value;
    return MemoryMatchState(
      cardLayout: cardLayout,
      selectedCards: [],
      completedCards: [
        ...completedCards,
        if (completed) ...selectedCards,
      ],
      attemptedMatches: attemptedMatches + 1,
    );
  }
}

class MemoryMatch extends HookWidget {
  const MemoryMatch({super.key});

  @override
  Widget build(BuildContext context) {
    final state = useState(MemoryMatchState.initialState);

    return CardGame<SuitedCard, dynamic>(
      cardSize: Size(64, 89),
      emptyGroupBuilder: (state) => SizedBox.shrink(),
      cardBuilder: (value, flipped, cardState) => GestureDetector(
        onTap: () async {
          if (state.value.canSelect &&
              !state.value.selectedCards.contains(value) &&
              !state.value.completedCards.contains(value)) {
            state.value = state.value.withSelection(value);
            if (!state.value.canSelect) {
              await Future.delayed(Duration(milliseconds: 800));
              state.value = state.value.withClearSelectionAndMaybeComplete();
            }
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
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: state.value.cardLayout
              .slices(6)
              .mapIndexed(
                (rowNum, row) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ...row.mapIndexed((colNum, card) => CardDeck<SuitedCard, dynamic>(
                            value: card,
                            values: state.value.completedCards.contains(card) ? [] : [card],
                            isCardFlipped: (_, __) => !state.value.selectedCards.contains(card),
                            canGrab: false,
                          )),
                    if (rowNum == state.value.cardLayout.length ~/ 6) ...[
                      SizedBox(
                        width: 64,
                        height: 89,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.value.attemptedMatches.toString(),
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              Text('matches', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                      CardDeck<SuitedCard, dynamic>(
                        value: 'completed',
                        values: state.value.completedCards,
                      ),
                    ],
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
