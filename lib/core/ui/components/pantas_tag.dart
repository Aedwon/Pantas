import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// The color of a [PantasTag].
enum PantasTagTone {
  /// `accent-tint` fill and `accent-tint-text`: "go here". The default.
  tint,

  /// `accent-fill` and `on-accent`: a strong status.
  solid,

  /// `fill` and `text-on-fill`: a neutral status.
  gray,

  /// `warning-tint` and `warning-tint-text`: caution, never a wrong answer.
  warning,
}

/// A status pill for one item: 12/600 text, padding 2 by 8, `radius-full`.
///
/// A tag names a status ("New", "Coming Soon"). It is not a button, an
/// eyebrow or a category label above a heading (D188), and it has one state:
/// no hover, press, focus or disabled look. Use two words at most.
class PantasTag extends StatelessWidget {
  const PantasTag(
    this.label, {
    this.tone = PantasTagTone.tint,
    super.key,
  });

  final String label;
  final PantasTagTone tone;

  /// The tag's drawn height for a text scale: the 12px line at 1.3 plus 2
  /// above and below. The SelectableTile slot reads it.
  static double heightFor(double scaledTwelve) =>
      scaledTwelve * (PantasType.webTag.height ?? 1) + PantasSpace.s2 * 2;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (fill, ink) = switch (tone) {
      PantasTagTone.tint => (c.accentTint, c.accentTintText),
      PantasTagTone.solid => (c.accentFill, c.onAccent),
      PantasTagTone.gray => (c.fill, c.textOnFill),
      PantasTagTone.warning => (c.warningTint, c.warningTintText),
    };
    return Container(
      key: const ValueKey('pantas-tag'),
      padding: const EdgeInsets.symmetric(
        horizontal: PantasSpace.s10,
        vertical: PantasSpace.s2,
      ),
      decoration: ShapeDecoration(
        color: fill,
        shape: PantasRadius.fullShape,
      ),
      child: Text(label, style: PantasType.webTag.copyWith(color: ink)),
    );
  }
}
