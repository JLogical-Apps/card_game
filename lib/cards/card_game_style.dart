import 'package:cards/cards/card_state.dart';
import 'package:flutter/material.dart';

class CardGameStyle<T> {
  final Size cardSize;
  final Widget Function(T, bool flipped, CardState) cardBuilder;
  final Widget Function(CardState) emptyGroupBuilder;

  CardGameStyle({
    required this.cardSize,
    required this.cardBuilder,
    required this.emptyGroupBuilder,
  });

  Widget buildEmptyGroup(CardState state) => emptyGroupBuilder(state);
}
