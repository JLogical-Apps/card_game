import 'package:cards/cards/card_game_style.dart';
import 'package:cards/games/cards/suited_card.dart';
import 'package:cards/games/cards/suited_card_builder.dart';
import 'package:cards/widgets/animated_flippable.dart';
import 'package:flutter/material.dart';

CardGameStyle<SuitedCard> deckStyle({double sizeMultiplier = 1}) => CardGameStyle(
      cardSize: Size(64, 89) * sizeMultiplier,
      emptyGroupBuilder: (state) => AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      cardBuilder: (value, flipped, cardState) => AnimatedFlippable(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        isFlipped: flipped,
        front: SuitedCardBuilder(card: value),
        back: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
          ),
        ),
      ),
    );
