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
}

class CardColumn<T extends Object, G> extends CardGroup<T, G> {
  @override
  final G value;

  @override
  final List<T> values;

  @override
  final Offset position;

  final int? maxGrabStackSize;
  final double spacing;

  CardColumn({
    required this.value,
    required this.values,
    required this.position,
    this.maxGrabStackSize,
    this.spacing = 20,
  });

  @override
  int getPriority(int index, T value) {
    return index;
  }

  @override
  Offset getOffset(int index, T value) {
    return position + Offset(0, index * spacing);
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
}
