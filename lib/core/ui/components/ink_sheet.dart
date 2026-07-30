import 'package:pantas/core/ui/theme/app_theme.dart';
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
          // A sheet grows to its content and then stops. Without the cap a
          // long one runs off the bottom of the screen: the quiz's question
          // grid at 120 questions is 24 rows and overflowed by 272px. Short
          // sheets are unaffected, since the box only constrains the tall
          // ones and the scroll view has nothing to scroll.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
            ),
            child: SingleChildScrollView(child: builder(sheetContext)),
          ),
        ),
      );
    },
  );
}
