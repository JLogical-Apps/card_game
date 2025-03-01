import 'dart:math';

import 'package:card_game/card_game.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth - MediaQuery.paddingOf(context).horizontal,
          constraints.maxHeight - MediaQuery.paddingOf(context).vertical,
        );

        // Calculate total horizontal and vertical space needed for cards
        final totalCardWidth = 6 * 64;
        final totalCardHeight = 9 * 89;

        // Calculate total padding space needed
        final totalHorizontalPadding = (6 - 1) * 4;
        final totalVerticalPadding = (9 - 1) * 4;

        // Calculate multiplier for each dimension
        final widthMultiplier = (size.width - totalHorizontalPadding) / totalCardWidth;
        final heightMultiplier = (size.height - totalVerticalPadding) / totalCardHeight;

        final cardRatio = min(widthMultiplier, heightMultiplier);

        return CardGame<SuitedCard, dynamic>(
          style: deckCardStyle(sizeMultiplier: cardRatio),
          children: [
            SafeArea(
              child: Column(
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
                                onCardPressed: (value) async {
                                  if (state.value.canSelect && !state.value.selectedCards.contains(value)) {
                                    state.value = state.value.withSelection(value);
                                    if (!state.value.canSelect) {
                                      await Future.delayed(Duration(milliseconds: 800));
                                      state.value = state.value.withClearSelectionAndMaybeComplete();
                                    }
                                  }
                                },
                              )),
                          if (rowNum == state.value.cardLayout.length ~/ 6) ...[
                            Center(
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
            ),
          ],
        );
      },
    );
  }
}
