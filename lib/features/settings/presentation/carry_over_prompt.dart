import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_sheet.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Prompt shown when switching exams, asking whether to carry existing
/// progress over.
///
/// Returns true if student wants to count them, false for fresh numbers, or null if dismissed/count is 0.
Future<bool?> showCarryOverPrompt({
  required BuildContext context,
  required String examShortName,
  required int carryableCount,
}) async {
  if (carryableCount <= 0) return null;
  return showInkSheet<bool>(
    context: context,
    builder: (sheetContext) {
      final styles = sheetContext.textStyles;
      final colors = sheetContext.colors;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "You're not starting from zero",
            style: styles.headlineSmall.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "$carryableCount of the questions you've answered are also on "
            "$examShortName. We'll count them toward your "
            '$examShortName progress '
            'so you can pick up where you are, not where you started.',
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 20),
          BoardButton(
            label: 'Count them',
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
          const SizedBox(height: 8),
          BoardButton(
            label: 'Start my numbers fresh',
            secondary: true,
            onPressed: () => Navigator.of(sheetContext).pop(false),
          ),
        ],
      );
    },
  );
}
