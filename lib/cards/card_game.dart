import 'package:cards/cards/card.dart';
import 'package:cards/cards/card_group.dart';
import 'package:cards/cards/card_move_details.dart';
import 'package:cards/cards/card_state.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

class CardGame<T extends Object, G> extends HookWidget {
  final Size cardSize;
  final Widget Function(T, CardState) cardBuilder;
  final List<CardGroup<T, G>> cardGroups;
  final Widget Function(CardState) emptyGroupBuilder;

  final Function(CardMoveDetails<T, G>, G newGroupValue) onCardMoved;

  const CardGame({
    super.key,
    required this.cardSize,
    required this.cardBuilder,
    required this.cardGroups,
    required this.emptyGroupBuilder,
    required this.onCardMoved,
  });

  Widget buildCardContent(T value, CardState state) => cardBuilder(value, state);

  Widget buildEmptyGroup(CardState state) => emptyGroupBuilder(state);

  @override
  Widget build(BuildContext context) {
    final draggingState = useState<({CardGroup<T, G> group, int index, T value, Offset offset})?>(null);
    final draggingValue = draggingState.value;

    return Provider<CardGame<T, G>>.value(
      value: this,
      child: Stack(
        children: [
          ...cardGroups.map((group) => Positioned(
                key: ValueKey('${group.value} - empty'),
                left: group.position.dx,
                top: group.position.dy,
                width: cardSize.width,
                height: cardSize.height,
                child: DragTarget<CardMoveDetails<T, G>>(
                  onWillAcceptWithDetails: (details) => details.data.fromGroupValue != group.value,
                  onAcceptWithDetails: (details) => onCardMoved(details.data, group.value),
                  builder: (context, accepted, rejected) {
                    return buildEmptyGroup(accepted.isEmpty ? CardState.regular : CardState.highlighted);
                  },
                ),
              )),
          ...cardGroups
              .expand((group) => group.values.mapIndexed((i, value) => (group, i, value)))
              .groupListsBy((record) {
                final (group, i, value) = record;
                final isBeingDragged = draggingValue == null
                    ? false
                    : draggingValue.group
                        .getDraggableCardValues(draggingValue.index, draggingValue.value)
                        .contains(value);
                return isBeingDragged ? double.maxFinite : group.getPriority(i, value);
              })
              .entries
              .sortedBy((entry) => entry.key)
              .expand((groupedEntry) => groupedEntry.value.map((record) {
                    final (group, i, value) = record;
                    final isBeingDragged = draggingValue == null
                        ? false
                        : draggingValue.group
                            .getDraggableCardValues(draggingValue.index, draggingValue.value)
                            .contains(value);
                    return AnimatedPositioned(
                      key: ValueKey(value),
                      top: isBeingDragged
                          ? group.getOffset(i, value).dy + draggingState.value!.offset.dy
                          : group.getOffset(i, value).dy,
                      left: isBeingDragged
                          ? group.getOffset(i, value).dx + draggingState.value!.offset.dx
                          : group.getOffset(i, value).dx,
                      width: cardSize.width,
                      height: cardSize.height,
                      duration: isBeingDragged ? Duration.zero : Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      child: Card<T, G>(
                        value: value,
                        groupValue: group.value,
                        onCardMoved: onCardMoved,
                        draggableCardValues: group.getDraggableCardValues(i, value),
                        onDragUpdated: (offset) => draggingState.value = (
                          group: group,
                          index: i,
                          value: value,
                          offset: offset,
                        ),
                        onDragEnded: () => draggingState.value = null,
                      ),
                    );
                  })),
        ],
      ),
    );
  }
}
