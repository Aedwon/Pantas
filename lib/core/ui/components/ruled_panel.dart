import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A stateful object drawn as a bordered rectangle on the page's own paper.
///
/// Distinct from `RuledSection`, which is a top-rule block. This one is
/// bounded on all four sides and opens with a heading plate.
///
/// The trailing slot takes a count and nothing else. A status word was tried
/// and cut: in this identity the top right of a section is either an action in
/// board or a count, and a word is neither.
class RuledPanel extends StatelessWidget {
  const RuledPanel({
    required this.heading,
    required this.child,
    this.count,
    this.action,
    this.onAction,
    super.key,
  }) : assert(
          count == null || action == null,
          'The panel header carries one trailing element: a count or an '
          'action, never both.',
        );

  final String heading;
  final Widget child;

  /// Tabular figures in 12px `inkMuted`. Never a status word.
  final String? count;

  /// A text action in board at 12/600, in the same slot as [count].
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        border: Border.all(
          color: colors.rule,
          // ignore: avoid_redundant_argument_values
          width: AppDimensions.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            // Not a Spacer. A Spacer is a flex child, and so is the heading,
            // so the two split the free space evenly and left the action
            // stranded mid-row whenever the heading was short. spaceBetween
            // gives the leftover to the gap instead of dividing it.
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: colors.ink, width: 1.6),
                    ),
                  ),
                  child: Text(heading, style: styles.headlineSmall),
                ),
              ),
              // The heading is Flexible so its underline stays the width of
              // the words and a long one can still shrink.
              if (count != null) ...[
                Text(
                  count!,
                  style: styles.bodySmall.copyWith(
                    color: colors.inkMuted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
              if (action != null)
                InkWell(
                  onTap: onAction,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusButton),
                  child: Padding(
                    // Left only. Symmetric padding held the words 8px off
                    // the panel's right edge, so the action never sat on
                    // the margin every other row is aligned to.
                    padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                    child: Text(
                      action!,
                      style: styles.labelSmall.copyWith(
                        color:
                            onAction != null ? colors.board : colors.inkMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
          child,
        ],
      ),
    );
  }
}
