import 'dart:math';

import 'package:cards/cards/cards.dart';
import 'package:cards/games/cards/suited_card.dart';
import 'package:cards/games/cards/suited_card_builder.dart';
import 'package:cards/games/cards/suited_card_value_mapper.dart';
import 'package:cards/widgets/animated_flippable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class WarState {
  final List<List<SuitedCard>> playerDecks;
  final List<List<SuitedCard>> playerHands;

  const WarState({required this.playerDecks, required this.playerHands});

  static WarState getInitialState(int numPlayers) {
    final deck = SuitedCard.deck.shuffled();
    final cardsPerPlayer = deck.length ~/ numPlayers;
    return WarState(
      playerDecks: List.generate(numPlayers, (i) => deck.skip(cardsPerPlayer * i).take(cardsPerPlayer).toList()),
      playerHands: List.generate(numPlayers, (_) => []),
    );
  }

  WarState withDraw() {
    final lastCards = playerDecks.map((deck) => deck.lastOrNull).toList();
    return WarState(
      playerDecks: playerDecks.map((deck) => deck.isEmpty ? <SuitedCard>[] : deck.sublist(0, deck.length - 1)).toList(),
      playerHands: playerHands
          .mapIndexed((i, hand) => [
                ...hand,
                if (lastCards[i] case final lastCard?) lastCard,
              ])
          .toList(),
    );
  }

  WarState withAcceptOrDraw() {
    final roundWinner = this.roundWinner;
    if (roundWinner == null) {
      return withDraw();
    }

    final allHands = playerHands.expand((list) => list).shuffled();

    return WarState(
      playerDecks: playerDecks.mapIndexed((i, deck) => roundWinner == i ? allHands + deck : deck).toList(),
      playerHands: playerHands.map((_) => <SuitedCard>[]).toList(),
    );
  }

  int? get roundWinner {
    final nonEmptyPlayerHands =
        playerHands.mapIndexed((i, hand) => (i, hand)).where((record) => record.$2.isNotEmpty).toList();
    if (nonEmptyPlayerHands.isEmpty) {
      return null;
    }

    final largestCard = nonEmptyPlayerHands
        .map((record) => record.$2.last)
        .fold(-1, (prev, acc) => max(prev, SuitedCardValueMapper.aceAsHighest.getValue(acc)));
    final handsContainingLargestCard = nonEmptyPlayerHands
        .where((record) => SuitedCardValueMapper.aceAsHighest.getValue(record.$2.last) == largestCard)
        .toList();
    if (handsContainingLargestCard.length > 1) {
      return null;
    }

    return handsContainingLargestCard.first.$1;
  }

  int? get gameWinner {
    final nonEmptyHands =
        playerHands.mapIndexed((i, hand) => (i, hand)).where((record) => record.$2.isNotEmpty).toList();
    if (nonEmptyHands.length == 1) {
      return nonEmptyHands.first.$1;
    }
    return null;
  }
}

class War extends HookWidget {
  final int numPlayers;

  const War({super.key, this.numPlayers = 2});

  @override
  Widget build(BuildContext context) {
    final warState = useState(WarState.getInitialState(numPlayers));

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            warState.value = warState.value.withAcceptOrDraw();
          },
          child: CardGame<SuitedCard, dynamic>(
            cardGroups: [
              ...List.generate(
                  numPlayers,
                  (i) => CardDeck(
                        value: 'deck: $i',
                        values: warState.value.playerDecks[i],
                        position: Offset(100, i * 150),
                        isCardFlipped: (_, __) => true,
                      )),
              ...List.generate(
                  numPlayers,
                  (i) => CardRow(
                        value: 'hand: $i',
                        values: warState.value.playerHands[i],
                        position: Offset(220, i * 150),
                        maxGrabStackSize: 0,
                      )),
            ],
            cardSize: Size(64, 89) * 1.5,
            emptyGroupBuilder: (state) => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              decoration: BoxDecoration(
                color: switch (state) {
                  CardState.regular => Colors.white,
                  CardState.highlighted => Color(0xFF9FC7FF),
                  CardState.error => Color(0xFFFFADAD),
                }
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            cardBuilder: (value, flipped, state) => AnimatedFlippable(
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
        ...List.generate(
            numPlayers,
            (i) => Positioned(
                  left: 100,
                  width: 96,
                  top: i * 150,
                  height: 135,
                  child: Center(
                    child: Text(
                      warState.value.playerDecks[i].length.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(fontFeatures: [FontFeature.tabularFigures()]),
                    ),
                  ),
                )),
        Align(
          alignment: Alignment.bottomCenter,
          child: ElevatedButton(
            onPressed: () => warState.value = WarState.getInitialState(numPlayers),
            style: ButtonStyle(shape: WidgetStatePropertyAll(CircleBorder())),
            child: Icon(Icons.restart_alt),
          ),
        ),
      ],
    );
  }
}
