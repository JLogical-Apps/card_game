import 'package:cards/cards/card_state.dart';
import 'package:flutter/material.dart';

class CardGame<T> extends InheritedWidget {
  final Size cardSize;
  final Widget Function(T, CardState) cardBuilder;
  final Widget Function(CardState) emptyGroupBuilder;

  const CardGame({
    super.key,
    required this.cardSize,
    required this.cardBuilder,
    required this.emptyGroupBuilder,
    required super.child,
  });

  Widget buildCardContent(T value, CardState state) => cardBuilder(value, state);

  Widget buildEmptyGroup(CardState state) => emptyGroupBuilder(state);

  static CardGame<T> of<T>(BuildContext context) {
    final CardGame<T>? result = context.dependOnInheritedWidgetOfExactType<CardGame<T>>();
    assert(result != null, 'No CardGame found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(CardGame oldWidget) {
    return true;
  }
}
