import 'package:cards/cards/card_game.dart';
import 'package:cards/cards/card_move_details.dart';
import 'package:cards/cards/card_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

class Card<T extends Object, G> extends HookWidget {
  final T value;
  final G? groupValue;

  final List<T>? draggableCardValues;

  final Function(CardMoveDetails<T, G>, G newGroupValue) onCardMoved;
  final Function(Offset) onDragUpdated;
  final Function() onDragEnded;

  const Card({
    super.key,
    required this.value,
    this.groupValue,
    this.draggableCardValues,
    required this.onCardMoved,
    required this.onDragUpdated,
    required this.onDragEnded,
  });

  @override
  Widget build(BuildContext context) {
    final groupValue = this.groupValue;

    final dragStartOffset = useState<Offset?>(null);
    final cardGame = context.watch<CardGame<T, G>>();

    Widget widget = dragStartOffset.value != null || groupValue == null
        ? SizedBox(
            width: cardGame.cardSize.width,
            height: cardGame.cardSize.height,
            child: cardGame.buildCardContent(value, CardState.regular),
          )
        : DragTarget<CardMoveDetails<T, G>>(
            onWillAcceptWithDetails: (details) => details.data.fromGroupValue != groupValue,
            onAcceptWithDetails: (details) => onCardMoved(details.data, groupValue),
            builder: (context, accepted, rejected) {
              return SizedBox(
                width: cardGame.cardSize.width,
                height: cardGame.cardSize.height,
                child: cardGame.buildCardContent(value, accepted.isEmpty ? CardState.regular : CardState.highlighted),
              );
            },
          );

    if (groupValue != null) {
      widget = Draggable<CardMoveDetails<T, G>>(
        data: CardMoveDetails(cardValues: draggableCardValues ?? [value], fromGroupValue: groupValue as G),
        feedback: SizedBox.shrink(),
        childWhenDragging: IgnorePointer(child: widget),
        onDragUpdate: (details) {
          dragStartOffset.value ??= details.localPosition;
          onDragUpdated(details.localPosition - dragStartOffset.value!);
        },
        onDraggableCanceled: (_, __) {
          onDragEnded();
          dragStartOffset.value = null;
        },
        onDragCompleted: () {
          onDragEnded();
          dragStartOffset.value = null;
        },
        child: widget,
      );
    }

    return widget;
  }
}
