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

  const CardGame({
    super.key,
    required this.style,
    required this.children,
  });

  @override
  State<CardGame<T, G>> createState() => _CardGameState<T, G>();
}

class _CardGameState<T extends Object, G> extends State<CardGame<T, G>> {
  ({CardMoveDetails<T, G> moveDetails, Offset offset})? draggingValue;
  Map<List<T>, DateTime> cardsAnimatingBack = {};

  @override
  Widget build(BuildContext context) {
    final draggingValue = this.draggingValue;

    return ChangeNotifierProvider<CardGameState<T, G>>(
      create: (_) => CardGameState(
        cardSize: widget.style.cardSize,
        cardBuilder: widget.style.cardBuilder,
        cardGroups: {},
      ),
      child: Builder(
        builder: (context) {
          final cardGameState = context.watch<CardGameState<T, G>>();
          return Stack(
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
                    final isBeingDragged = draggingValue?.moveDetails.cardValues.contains(value) ?? false;
                    final isAnimatingDragged = cardsAnimatingBack.entries.any((entry) =>
                        entry.key.contains(value) && DateTime.now().difference(entry.value).inMilliseconds < 300);
                    return isBeingDragged || isAnimatingDragged ? double.maxFinite : group.getPriority(i, value);
                  })
                  .entries
                  .sortedBy((entry) => entry.key)
                  .expand((groupedEntry) => groupedEntry.value.map((record) {
                        final (group, i, value) = record;
                        final cardGroupData = cardGameState.cardGroups[group.value]!;
                        final groupOffset = cardGroupData.offset;
                        final groupSize = cardGroupData.groupSize;
                        final isBeingDragged = draggingValue?.moveDetails.cardValues.contains(value) ?? false;

                        final canMoveCardHere = group.canMoveCardHere;
                        final onCardMovedHere = group.onCardMovedHere;

                        final cardOffset = group.getCardOffset(i, value, cardGameState.cardSize, groupSize);

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
                            onPressed: () => group.onCardPressed?.call(value),
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
    );
  }
}

class CardGameState<T extends Object, G> extends ChangeNotifier {
  final Size cardSize;
  final Map<G, ({CardGroup<T, G> group, Offset offset, Size groupSize})> cardGroups;
  final Widget Function(T, bool flipped, CardState) cardBuilder;

  CardGameState({
    required this.cardSize,
    required this.cardGroups,
    required this.cardBuilder,
  });

  void setCardGroup(CardGroup<T, G> group, Offset offset, Size groupSize) {
    final currentValue = cardGroups[group.value];
    if (currentValue?.group == group.value &&
        currentValue?.offset == offset &&
        currentValue?.groupSize == groupSize) {
      return;
    }

    cardGroups[group.value] = (group: group, offset: offset, groupSize: groupSize);
    notifyListeners();
  }

  Widget buildCardContent(T value, bool flipped, CardState state) => cardBuilder(value, flipped, state);
}
