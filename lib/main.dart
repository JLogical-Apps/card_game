import 'package:cards/cards/card_game.dart';
import 'package:cards/cards/card_group.dart';
import 'package:cards/cards/card_state.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  runApp(MaterialApp(
    title: 'Cards',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    ),
    home: HomePage(),
  ));
}

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cardsState = useState([
      [4, 3, 2, 1],
      <int>[],
      <int>[],
    ]);

    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: CardGame<int, int>(
          cardGroups: cardsState.value
              .mapIndexed(
                  (i, states) => CardColumn<int, int>(value: i, values: states, position: Offset(40 + i * 140, 0)))
              .toList(),
          canMoveCard: (move, newGroupValue) {
            final movingCard = move.cardValues.last;
            final movingOnto = cardsState.value[newGroupValue].lastOrNull;
            return movingOnto == null || movingCard < movingOnto;
          },
          onCardMoved: (move, newGroupValue) {
            final newCards = [...cardsState.value];
            newCards[move.fromGroupValue].removeWhere((card) => move.cardValues.contains(card));
            newCards[newGroupValue].addAll(move.cardValues);
            cardsState.value = newCards;
          },
          cardSize: Size(80, 120),
          emptyGroupBuilder: (state) => AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              color: switch (state) {
                CardState.regular => Colors.white,
                CardState.highlighted => Color(0xFF9FC7FF),
                CardState.error => Color(0xFFFFADAD),
              }
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          cardBuilder: (value, state) => AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              color: switch (state) {
                CardState.regular => Colors.white,
                CardState.highlighted => Color(0xFF9FC7FF),
                CardState.error => Color(0xFFFFADAD),
              },
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black,
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 3,
                  top: 1,
                  child: Text(value.toString()),
                ),
                Center(
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
