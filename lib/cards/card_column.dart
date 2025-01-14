import 'package:cards/cards/card.dart';
import 'package:cards/cards/card_game.dart';
import 'package:cards/cards/card_move_details.dart';
import 'package:cards/cards/card_state.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Card;

class CardColumn<T extends Object, G> extends StatelessWidget {
  final List<T> cards;
  final G? groupValue;
  final Function(CardMoveDetails<T, G>)? onCardAdded;

  const CardColumn({super.key, required this.cards, this.groupValue, this.onCardAdded});

  @override
  Widget build(BuildContext context) {
    return onCardAdded == null
        ? _buildCards(context)
        : DragTarget<CardMoveDetails<T, G>>(
            hitTestBehavior: HitTestBehavior.deferToChild,
            onWillAcceptWithDetails: (details) => details.data.fromGroupValue != groupValue,
            onAcceptWithDetails: (details) => onCardAdded!.call(details.data),
            builder: (context, accepted, rejected) => _buildCards(context, isDraggedOver: accepted.isNotEmpty),
          );
  }

  Widget _buildCards(BuildContext context, {bool isDraggedOver = false}) {
    final cardGame = CardGame.of<T>(context);

    return SizedBox(
      width: cardGame.cardSize.width,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: cardGame.cardSize.height,
            child: cardGame.buildEmptyGroup(isDraggedOver && cards.isEmpty ? CardState.highlighted : CardState.regular),
          ),
          ...cards.mapIndexed((i, card) => Positioned(
                left: 0,
                right: 0,
                top: i * 10,
                child: Card<T, G>(
                  value: card,
                  groupValue: groupValue,
                  state: isDraggedOver && i + 1 == cards.length ? CardState.highlighted : CardState.regular,
                ),
              )),
        ],
      ),
    );
  }
}
