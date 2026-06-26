import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The wash drawn over everything behind a sheet.
///
/// A sheet is used where a control edits a value in place and needs more room
/// than a row: the exam date wheels, the reminder wheels, the name field, and
/// the ordering choice. A destination is a pushed page instead.
const Color _washLight = Color(0x6B26221B);
const Color _washDark = Color(0x8C000000);

Future<T?> showInkSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: isDark ? _washDark : _washLight,
    isScrollControlled: true,
    builder: (sheetContext) {
      final colors = sheetContext.colors;
      return SafeArea(
        top: false,
        child: Container(
          key: const Key('inkSheetSurface'),
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.background,
            border: Border(top: BorderSide(color: colors.ink)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 15, 18, 18),
          child: builder(sheetContext),
        ),
      );
    },
  );
}
