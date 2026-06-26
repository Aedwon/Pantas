import 'package:cse_cet_reviewer/core/ui/components/ink_sheet.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
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
}
