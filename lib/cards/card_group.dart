import 'package:cards/cards/card_game.dart';
import 'package:cards/utils/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

abstract class CardGroup<T extends Object, G> extends HookWidget {
  final G value;
  final List<T> values;

  final Function(T)? onCardPressed;

  int getPriority(int index, T value);
  Offset getCardOffset(int index, T value);
  List<T>? getDraggableCardValues(int index, T value) {
    return [value];
  }

  bool isFlipped(int index, T value) => false;
  bool canBeDraggedOnto(int index, T value) => false;

  const CardGroup({
    super.key,
    required this.value,
    required this.values,
    this.onCardPressed,
  });
}

class CardLinearGroup<T extends Object, G> extends CardGroup<T, G> {
  final bool Function(int index, T value)? isCardFlipped;

  final Offset cardOffset;
  final int? maxGrabStackSize;

  const CardLinearGroup({
    super.key,
    required super.value,
    required super.values,
    super.onCardPressed,
    this.isCardFlipped,
    required this.cardOffset,
    required this.maxGrabStackSize,
  });

  @override
  Widget build(BuildContext context) {
    final cardGameState = context.watch<CardGameState<T, G>>();
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final cardGameContext =
            context.findAncestorContextOfType<CardGame<T, G>>() ?? (throw Exception('Must be in a CardGame!'));
        final cardGameRenderBox = cardGameContext.findRenderObject() as RenderBox;
        final myRenderBox = context.findRenderObject() as RenderBox;

        final relativeOffset = myRenderBox.localToGlobal(Offset.zero, ancestor: cardGameRenderBox);
        cardGameState.setCardGroup(this, relativeOffset);
      });
      return null;
    }, [values]);

    return SizedBox(width: cardGameState.cardSize.width, height: cardGameState.cardSize.height);
  }

  @override
  Offset getCardOffset(int index, T value) {
    return Offset(cardOffset.dx * index, cardOffset.dy * index);
  }

  @override
  int getPriority(int index, T value) {
    return index;
  }

  @override
  bool isFlipped(int index, T value) {
    return isCardFlipped?.call(index, value) ?? false;
  }

  @override
  List<T>? getDraggableCardValues(int index, T value) {
    final maxGrabStackSize = this.maxGrabStackSize;
    final grabStackSize = values.length - index;

    if (maxGrabStackSize == null || maxGrabStackSize >= grabStackSize) {
      return values.sublist(index);
    } else {
      return null;
    }
  }

  @override
  bool canBeDraggedOnto(int index, T value) {
    return index + 1 == values.length;
  }
}

class CardColumn<T extends Object, G> extends CardLinearGroup<T, G> {
  CardColumn({
    super.key,
    required super.value,
    required super.values,
    super.onCardPressed,
    super.isCardFlipped,
    super.maxGrabStackSize,
    double spacing = 20,
  }) : super(cardOffset: Offset(0, spacing));
}

class CardRow<T extends Object, G> extends CardLinearGroup<T, G> {
  CardRow({
    super.key,
    required super.value,
    required super.values,
    super.onCardPressed,
    super.isCardFlipped,
    super.maxGrabStackSize,
    double spacing = 20,
  }) : super(cardOffset: Offset(spacing, 0));
}

class CardDeck<T extends Object, G> extends CardLinearGroup<T, G> {
  const CardDeck({
    super.key,
    required super.value,
    required super.values,
    super.onCardPressed,
    super.isCardFlipped,
    bool canGrab = false,
  }) : super(cardOffset: Offset.zero, maxGrabStackSize: canGrab ? 1 : 0);
}
