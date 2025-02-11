import 'package:card_game/src/cards/card_game_style.dart';
import 'package:card_game/src/cards/card_state.dart';
import 'package:card_game/src/cards/suited_cards/suited_card.dart';
import 'package:card_game/src/cards/suited_cards/suited_card_builder.dart';
import 'package:card_game/src/widgets/animated_flippable.dart';
import 'package:flutter/material.dart';

CardGameStyle<SuitedCard> deckCardStyle({double sizeMultiplier = 1}) => CardGameStyle(
      cardSize: Size(64, 89) * sizeMultiplier,
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
      cardBuilder: (value, flipped, cardState) => AnimatedFlippable(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        isFlipped: flipped,
        front: Stack(
          fit: StackFit.expand,
          children: [
            SuitedCardBuilder(card: value),
            Center(
              child: AnimatedContainer(
                margin: EdgeInsets.all(2),
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                  color: switch (cardState) {
                    CardState.regular => null,
                    CardState.highlighted => Color(0xFF9FC7FF).withValues(alpha: 0.5),
                    CardState.error => Color(0xFFFFADAD).withValues(alpha: 0.5),
                  },
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        back: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
          ),
        ),
      ),
    );
