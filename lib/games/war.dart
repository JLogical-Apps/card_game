import 'dart:math';

import 'package:cards/cards/cards.dart';
import 'package:cards/games/cards/suited_card.dart';
import 'package:cards/games/cards/suited_card_value_mapper.dart';
import 'package:cards/games/styles/deck_style.dart';
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        warState.value = warState.value.withAcceptOrDraw();
      },
      child: CardGame<SuitedCard, dynamic>(
        style: deckStyle(sizeMultiplier: 1.5),
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Column(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  numPlayers,
                  (i) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      spacing: 20,
                      children: [
                        Stack(
                          children: [
                            CardDeck<SuitedCard, dynamic>.flipped(
                              value: 'deck: $i',
                              values: warState.value.playerDecks[i],
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  warState.value.playerDecks[i].length.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .copyWith(fontFeatures: [FontFeature.tabularFigures()]),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: CardRow<SuitedCard, dynamic>(
                            value: 'hand: $i',
                            values: warState.value.playerHands[i],
                            maxGrabStackSize: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
              child: ElevatedButton(
                onPressed: () => warState.value = WarState.getInitialState(numPlayers),
                style: ButtonStyle(shape: WidgetStatePropertyAll(CircleBorder())),
                child: Icon(Icons.restart_alt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
