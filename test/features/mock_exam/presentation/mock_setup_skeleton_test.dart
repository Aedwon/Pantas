// U15: the phone Mock setup skeleton is drawn from the loaded page, so the
// page does not change title or jump sideways when the paper arrives.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_skeletons.dart';

void main() {
  testWidgets('no app bar, the Quiz link row, and the page side padding',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const MockSetupSkeleton(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Mock exam'), findsNothing);
    // The same link row the loaded page draws.
    expect(find.text('Quiz'), findsOneWidget);
    final blocks = tester.widgetList<SkeletonBlock>(find.byType(SkeletonBlock));
    // The table block is the one tagged as a section: 16 px sides.
    final table = find.byKey(skeletonSectionKey);
    expect(tester.getTopLeft(table).dx, 16);
    expect(tester.getSize(table).width, 390 - 32);
    expect(blocks, isNotEmpty);
  });
}
