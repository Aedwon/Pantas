import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// Closes a card with a caption at the left and the card's one action at the
/// right.
///
/// The band is `surface-inset` under a 0.5 `divider` rule, padded 16 / 20 /
/// 18 / 20. A long caption wraps first. When the caption cannot keep a 12rem
/// column beside the action, the action drops under it at the right. The
/// footer takes no focus; the [action] (a button) keeps its own 44 target.
///
/// Put it last in a `WebCard`. It holds one action: a pair goes in one
/// [action] widget, secondary then main.
class CardFooter extends StatelessWidget {
  const CardFooter({
    required this.caption,
    required this.action,
    this.actionMinWidth = PantasSize.targetTouch * 3,
    super.key,
  });

  /// A short, factual line that explains the action ("About 15 min").
  final String caption;

  /// The card's action, at its natural width.
  final Widget action;

  /// The room the action needs beside the caption before it drops under it.
  /// A wider action (a pair of buttons) passes its own estimate.
  final double actionMinWidth;

  /// The caption's smallest column: 12rem, which grows with the text size.
  static const double _captionBasis = PantasSpace.s16 * 12;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final caption = Text(
      this.caption,
      style: PantasType.webSub.copyWith(color: c.textSecondary),
    );
    final basis = MediaQuery.textScalerOf(context).scale(_captionBasis);
    return DecoratedBox(
      key: const ValueKey('card-footer'),
      decoration: BoxDecoration(
        color: c.surfaceInset,
        border: Border(
          top: BorderSide(color: c.divider, width: PantasBorder.hairline),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s20,
          PantasSpace.s16,
          PantasSpace.s20,
          PantasSpace.s18,
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            final stacked = box.maxWidth.isFinite &&
                box.maxWidth < basis + PantasSpace.s16 + actionMinWidth;
            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  caption,
                  const SizedBox(height: PantasSpace.s12),
                  Align(alignment: Alignment.centerRight, child: action),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: caption,
                  ),
                ),
                const SizedBox(width: PantasSpace.s16),
                action,
              ],
            );
          },
        ),
      ),
    );
  }
}
