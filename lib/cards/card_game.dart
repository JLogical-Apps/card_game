import 'package:cards/cards/card.dart';
import 'package:cards/cards/card_game_style.dart';
import 'package:cards/cards/card_group.dart';
import 'package:cards/cards/card_move_details.dart';
import 'package:cards/cards/card_state.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

class CardGame<T extends Object, G> extends HookWidget {
  final CardGameStyle<T> style;
  final List<Widget> children;

  final bool Function(CardMoveDetails<T, G>, G newGroupValue)? canMoveCard;
  final Function(CardMoveDetails<T, G>, G newGroupValue)? onCardMoved;

  const CardGame({
    super.key,
    required this.style,
    required this.children,
    this.canMoveCard,
    this.onCardMoved,
  });

  @override
  Widget build(BuildContext context) {
    final onCardMoved = this.onCardMoved;

    final draggingState = useState<({CardMoveDetails<T, G> moveDetails, Offset offset})?>(null);
    final draggingValue = draggingState.value;

    return ChangeNotifierProvider<CardGameState<T, G>>(
      create: (_) => CardGameState(
        cardSize: style.cardSize,
        cardBuilder: style.cardBuilder,
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
                final (:group, :offset) = entry.value;
                return AnimatedPositioned(
                  key: ValueKey('${group.value} - empty'),
                  left: offset.dx,
                  top: offset.dy,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  width: style.cardSize.width,
                  height: style.cardSize.height,
                  child: onCardMoved == null ||
                          draggingValue != null && draggingValue.moveDetails.fromGroupValue == group.value
                      ? style.buildEmptyGroup(CardState.regular)
                      : DragTarget<CardMoveDetails<T, G>>(
                          onWillAcceptWithDetails: (details) => details.data.fromGroupValue != group.value,
                          onAcceptWithDetails: (details) => onCardMoved(details.data, group.value),
                          builder: (context, accepted, rejected) => style.buildEmptyGroup(
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
                    return isBeingDragged ? double.maxFinite : group.getPriority(i, value);
                  })
                  .entries
                  .sortedBy((entry) => entry.key)
                  .expand((groupedEntry) => groupedEntry.value.map((record) {
                        final (group, i, value) = record;
                        final groupOffset = cardGameState.cardGroups[group.value]!.offset;
                        final isBeingDragged = draggingValue?.moveDetails.cardValues.contains(value) ?? false;
                        return AnimatedPositioned(
                          key: ValueKey(value),
                          top: isBeingDragged
                              ? groupOffset.dy + group.getCardOffset(i, value).dy + draggingState.value!.offset.dy
                              : groupOffset.dy + group.getCardOffset(i, value).dy,
                          left: isBeingDragged
                              ? groupOffset.dx + group.getCardOffset(i, value).dx + draggingState.value!.offset.dx
                              : groupOffset.dx + group.getCardOffset(i, value).dx,
                          width: style.cardSize.width,
                          height: style.cardSize.height,
                          duration: isBeingDragged ? Duration.zero : Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          child: Card<T, G>(
                            value: value,
                            groupValue: group.value,
                            flipped: group.isFlipped(i, value),
                            canBeDraggedOnto: group.canBeDraggedOnto(i, value),
                            currentlyDraggedCard: draggingValue?.moveDetails,
                            canMoveCard: canMoveCard,
                            onCardMoved: onCardMoved,
                            onPressed: () => group.onCardPressed?.call(value),
                            draggableCardValues: group.getDraggableCardValues(i, value),
                            onDragUpdated: (moveDetails, offset) => draggingState.value = (
                              moveDetails: moveDetails,
                              offset: offset,
                            ),
                            onDragEnded: () => draggingState.value = null,
                          ),
                        );
                      })),
              Stack(children: children),
            ],
          );
        },
      ),
    );
  }
}

class CardGameState<T extends Object, G> extends ChangeNotifier {
  final Size cardSize;
  final Map<G, ({CardGroup<T, G> group, Offset offset})> cardGroups;
  final Widget Function(T, bool flipped, CardState) cardBuilder;

  CardGameState({
    required this.cardSize,
    required this.cardGroups,
    required this.cardBuilder,
  });

  void setCardGroup(CardGroup<T, G> group, Offset offset) {
    final currentValue = cardGroups[group.value];
    if (currentValue?.group == group.value && currentValue?.offset == offset) {
      return;
    }

    cardGroups[group.value] = (group: group, offset: offset);
    notifyListeners();
  }

  Widget buildCardContent(T value, bool flipped, CardState state) => cardBuilder(value, flipped, state);
}
