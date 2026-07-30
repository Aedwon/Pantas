import 'package:pantas/core/ui/components/pennant_mark.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:pantas/core/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('an unset pennant paints', (tester) async {
    await tester.pumpApp(const PennantMark(isSet: false));

    expect(find.byType(PennantMark), findsOneWidget);
    final customPaint = find.descendant(
      of: find.byType(PennantMark),
      matching: find.byType(CustomPaint),
    );
    expect(tester.getSize(customPaint).width, 21);
  });

  testWidgets('a set pennant paints at the same size', (tester) async {
    await tester.pumpApp(const PennantMark(isSet: true));

    final customPaint = find.descendant(
      of: find.byType(PennantMark),
      matching: find.byType(CustomPaint),
    );
    expect(tester.getSize(customPaint).width, 21);
  });

  testWidgets('the size is settable for a grid cell', (tester) async {
    await tester.pumpApp(const PennantMark(isSet: true, size: 12));

    final customPaint = find.descendant(
      of: find.byType(PennantMark),
      matching: find.byType(CustomPaint),
    );
    expect(tester.getSize(customPaint).width, 12);
  });

  testWidgets('setting animates and unsetting does not', (tester) async {
    await tester.pumpApp(const PennantMark(isSet: false, color: Colors.black));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: [AppColors.light, AppTextStyles.create()],
        ),
        home: const Scaffold(
          body: PennantMark(isSet: true, color: Colors.black),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    // Mid-sweep: the fill is partial, so a frame is still scheduled.
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: [AppColors.light, AppTextStyles.create()],
        ),
        home: const Scaffold(
          body: PennantMark(isSet: false, color: Colors.black),
        ),
      ),
    );
    await tester.pump();
    // Draining is instant: nothing is scheduled after the first frame.
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
