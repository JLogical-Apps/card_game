## 2.0.0
- Cards automatically respond to sizing and builder changes.
  - Card layouts adapt seamlessly to screen rotations and display size changes.
- Improved animations and interactions when cards move between groups.
  - Cards animating between groups now appear on top of all other cards.
  - Animated cards cannot be clicked while in motion.
- Replaced the `playing_cards` dependency with open-source SVGs.
- Added support for styling empty groups (e.g., add silhouettes of suits in Solitaire).
- Exported `AnimatedFlippable` widget to make custom card style creation easier.
- Added `SuitedCardDistanceMapper.aceToKing` for games that don't allow rollover from ace to king.

## 1.1.1

- Slight visual improvements to cards.
- Cards do not clip when dragged outside of the `CardGame`.
- The example project will adapt to a variety of screen sizes.

## 1.1.0

Card Rows/Columns will compress to ensure that all their cards can fit within the allocated constraints.

## 1.0.2

Remove `flutter_hooks` dependency. It's still used in the example projects though.

## 1.0.1

README and pubspec.yaml updates.

## 1.0.0

Initial release