import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

void main() {
  for (final radio in [false, true]) {
    testWidgets('selection rows share the board control, radio=$radio',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(
            body: radio
                ? ListRow(
                    title: 'Choice',
                    variant: ListRowVariant.radio,
                    onTap: () => taps++,
                  )
                : ListRow.checkbox(
                    title: 'Choice',
                    selected: false,
                    onTap: () => taps++,
                  ),
          ),
        ),
      );
      expect(
        find.byWidgetPredicate(
          (w) =>
              w.runtimeType.toString() == (radio ? 'RadioRow' : 'CheckboxRow'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Choice'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });
  }
}
