import 'package:cards/cards/card_game.dart';
import 'package:cards/cards/card_move_details.dart';
import 'package:cards/cards/card_state.dart';
import 'package:flutter/material.dart';

class Card<T extends Object, G> extends StatelessWidget {
  final T value;
  final G? groupValue;
  final CardState state;

  const Card({super.key, required this.value, this.groupValue, this.state = CardState.regular});

  @override
  Widget build(BuildContext context) {
    final cardGame = CardGame.of<T>(context);
    final widget = SizedBox(
      width: cardGame.cardSize.width,
      height: cardGame.cardSize.height,
      child: cardGame.buildCardContent(value, state),
    );

    return groupValue == null
        ? widget
        : Draggable<CardMoveDetails<T, G>>(
            data: CardMoveDetails(cardValue: value, fromGroupValue: groupValue as G),
            feedback: Material(color: Colors.transparent, child: widget),
            childWhenDragging: SizedBox.shrink(),
            child: widget,
          );
  }
}
