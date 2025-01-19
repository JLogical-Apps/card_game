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

    return Stack(
      children: [
        CardGame<SuitedCard, dynamic>(
          cardGroups: [
            ...state.value.cardLayout.slices(6).expandIndexed((rowNum, row) => row
                .mapIndexed((colNum, card) => state.value.completedCards.contains(card)
                    ? null
                    : CardDeck<SuitedCard, dynamic>(
                        value: card,
                        values: [card],
                        position: Offset(colNum * 70 + 10, rowNum * 91),
                        isCardFlipped: (_, __) => !state.value.selectedCards.contains(card),
                        canGrab: false,
                      ))
                .nonNulls
                .toList()),
            CardDeck(
              value: 'completed',
              values: state.value.completedCards,
              position: Offset(360, MediaQuery.sizeOf(context).height - 200),
            ),
          ],
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
        ),
        Positioned(
          left: 290,
          width: 64,
          bottom: 0,
          height: 129,
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
      ],
    );
  }
}
