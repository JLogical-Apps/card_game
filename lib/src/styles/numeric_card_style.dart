import 'package:card_game/src/cards/card_game_style.dart';
import 'package:card_game/src/cards/card_state.dart';
import 'package:flutter/material.dart';

CardGameStyle<int> numericCardStyle({double sizeMultiplier = 1}) => CardGameStyle(
      cardSize: Size(80, 120) * sizeMultiplier,
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
      cardBuilder: (value, flipped, state) => AnimatedContainer(
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
    );
