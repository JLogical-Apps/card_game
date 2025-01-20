class CardMoveDetails<T, G> {
  final List<T> cardValues;
  final G fromGroupValue;

  const CardMoveDetails({required this.cardValues, required this.fromGroupValue});
}
