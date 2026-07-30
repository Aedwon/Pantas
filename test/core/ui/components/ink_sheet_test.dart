import 'package:pantas/core/ui/components/ink_sheet.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the sheet has an ink top rule, square corners and no shadow',
      (tester) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showInkSheet<void>(
            context: context,
            builder: (_) => const Text('Exam date'),
          ),
          child: const Text('open'),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Exam date'), findsOneWidget);

    final surface = tester.widget<Container>(
      find.byKey(const Key('inkSheetSurface')),
    );
    final decoration = surface.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.light.background);
    expect(decoration.borderRadius, isNull);
    expect(decoration.boxShadow, isNull);
    expect(decoration.border!.top.color, AppColors.light.ink);
    expect(decoration.border!.top.width, 1);
  });

  testWidgets('the sheet returns its result and closes', (tester) async {
    String? result;
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showInkSheet<String>(
              context: context,
              builder: (sheetContext) => TextButton(
                onPressed: () => Navigator.of(sheetContext).pop('saved'),
                child: const Text('Save'),
              ),
            );
          },
          child: const Text('open'),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 'saved');
    expect(find.text('Save'), findsNothing);
  });

  testWidgets('a sheet taller than the screen scrolls instead of overflowing',
      (tester) async {
    // The quiz's question grid at 120 questions is 24 rows and ran 272px off
    // the bottom of the screen.
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showInkSheet<void>(
            context: context,
            builder: (_) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 40; i += 1)
                  SizedBox(height: 46, child: Text('row $i')),
              ],
            ),
          ),
          child: const Text('open'),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('a short sheet is still only as tall as its content',
      (tester) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showInkSheet<void>(
            context: context,
            builder: (_) => const SizedBox(height: 80, child: Text('short')),
          ),
          child: const Text('open'),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final surface = tester.getRect(find.byKey(const Key('inkSheetSurface')));
    // 80 of content plus the surface's 15 and 18 of vertical padding.
    expect(surface.height, closeTo(113, 1));
  });
}
