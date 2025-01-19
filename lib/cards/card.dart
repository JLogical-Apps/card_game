import 'package:cards/cards/card_game.dart';
import 'package:cards/cards/card_move_details.dart';
import 'package:cards/cards/card_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

class Card<T extends Object, G> extends HookWidget {
  final T value;
  final G? groupValue;

  final bool flipped;

  final CardMoveDetails<T, G>? currentlyDraggedCard;

  final bool canBeDraggedOnto;
  final Function()? onPressed;
  final bool Function(CardMoveDetails<T, G>, G newGroupValue)? canMoveCard;
  final Function(CardMoveDetails<T, G>, G newGroupValue)? onCardMoved;
  final Function(CardMoveDetails<T, G>, Offset) onDragUpdated;
  final Function() onDragEnded;
  final List<T>? draggableCardValues;

  const Card({
    super.key,
    required this.value,
    this.groupValue,
    required this.flipped,
    this.canBeDraggedOnto = false,
    this.currentlyDraggedCard,
    this.draggableCardValues,
    this.onPressed,
    this.canMoveCard,
    this.onCardMoved,
    required this.onDragUpdated,
    required this.onDragEnded,
  });

  @override
  Widget build(BuildContext context) {
    final groupValue = this.groupValue;
    final draggableCardValues = this.draggableCardValues;
    final onCardMoved = this.onCardMoved;

    final dragStartOffset = useState<Offset?>(null);
    final cardGameState = context.watch<CardGameState<T, G>>();

    Widget widget = onCardMoved == null ||
            dragStartOffset.value != null ||
            groupValue == null ||
            currentlyDraggedCard?.fromGroupValue == groupValue ||
            !canBeDraggedOnto
        ? cardGameState.buildCardContent(value, flipped, CardState.regular)
        : DragTarget<CardMoveDetails<T, G>>(
            onWillAcceptWithDetails: (details) =>
                details.data.fromGroupValue != groupValue && (canMoveCard?.call(details.data, groupValue) ?? true),
            onAcceptWithDetails: (details) => onCardMoved(details.data, groupValue),
            builder: (context, accepted, rejected) {
              return cardGameState.buildCardContent(
                value,
                flipped,
                accepted.isNotEmpty
                    ? CardState.highlighted
                    : rejected.isNotEmpty
                        ? CardState.error
                        : CardState.regular,
              );
            },
          );

    if (onPressed != null) {
      widget = GestureDetector(onTap: onPressed, child: widget);
    }

    if (groupValue != null && draggableCardValues != null) {
      final cardMoveDetails = CardMoveDetails<T, G>(
        cardValues: draggableCardValues,
        fromGroupValue: groupValue as G,
      );
      widget = Draggable<CardMoveDetails<T, G>>(
        data: cardMoveDetails,
        feedback: SizedBox.shrink(),
        childWhenDragging: IgnorePointer(child: widget),
        onDragUpdate: (details) {
          dragStartOffset.value ??= details.localPosition;
          onDragUpdated(cardMoveDetails, details.localPosition - dragStartOffset.value!);
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
