import 'package:cards/cards/card_column.dart';
import 'package:cards/cards/card_game.dart';
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
      [1, 2],
      [3, 4],
    ]);

    return CardGame<int>(
      cardSize: Size(80, 120),
      emptyGroupBuilder: (state) => AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          color: (state == CardState.regular ? Colors.white : Color(0xFF9FC7FF)).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      cardBuilder: (value, state) => AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          color: state == CardState.regular ? Colors.white : Color(0xFF9FC7FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(value.toString()),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.green,
        body: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cardsState.value
                .mapIndexed((i, cards) => CardColumn(
                      cards: cards,
                      groupValue: i,
                      onCardAdded: (cardMoveDetails) {
                        final newCards = [...cardsState.value];
                        newCards[cardMoveDetails.fromGroupValue].removeLast();
                        newCards[i].add(cardMoveDetails.cardValue);
                        cardsState.value = newCards;
                      },
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
