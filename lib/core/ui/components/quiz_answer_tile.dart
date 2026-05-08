import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum TileState { normal, correct, incorrect, correctMissed }

class QuizAnswerTile extends StatelessWidget {
  const QuizAnswerTile({
    required this.letter,
    required this.text,
    required this.onTap,
    this.isSelected = false,
    this.state = TileState.normal,
    this.isMath = false,
    super.key,
  });

  final String letter;
  final String text;
  final VoidCallback onTap;
  final bool isSelected;
  final TileState state;
  final bool isMath;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    final Color bgColor;
    final Color borderColor;
    final double borderWidth;
    final Color textColor;
    final String prefixDisplay;

    switch (state) {
      case TileState.normal:
        bgColor = colors.surface;
        borderColor = isSelected ? colors.borderSelected : colors.border;
        borderWidth = 1.5;
        textColor = isSelected ? colors.onSurface : colors.onSurfaceMuted;
        prefixDisplay = letter;
      case TileState.correct:
        bgColor = colors.successContainer;
        borderColor = colors.success;
        borderWidth = 2;
        textColor = colors.success;
        prefixDisplay = '✅';
      case TileState.incorrect:
        bgColor = colors.errorContainer;
        borderColor = colors.error;
        borderWidth = 2;
        textColor = colors.error;
        prefixDisplay = '❌';
      case TileState.correctMissed:
        bgColor = colors.successContainer;
        borderColor = colors.success;
        borderWidth = 2;
        textColor = colors.success;
        prefixDisplay = '💡';
    }

    final textStyle = isMath ? textStyles.mathBody : textStyles.bodyMedium;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints:
            const BoxConstraints(minHeight: AppDimensions.minTapTarget),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                prefixDisplay,
                style: textStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected && state == TileState.normal
                      ? colors.borderSelected
                      : colors.onSurfaceMuted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: textStyle.copyWith(
                  color: textColor,
                  fontWeight: state == TileState.correct || isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  decoration: state == TileState.incorrect
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
