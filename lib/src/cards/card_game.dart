import 'package:card_game/src/cards/card.dart';
import 'package:card_game/src/cards/card_game_style.dart';
import 'package:card_game/src/cards/card_group.dart';
import 'package:card_game/src/cards/card_move_details.dart';
import 'package:card_game/src/cards/card_state.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';

/// A widget that manages a card game where cards are of type [T] and groups are identified by type [G].
///
/// The [CardGame] widget serves as the foundation for creating card-based games. It handles card
/// animations, drag-and-drop interactions, and state management. Type parameter [T] represents the
/// type of values used for cards (e.g., [int] or [SuitedCard]), while [G] represents the type
/// used to uniquely identify card groups.
///
/// Example usage:
/// ```dart
/// CardGame<SuitedCard, String>(
///   style: deckCardStyle(),
///   children: [
///     CardColumn<SuitedCard, String>(
///       value: "column1",
///       values: [card1, card2, card3],
///     ),
///   ],
/// )
/// ```
class CardGame<T extends Object, G> extends StatefulWidget {
  /// The visual style configuration for the card game, including card appearance and dimensions.
  final CardGameStyle<T> style;

  /// The widgets that make up the game layout, wrapped in a [Stack].
  /// Should include [CardGroup] widgets like [CardColumn], [CardRow], or [CardDeck].
  final List<Widget> children;

  /// Unique identifier for a game.
  /// Use this whenever a new game is started or restarted so that card layering
  /// is predictable during the reshuffle.
  final Object? gameKey;

  const CardGame({
    super.key,
    required this.style,
    required this.children,
    this.gameKey,
  });

  @override
  State<CardGame<T, G>> createState() => _CardGameState<T, G>();
}

class _CardGameState<T extends Object, G> extends State<CardGame<T, G>> {
  late Object? gameKey = widget.gameKey;
  DateTime lastGameStarted = DateTime.now();

  ({CardMoveDetails<T, G> moveDetails, Offset offset})? draggingValue;
  Map<List<T>, DateTime> cardsAnimatingBack = {};

  Map<T, G> cardByGroup = {};
  Map<T, DateTime> cardsAnimatingThroughGroups = {};

  @override
  void didUpdateWidget(covariant CardGame<T, G> oldWidget) {
    if (gameKey != widget.gameKey) {
      gameKey = widget.gameKey;
      cardByGroup.clear();
      cardsAnimatingThroughGroups.clear();
      lastGameStarted = DateTime.now();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final draggingValue = this.draggingValue;

    return Provider<CardGameStyle<T>>.value(
      value: widget.style,
      child: ChangeNotifierProvider<CardGameState<T, G>>(
        create: (_) => CardGameState(cardGroups: {}),
        child: Builder(
          builder: (context) {
            final cardGameState = context.watch<CardGameState<T, G>>();
            return Stack(
              clipBehavior: Clip.none,
              children: [
                ...cardGameState.cardGroups.entries
                    .where((entry) => cardGameState.cardGroups.containsKey(entry.key))
                    .map((entry) {
                  final (:group, :offset, :groupSize) = entry.value;
                  final canMoveCardHere = group.canMoveCardHere;
                  final onCardMoved = group.onCardMovedHere;

                  return AnimatedPositioned(
                    key: ValueKey('${group.value} - empty'),
                    left: offset.dx,
                    top: offset.dy,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    width: widget.style.cardSize.width,
                    height: widget.style.cardSize.height,
                    child: onCardMoved == null ||
                            draggingValue != null && draggingValue.moveDetails.fromGroupValue == group.value
                        ? widget.style.buildEmptyGroup(CardState.regular)
                        : DragTarget<CardMoveDetails<T, G>>(
                            onWillAcceptWithDetails: (details) =>
                                details.data.fromGroupValue != group.value &&
                                (canMoveCardHere?.call(details.data) ?? false),
                            onAcceptWithDetails: (details) => onCardMoved(details.data),
                            builder: (context, accepted, rejected) => widget.style.buildEmptyGroup(
                              accepted.isNotEmpty
                                  ? CardState.highlighted
                                  : rejected.isNotEmpty
                                      ? CardState.error
                                      : CardState.regular,
                            ),
                          ),
                  );
                }),
                ...cardGameState.cardGroups.entries
                    .where((entry) => cardGameState.cardGroups.containsKey(entry.key))
                    .expand((entry) => entry.value.group.values.mapIndexed((i, value) => (entry.value.group, i, value)))
                    .groupListsBy((record) {
                      final (group, i, value) = record;

                      // Handle cards updating groups.
                      if (cardByGroup[value] != null && cardByGroup[value] != group.value) {
                        cardsAnimatingThroughGroups[value] = DateTime.now();
                        cardByGroup[value] = group.value;
                      } else if (cardByGroup[value] == null) {
                        cardByGroup[value] = group.value;
                      }

                      final isReshuffling = DateTime.now().difference(lastGameStarted).inMilliseconds < 300;

                      final animatingThroughGroupValue = cardsAnimatingThroughGroups[value];
                      final isAnimatingThroughGroups = animatingThroughGroupValue != null &&
                          DateTime.now().difference(animatingThroughGroupValue).inMilliseconds < 300;

                      final isBeingDragged = draggingValue?.moveDetails.cardValues.contains(value) ?? false;
                      final isAnimatingDragged = cardsAnimatingBack.entries.any((entry) =>
                          entry.key.contains(value) && DateTime.now().difference(entry.value).inMilliseconds < 300);
                      final priorityInGroup = group.getPriority(i, value);

                      return isBeingDragged || isAnimatingDragged
                          ? double.maxFinite
                          : (priorityInGroup + (isAnimatingThroughGroups && !isReshuffling ? 1000 : 0));
                    })
                    .entries
                    .sortedBy((entry) => entry.key)
                    .expand((groupedEntry) => groupedEntry.value.map((record) {
                          final (group, i, value) = record;
                          final cardGroupData = cardGameState.cardGroups[group.value]!;
                          final groupOffset = cardGroupData.offset;
                          final groupSize = cardGroupData.groupSize;
                          final isBeingDragged = draggingValue?.moveDetails.cardValues.contains(value) ?? false;

                          final animatingThroughGroupValue = cardsAnimatingThroughGroups[value];
                          final isAnimatingThroughGroups = animatingThroughGroupValue != null &&
                              DateTime.now().difference(animatingThroughGroupValue).inMilliseconds < 300;

                          final canMoveCardHere = group.canMoveCardHere;
                          final onCardMovedHere = group.onCardMovedHere;

                          final cardOffset = group.getCardOffset(i, value, widget.style.cardSize, groupSize);

                          return AnimatedPositioned(
                            key: ValueKey(value),
                            top: isBeingDragged
                                ? groupOffset.dy + cardOffset.dy + draggingValue!.offset.dy
                                : groupOffset.dy + cardOffset.dy,
                            left: isBeingDragged
                                ? groupOffset.dx + cardOffset.dx + draggingValue!.offset.dx
                                : groupOffset.dx + cardOffset.dx,
                            width: widget.style.cardSize.width,
                            height: widget.style.cardSize.height,
                            duration: isBeingDragged ? Duration.zero : Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
                            child: Card<T, G>(
                              value: value,
                              group: group,
                              flipped: group.isCardFlipped?.call(i, value) ?? false,
                              canBeDraggedOnto: group.canBeDraggedOnto(i, value),
                              currentlyDraggedCard: draggingValue?.moveDetails,
                              canMoveCardHere: (move) => canMoveCardHere?.call(move) ?? onCardMovedHere != null,
                              onCardMovedHere: onCardMovedHere == null ? null : (move) => onCardMovedHere(move),
                              onPressed: isAnimatingThroughGroups ? null : () => group.onCardPressed?.call(value),
                              draggableCardValues: group.getDraggableCardValues(i, value),
                              onDragUpdated: (moveDetails, offset) => setState(() => this.draggingValue = (
                                    moveDetails: moveDetails,
                                    offset: offset,
                                  )),
                              onDragEnded: () => setState(() {
                                this.draggingValue = null;
                                cardsAnimatingBack = {
                                  ...cardsAnimatingBack,
                                  group.getDraggableCardValues(i, value)!: DateTime.now(),
                                };
                              }),
                            ),
                          );
                        })),
                Stack(children: widget.children),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CardGameState<T extends Object, G> extends ChangeNotifier {
  final Map<G, ({CardGroup<T, G> group, Offset offset, Size groupSize})> cardGroups;

  CardGameState({required this.cardGroups});

  void setCardGroup(CardGroup<T, G> group, Offset offset, Size groupSize) {
    final currentValue = cardGroups[group.value];
    if (currentValue?.group == group.value && currentValue?.offset == offset && currentValue?.groupSize == groupSize) {
      return;
    }

    cardGroups[group.value] = (group: group, offset: offset, groupSize: groupSize);
    notifyListeners();
  }
}
