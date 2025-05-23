import 'package:card_game/card_game.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TowerOfHanoi extends HookWidget {
  final int amount;

  const TowerOfHanoi({super.key, this.amount = 4});

  List<List<int>> get initialCards => [
        List.generate(amount, (i) => amount - i),
        <int>[],
        <int>[],
      ];

  @override
  Widget build(BuildContext context) {
    final cardsState = useState(initialCards);

    return CardGame<int, int>(
      style: numericCardStyle(),
      children: [
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: cardsState.value
                      .mapIndexed((i, states) => CardColumn<int, int>(
                            value: i,
                            values: states,
                            maxGrabStackSize: 1,
                            canMoveCardHere: (move) {
                              final movingCard = move.cardValues.last;
                              final movingOnto = states.lastOrNull;
                              return movingOnto == null || movingCard < movingOnto;
                            },
                            onCardMovedHere: (move) {
                              final newCards = [...cardsState.value];
                              newCards[move.fromGroupValue].removeLast();
                              newCards[i].add(move.cardValues.first);
                              cardsState.value = newCards;
                            },
                          ))
                      .toList(),
                ),
              ),
              ElevatedButton(
                onPressed: () => cardsState.value = initialCards,
                style: ButtonStyle(shape: WidgetStatePropertyAll(CircleBorder())),
                child: Icon(Icons.restart_alt),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
