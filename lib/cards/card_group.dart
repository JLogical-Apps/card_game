import 'dart:ui';

abstract class CardGroup<T extends Object, G> {
  G get value;
  List<T> get values;
  Offset get position;

  int getPriority(int index, T value);
  Offset getOffset(int index, T value);
  List<T>? getDraggableCardValues(int index, T value) {
    return [value];
  }

  bool isFlipped(int index, T value) => false;
  bool canBeDraggedOnto(int index, T value) => false;
}

class CardLinearGroup<T extends Object, G> extends CardGroup<T, G> {
  @override
  final G value;

  @override
  final List<T> values;

  @override
  final Offset position;

  final bool Function(int index, T value)? isCardFlipped;

  final Offset cardOffset;
  final int? maxGrabStackSize;

  CardLinearGroup({
    required this.value,
    required this.values,
    required this.position,
    this.isCardFlipped,
    required this.cardOffset,
    required this.maxGrabStackSize,
  });

  @override
  Offset getOffset(int index, T value) {
    return position + Offset(cardOffset.dx * index, cardOffset.dy * index);
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
    required super.value,
    required super.values,
    required super.position,
    super.isCardFlipped,
    super.maxGrabStackSize,
    double spacing = 20,
  }) : super(cardOffset: Offset(0, spacing));
}

class CardRow<T extends Object, G> extends CardLinearGroup<T, G> {
  CardRow({
    required super.value,
    required super.values,
    required super.position,
    super.isCardFlipped,
    super.maxGrabStackSize,
    double spacing = 20,
  }) : super(cardOffset: Offset(spacing, 0));
}

class CardDeck<T extends Object, G> extends CardLinearGroup<T, G> {
  CardDeck({
    required super.value,
    required super.values,
    required super.position,
    super.isCardFlipped,
    bool canGrab = false,
  }) : super(cardOffset: Offset.zero, maxGrabStackSize: canGrab ? 1 : 0);
}
