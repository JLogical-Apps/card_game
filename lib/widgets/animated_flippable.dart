import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedFlippable extends StatelessWidget {
  final Widget front;
  final Widget back;
  final bool isFlipped;

  final Duration duration;
  final Curve curve;

  const AnimatedFlippable({
    super.key,
    required this.front,
    required this.back,
    required this.isFlipped,
    required this.duration,
    required this.curve,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isFlipped ? 180 : 0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        final showFront = value < 90;
        return Transform(
          transform: Matrix4.identity()..rotateY(value * pi / 180),
          alignment: Alignment.center,
          child: showFront
              ? front
              : Transform(
                  transform: Matrix4.identity()..rotateY(pi),
                  alignment: Alignment.center,
                  child: back,
                ),
        );
      },
    );
  }
}
