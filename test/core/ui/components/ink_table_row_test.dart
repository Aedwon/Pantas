import 'package:cse_cet_reviewer/core/ui/components/ink_table_row.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness(Widget child) =>
    MaterialApp(theme: buildLightTheme(), home: Scaffold(body: child));

void main() {
  testWidgets('done row shows board check and muted title', (tester) async {
    await tester.pumpWidget(
      harness(
        const InkTableRow(
          title: 'Vocabulary in context',
          meta: '9 min',
          state: InkRowState.done,
        ),
      ),
    );
    final check = tester.widget<Text>(find.text('✓'));
    expect(check.style?.color, AppColors.light.board);
    final title = tester.widget<Text>(find.text('Vocabulary in context'));
    expect(title.style?.color, AppColors.light.inkMuted);
  });

  testWidgets('active row is semibold with circle glyph and fires onTap',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      harness(
        InkTableRow(
          title: 'Reading comprehension',
          subtitle: 'Main idea & supporting details',
          meta: '12 min',
          state: InkRowState.active,
          onTap: () => tapped = true,
        ),
      ),
    );
    expect(find.text('○'), findsOneWidget);
    final title = tester.widget<Text>(find.text('Reading comprehension'));
    expect(title.style?.fontWeight, FontWeight.w600);
    await tester.tap(find.text('Reading comprehension'));
    expect(tapped, isTrue);
  });

  testWidgets('plain row renders category column', (tester) async {
    await tester.pumpWidget(
      harness(
        const InkTableRow(
          title: 'Number series',
          category: 'Numerical ability',
          meta: '10 min',
        ),
      ),
    );
    expect(find.text('Numerical ability'), findsOneWidget);
    expect(find.text('✓'), findsNothing);
    expect(find.text('○'), findsNothing);
  });

  testWidgets('row meets minimum height', (tester) async {
    await tester.pumpWidget(harness(const InkTableRow(title: 'Row')));
    final size = tester.getSize(find.byType(InkTableRow));
    expect(size.height, greaterThanOrEqualTo(44));
  });
}
