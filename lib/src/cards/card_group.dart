import 'package:card_game/src/cards/card_game.dart';
import 'package:card_game/src/cards/card_move_details.dart';
import 'package:card_game/src/utils/build_context_extensions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Base class for all card group widgets in a [CardGame].
///
/// Card groups manage collections of cards and handle their interactions.
/// Type parameter [T] represents the card value type, while [G] is the group identifier type.
abstract class CardGroup<T extends Object, G> extends StatefulWidget {
  /// Unique identifier for this card group within the game.
  final G value;

  /// List of card values in this group, ordered from bottom to top.
  final List<T> values;

  /// Determines whether a specific card should be displayed face-down.
  ///
  /// If not provided, all cards are shown face-up.
  final bool Function(int index, T value)? isCardFlipped;

  /// Called when a card is tapped.
  final Function(T)? onCardPressed;

  /// Determines whether a stack of cards can be dropped onto this group.
  ///
  /// [details] contains information about the cards being moved and their source group.
  final bool Function(CardMoveDetails<T, G> details)? canMoveCardHere;

  /// Called when cards are successfully dropped onto this group.
  ///
  /// [details] contains information about the moved cards and their source group.
  final Function(CardMoveDetails<T, G> details)? onCardMovedHere;

  int getPriority(int index, T value);
  Offset getCardOffset(int index, T value);
  List<T>? getDraggableCardValues(int index, T value) {
    return [value];
  }

  bool canBeDraggedOnto(int index, T value) => false;

  const CardGroup({
    super.key,
    required this.value,
    required this.values,
    this.isCardFlipped,
    this.onCardPressed,
    this.canMoveCardHere,
    this.onCardMovedHere,
  });
}

/// Abstract base class for card groups that arrange cards in a linear fashion.
///
/// Extends [CardGroup] to add functionality for controlling card grabbing and stack size limits.
/// Used as the base class for [CardColumn], [CardRow], and [CardDeck].
class CardLinearGroup<T extends Object, G> extends CardGroup<T, G> {
  final Offset cardOffset;

  /// Determines whether a specific card can be grabbed for dragging.
  ///
  /// If not provided, cards cannot be grabbed.
  final bool Function(int index, T value)? canCardBeGrabbed;

  /// Maximum number of cards that can be grabbed and dragged at once.
  ///
  /// If null, no limit is applied.
  final int? maxGrabStackSize;

  const CardLinearGroup({
    super.key,
    required super.value,
    required super.values,
    super.onCardPressed,
    super.canMoveCardHere,
    super.onCardMovedHere,
    super.isCardFlipped,
    required this.cardOffset,
    this.canCardBeGrabbed,
    required this.maxGrabStackSize,
  });

  @override
  State<StatefulWidget> createState() => _CardLinearGroupState<T, G>();

  @override
  Offset getCardOffset(int index, T value) {
    return Offset(cardOffset.dx * index, cardOffset.dy * index);
  }

  @override
  int getPriority(int index, T value) {
    return index;
  }

  @override
  List<T>? getDraggableCardValues(int index, T value) {
    if (!(canCardBeGrabbed?.call(index, value) ?? true)) {
      return null;
    }

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

class _CardLinearGroupState<T extends Object, G> extends State<CardLinearGroup<T, G>> {
  @override
  void didUpdateWidget(covariant CardLinearGroup<T, G> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!DeepCollectionEquality().equals(oldWidget.values, widget.values)) {
      _updateCardGame();
    }
  }

  @override
  void initState() {
    super.initState();

    _updateCardGame();
  }

  @override
  Widget build(BuildContext context) {
    final cardGameState = context.watch<CardGameState<T, G>>();
    return SizedBox(width: cardGameState.cardSize.width, height: cardGameState.cardSize.height);
  }

  void _updateCardGame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cardGameState = context.read<CardGameState<T, G>>();
      final cardGameContext =
          context.findAncestorContextOfType<CardGame<T, G>>() ?? (throw Exception('Must be in a CardGame!'));
      final cardGameRenderBox = cardGameContext.findRenderObject() as RenderBox;
      final myRenderBox = context.findRenderObject() as RenderBox;

      final relativeOffset = myRenderBox.localToGlobal(Offset.zero, ancestor: cardGameRenderBox);
      cardGameState.setCardGroup(widget, relativeOffset);
    });
  }
}

/// Arranges cards vertically in a column.
class CardColumn<T extends Object, G> extends CardLinearGroup<T, G> {
  CardColumn({
    super.key,
    required super.value,
    required super.values,
    super.onCardPressed,
    super.canMoveCardHere,
    super.onCardMovedHere,
    super.isCardFlipped,
    super.canCardBeGrabbed,
    super.maxGrabStackSize,
    double spacing = 20,
  }) : super(cardOffset: Offset(0, spacing));
}

/// Arranges cards horizontally in a row.
class CardRow<T extends Object, G> extends CardLinearGroup<T, G> {
  CardRow({
    super.key,
    required super.value,
    required super.values,
    super.onCardPressed,
    super.canMoveCardHere,
    super.onCardMovedHere,
    super.isCardFlipped,
    super.canCardBeGrabbed,
    super.maxGrabStackSize,
    double spacing = 20,
  }) : super(cardOffset: Offset(spacing, 0));
}

/// Displays cards stacked on top of each other, showing only the topmost card.
///
/// Can be created as flipped using [CardDeck.flipped] to show cards face-down.
class CardDeck<T extends Object, G> extends CardLinearGroup<T, G> {
  const CardDeck({
    super.key,
    required super.value,
    required super.values,
    super.onCardPressed,
    super.canMoveCardHere,
    super.onCardMovedHere,
    super.isCardFlipped,
    bool canGrab = false,
  }) : super(cardOffset: Offset.zero, maxGrabStackSize: canGrab ? 1 : 0);

  CardDeck.flipped({
    super.key,
    required super.value,
    required super.values,
    super.onCardPressed,
    super.canMoveCardHere,
    super.onCardMovedHere,
    bool canGrab = false,
  }) : super(
          cardOffset: Offset.zero,
          maxGrabStackSize: canGrab ? 1 : 0,
          isCardFlipped: (_, __) => true,
        );
}
