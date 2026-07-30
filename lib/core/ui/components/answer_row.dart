import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/inline_math_text.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

enum AnswerRowState { plain, selected, correct, incorrect, correctMissed }

/// Quiz answer device (spec amendment): hairline-separated rows with serif
/// choice letters. The selected row is the single place the board tint+border
/// fills. Graded states mark with text glyphs: board ✓ for correct, rust ✕
/// for a wrong pick, a board ✓ on the missed correct row.
class AnswerRow extends StatelessWidget {
  const AnswerRow({
    required this.letter,
    required this.text,
    required this.onTap,
    this.state = AnswerRowState.plain,
    this.isMath = false,
    super.key,
  });

  final String letter;
  final String text;
  final VoidCallback? onTap;
  final AnswerRowState state;
  final bool isMath;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    final selected = state == AnswerRowState.selected;
    final decoration = selected
        ? BoxDecoration(
            color: colors.boardTint,
            border: Border.all(color: colors.board),
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          )
        : BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.ruleFaint,
                // ignore: avoid_redundant_argument_values
                width: AppDimensions.hairline,
              ),
            ),
          );

    final (String prefix, Color prefixColor) = switch (state) {
      AnswerRowState.plain => (letter, colors.inkMuted),
      AnswerRowState.selected => (letter, colors.board),
      AnswerRowState.correct => ('✓', colors.board),
      AnswerRowState.incorrect => ('✕', colors.rust),
      AnswerRowState.correctMissed => ('✓', colors.board),
    };

    final bodyStyle = isMath ? styles.mathBody : styles.bodyMedium;
    final textColor = switch (state) {
      AnswerRowState.incorrect => colors.rust,
      _ => colors.ink,
    };
    final weight = switch (state) {
      AnswerRowState.selected || AnswerRowState.correct => FontWeight.w600,
      _ => FontWeight.w400,
    };

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: decoration,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              child: Text(
                prefix,
                style: styles.headlineSmall.copyWith(color: prefixColor),
              ),
            ),
            const SizedBox(width: 10),
            // A choice is a plain string, so `$…$` in it never reached the
            // maths renderer the stem goes through and printed its dollars.
            Expanded(
              child: InlineMathText(
                text,
                style: bodyStyle.copyWith(
                  color: textColor,
                  fontWeight: weight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
