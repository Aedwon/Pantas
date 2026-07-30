import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ExamSelectionRow extends StatelessWidget {
  const ExamSelectionRow({
    required this.exam,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final Exam exam;
  final bool selected;
  final VoidCallback onTap;

  static const double emblemWidth = 96;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: selected
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
              ),
        child: Row(
          children: [
            SizedBox(
              width: emblemWidth,
              child: Text(
                exam.shortName,
                maxLines: 1,
                softWrap: false,
                style: styles.headlineSmall.copyWith(
                  color: selected ? colors.board : colors.inkMuted,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                exam.name,
                style: styles.bodyMedium.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
