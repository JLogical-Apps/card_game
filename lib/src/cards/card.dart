import 'package:card_game/src/cards/card_game_style.dart';
import 'package:card_game/src/cards/card_group.dart';
import 'package:card_game/src/cards/card_move_details.dart';
import 'package:card_game/src/cards/card_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Card<T extends Object, G> extends StatefulWidget {
  final T value;
  final CardGroup<T, G> group;

  final bool flipped;

  final CardMoveDetails<T, G>? currentlyDraggedCard;

  final bool canBeDraggedOnto;
  final Function()? onPressed;
  final bool Function(CardMoveDetails<T, G>) canMoveCardHere;
  final Function(CardMoveDetails<T, G>)? onCardMovedHere;
  final Function(CardMoveDetails<T, G>, Offset) onDragUpdated;
  final Function() onDragEnded;
  final List<T>? draggableCardValues;

  const Card({
    super.key,
    required this.value,
    required this.group,
    required this.flipped,
    this.canBeDraggedOnto = false,
    this.currentlyDraggedCard,
    this.draggableCardValues,
    this.onPressed,
    required this.canMoveCardHere,
    this.onCardMovedHere,
    required this.onDragUpdated,
    required this.onDragEnded,
  });

  @override
  State<Card<T, G>> createState() => _CardState<T, G>();
}

class _CardState<T extends Object, G> extends State<Card<T, G>> {
  Offset? dragStartOffset;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final draggableCardValues = widget.draggableCardValues;
    final onCardMoved = widget.onCardMovedHere;

    final cardStyle = context.watch<CardGameStyle<T, G>>();

    final disableDrags = onCardMoved == null ||
        dragStartOffset != null ||
        widget.currentlyDraggedCard?.fromGroupValue == group.value ||
        !widget.canBeDraggedOnto;
    Widget cardWidget = DragTarget<CardMoveDetails<T, G>>(
      onWillAcceptWithDetails: disableDrags
          ? null
          : (details) => details.data.fromGroupValue != group.value && widget.canMoveCardHere(details.data),
      onAcceptWithDetails: disableDrags ? null : (details) => onCardMoved(details.data),
      builder: (context, accepted, rejected) {
        return cardStyle.buildCardContent(
          widget.value,
          group.value,
          widget.flipped,
          disableDrags
              ? CardState.regular
              : accepted.isNotEmpty
                  ? CardState.highlighted
                  : rejected.isNotEmpty
                      ? CardState.error
                      : CardState.regular,
        );
      },
    );

    cardWidget = GestureDetector(onTap: widget.onPressed, child: cardWidget);

    final cardMoveDetails = draggableCardValues == null
        ? null
        : CardMoveDetails<T, G>(cardValues: draggableCardValues, fromGroupValue: group.value);
    cardWidget = Draggable<CardMoveDetails<T, G>>(
      data: cardMoveDetails,
      feedback: SizedBox.shrink(),
      childWhenDragging: IgnorePointer(child: cardWidget),
      onDragUpdate: cardMoveDetails == null
          ? null
          : (details) {
              dragStartOffset ??= details.localPosition;
              widget.onDragUpdated(cardMoveDetails, details.localPosition - dragStartOffset!);
            },
      onDraggableCanceled: (_, __) {
        widget.onDragEnded();
        dragStartOffset = null;
      },
      onDragCompleted: () {
        widget.onDragEnded();
        dragStartOffset = null;
      },
      maxSimultaneousDrags: cardMoveDetails == null ? 0 : 1,
      child: cardWidget,
    );

    return cardWidget;
  }
}
