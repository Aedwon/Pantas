import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/search_field.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

import '../../../helpers/ds_matrix.dart';

BoxDecoration _ring(WidgetTester tester) => tester
    .widget<Container>(find.byKey(const ValueKey('search-fill')))
    .foregroundDecoration! as BoxDecoration;

void main() {
  dsMatrix(
    'search: 38 on the desktop, 44 on the phone, ring and radius',
    (context) => SizedBox(
      width: 340,
      child: SearchField(
        hint: 'Search questions',
        onChanged: (_) {},
        keyHint: const Text('Ctrl K'),
      ),
    ),
    check: (tester, cell) async {
      final palette = cell.dark ? PantasColors.dark : PantasColors.light;
      final wide = cell.width >= 1024;
      final fill = find.byKey(const ValueKey('search-fill'));
      // Heights are minimums: 38 (`size-search`) on the desktop and 44
      // (`size-icon-btn`) on the phone, taller when the text is.
      final height = tester.getSize(fill).height;
      if (cell.scale == 1) {
        expect(height, wide ? 38 : 44);
      } else {
        expect(height, greaterThan(wide ? 38 : 44));
      }
      final well = tester.widget<Container>(fill).decoration! as BoxDecoration;
      expect(well.color, palette.surfaceCard);
      expect(well.borderRadius, BorderRadius.circular(wide ? 8 : 12));
      final border = _ring(tester).border! as Border;
      expect(border.top.color, palette.borderControl);
      expect(border.top.width, 1);
      // The hint is hidden on a touch screen.
      expect(find.text('Ctrl K'), wide ? findsOneWidget : findsNothing);
      final hint = tester.widget<TextField>(find.byType(TextField));
      expect(hint.decoration!.hintStyle!.color, palette.textSecondary);
    },
  );

  testWidgets('focus makes a 2 px accent ring', (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      SizedBox(width: 340, child: SearchField(onChanged: (_) {})),
    );
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    final border = _ring(tester).border! as Border;
    expect(border.top.width, 2);
    expect(border.top.color, PantasColors.light.accent);
  });

  testWidgets('a value shows a clear button; Esc clears too', (tester) async {
    var value = 'x';
    await pumpDs(
      tester,
      dsCells.first,
      SizedBox(width: 340, child: SearchField(onChanged: (v) => value = v)),
    );
    expect(find.bySemanticsLabel('Clear search'), findsNothing);
    await tester.enterText(find.byType(TextField), 'math');
    await tester.pump();
    expect(value, 'math');
    expect(find.bySemanticsLabel('Clear search'), findsOneWidget);
    // The hit area is 44 high.
    final target = tester.getSize(
      find
          .ancestor(
            of: find.byIcon(Icons.close).evaluate().isEmpty
                ? find.byType(InkResponse)
                : find.byIcon(Icons.close),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expect(target.height, greaterThanOrEqualTo(44));
    await tester.tap(find.byType(InkResponse));
    await tester.pump();
    expect(value, '');
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    await tester.enterText(find.byType(TextField), 'again');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(value, '');
  });
}
