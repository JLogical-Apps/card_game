import 'package:cards/cards/cards.dart';
import 'package:cards/games/cards/suited_card.dart';
import 'package:cards/games/cards/suited_card_value_mapper.dart';
import 'package:cards/games/styles/deck_style.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SolitaireState {
  final List<List<SuitedCard>> hiddenCards;
  final List<List<SuitedCard>> revealedCards;
  final List<SuitedCard> deck;
  final List<SuitedCard> revealedDeck;
  final Map<CardSuit, List<SuitedCard>> completedCards;

  SolitaireState({
    required this.hiddenCards,
    required this.revealedCards,
    required this.deck,
    required this.revealedDeck,
    required this.completedCards,
  });

  static SolitaireState get initialState {
    var deck = SuitedCard.deck.shuffled();

    final hiddenCards = List.generate(7, (i) {
      final column = deck.take(i).toList();
      deck = deck.skip(i).toList();
      return column;
    });

    final revealedCards = deck.take(7).map((card) => [card]).toList();
    deck = deck.skip(7).toList();

    return SolitaireState(
      hiddenCards: hiddenCards,
      revealedCards: revealedCards,
      deck: deck,
      revealedDeck: [],
      completedCards: Map.fromEntries(CardSuit.values.map((suit) => MapEntry(suit, []))),
    );
  }

  SolitaireState withDrawOrRefresh() {
    return deck.isEmpty
        ? copyWith(deck: revealedDeck.reversed.toList(), revealedDeck: [])
        : copyWith(deck: deck.sublist(0, deck.length - 1), revealedDeck: revealedDeck + [deck.last]);
  }

  int getCardValue(SuitedCard card) => SuitedCardValueMapper.aceAsLowest.getValue(card);

  bool canComplete(SuitedCard card) {
    final completedSuitCards = completedCards[card.suit]!;
    return completedSuitCards.isEmpty && card.value == AceSuitedCardValue() ||
        (completedSuitCards.isNotEmpty && getCardValue(completedSuitCards.last) + 1 == getCardValue(card));
  }

  SolitaireState withAttemptToComplete(int column, SuitedCard card) {
    if (canComplete(card)) {
      final newRevealedCards = [...revealedCards];
      newRevealedCards[column] = [...revealedCards[column]]..removeLast();

      final newHiddenCards = [...hiddenCards];
      final lastHiddenCard = hiddenCards[column].lastOrNull;

      if (newRevealedCards[column].isEmpty && lastHiddenCard != null) {
        newRevealedCards[column] = [lastHiddenCard];
        newHiddenCards[column] = [...newHiddenCards[column]]..removeLast();
      }

      return copyWith(
        revealedCards: newRevealedCards,
        hiddenCards: newHiddenCards,
        completedCards: {
          ...completedCards,
          card.suit: [...completedCards[card.suit]!, card],
        },
      );
    }

    return this;
  }

  SolitaireState withAttemptToCompleteFromDeck() {
    final revealedCard = revealedDeck.lastOrNull;
    if (revealedCard == null) {
      return this;
    }

    if (canComplete(revealedCard)) {
      return copyWith(
        revealedDeck: [...revealedDeck]..removeLast(),
        completedCards: {
          ...completedCards,
          revealedCard.suit: [...completedCards[revealedCard.suit]!, revealedCard],
        },
      );
    }

    return this;
  }

  bool canMove(List<SuitedCard> cards, int newColumn) {
    final newColumnCard = revealedCards[newColumn].lastOrNull;
    final topMostCard = cards.first;

    return (newColumnCard == null && topMostCard.value == KingSuitedCardValue()) ||
        (newColumnCard != null &&
            getCardValue(topMostCard) + 1 == getCardValue(newColumnCard) &&
            newColumnCard.suit.color != topMostCard.suit.color);
  }

  SolitaireState withMove(List<SuitedCard> cards, dynamic oldColumn, int newColumn) {
    return oldColumn == 'revealed-deck'
        ? withMoveFromDeck(cards, newColumn)
        : withMoveFromColumn(cards, oldColumn, newColumn);
  }

  SolitaireState withMoveFromColumn(List<SuitedCard> cards, int oldColumn, int newColumn) {
    final newRevealedCards = [...revealedCards];
    newRevealedCards[oldColumn] =
        newRevealedCards[oldColumn].sublist(0, newRevealedCards[oldColumn].length - cards.length);
    newRevealedCards[newColumn] = [...newRevealedCards[newColumn], ...cards];

    final newHiddenCards = [...hiddenCards];

    final lastHiddenCard = hiddenCards[oldColumn].lastOrNull;
    if (newRevealedCards[oldColumn].isEmpty && lastHiddenCard != null) {
      newRevealedCards[oldColumn] = [lastHiddenCard];
      newHiddenCards[oldColumn] = [...newHiddenCards[oldColumn]]..removeLast();
    }

    return copyWith(
      revealedCards: newRevealedCards,
      hiddenCards: newHiddenCards,
    );
  }

  SolitaireState withMoveFromDeck(List<SuitedCard> cards, int newColumn) {
    final newRevealedCards = [...revealedCards];
    newRevealedCards[newColumn] = [...newRevealedCards[newColumn], ...cards];

    final newRevealedDeck = [...revealedDeck]..removeLast();

    return copyWith(
      revealedCards: newRevealedCards,
      revealedDeck: newRevealedDeck,
    );
  }

  SolitaireState copyWith({
    List<List<SuitedCard>>? hiddenCards,
    List<List<SuitedCard>>? revealedCards,
    List<SuitedCard>? deck,
    List<SuitedCard>? revealedDeck,
    Map<CardSuit, List<SuitedCard>>? completedCards,
  }) {
    return SolitaireState(
      hiddenCards: hiddenCards ?? this.hiddenCards,
      revealedCards: revealedCards ?? this.revealedCards,
      deck: deck ?? this.deck,
      revealedDeck: revealedDeck ?? this.revealedDeck,
      completedCards: completedCards ?? this.completedCards,
    );
  }
}

class Solitaire extends HookWidget {
  const Solitaire({super.key});

  @override
  Widget build(BuildContext context) {
    final state = useState(SolitaireState.initialState);

    return CardGame<SuitedCard, dynamic>(
      style: deckStyle(sizeMultiplier: 0.84),
      children: [
        Column(
          children: [
            Row(
              children: [
                SizedBox(width: 8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => state.value = state.value.withDrawOrRefresh(),
                  child: CardDeck<SuitedCard, dynamic>.flipped(
                    value: 'deck',
                    values: state.value.deck,
                  ),
                ),
                SizedBox(width: 8),
                CardDeck<SuitedCard, dynamic>(
                  value: 'revealed-deck',
                  values: state.value.revealedDeck,
                  canMoveCardHere: (_) => false,
                  onCardPressed: (card) => state.value = state.value.withAttemptToCompleteFromDeck(),
                  canGrab: true,
                ),
                Spacer(),
                ...state.value.completedCards.entries.expand((entry) => [
                      CardDeck<SuitedCard, dynamic>(
                        value: 'completed-cards: ${entry.key}',
                        values: entry.value,
                        canGrab: false,
                      ),
                      SizedBox(width: 8),
                    ]),
              ],
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final hiddenCards = state.value.hiddenCards[i];
                final revealedCards = state.value.revealedCards[i];

                return CardColumn<SuitedCard, dynamic>(
                  value: i,
                  values: hiddenCards + revealedCards,
                  canCardBeGrabbed: (_, card) => revealedCards.contains(card),
                  isCardFlipped: (_, card) => hiddenCards.contains(card),
                  onCardPressed: (card) {
                    if (hiddenCards.contains(card)) {
                      return;
                    }

                    state.value = state.value.withAttemptToComplete(i, card);
                  },
                  canMoveCardHere: (move) => state.value.canMove(move.cardValues, i),
                  onCardMovedHere: (move) =>
                      state.value = state.value.withMove(move.cardValues, move.fromGroupValue, i),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}
