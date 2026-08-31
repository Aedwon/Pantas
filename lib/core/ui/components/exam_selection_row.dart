import 'package:flutter/material.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1;
    return Semantics(
      label: '${exam.shortName}, ${exam.name}',
      selected: selected,
      button: true,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        excludeFromSemantics: true,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: selected
              ? BoxDecoration(
                  color: colors.boardTint,
                  border: Border.all(color: colors.board),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusButton),
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
          child: largeText
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.shortName,
                      style: styles.headlineSmall.copyWith(
                        color: selected ? colors.board : colors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exam.name,
                      style: styles.bodyMedium.copyWith(
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                )
              : Row(
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
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
