import 'dart:ui';

abstract class CardGroup<T extends Object, G> {
  G get value;
  List<T> get values;
  Offset get position;

  Offset getOffset(int index, T value);
}

class CardColumn<T extends Object, G> extends CardGroup<T, G> {
  @override
  final G value;

  @override
  final List<T> values;

  @override
  final Offset position;

  final double spacing;

  CardColumn({required this.value, required this.values, required this.position, this.spacing = 20});

  @override
  Offset getOffset(int index, T value) {
    return position + Offset(0, index * spacing);
  }
}
