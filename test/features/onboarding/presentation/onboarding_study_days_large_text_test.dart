import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_study_days_step.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';
import '../../../helpers/line_breaks.dart';

/// SelectableTile README, day tile: each day is wide enough for its weekday at
/// the current text size, the row scrolls when seven do not fit, and the hint
/// under the row stays readable at 200 percent text.
void main() {
  setUpAll(loadDsFonts);

  Future<void> pump(WidgetTester tester, Size size, double scale) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await pumpAccessibilitySurface(
      tester,
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: OnboardingStudyDaysStep(
          now: DateTime(2026, 10, 3),
          onCompleted: () {},
        ),
      ),
      disableAnimations: true,
      viewportSize: size,
      textScale: scale,
    );
    await tester.pumpAndSettle();
  }

  for (final size in [const Size(390, 844), const Size(320, 640)]) {
    testWidgets('weekday labels stay whole at 200% on ${size.width}',
        (tester) async {
      await pump(tester, size, 2);
      for (final label in ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']) {
        expect(splitsAWord(tester, find.text(label)), isFalse, reason: label);
      }
      final heights = {
        for (var day = 1; day <= 7; day++)
          tester.getSize(find.byKey(ValueKey('study-day-$day'))).height,
      };
      expect(heights, hasLength(1), reason: 'every day tile has one height');
      expect(tester.takeException(), isNull);
    });

    testWidgets('the hint scrolls clear of Continue at 200% on ${size.width}',
        (tester) async {
      await pump(tester, size, 2);
      final hint = find.text('Pick at least one day to continue.');
      // The actions are pinned (WORKFLOW ruling 3), so the page scrolls the
      // hint clear of them.
      await tester.ensureVisible(hint);
      await tester.pumpAndSettle();
      final continueTop = tester.getTopLeft(find.text('Continue')).dy;
      expect(tester.getBottomLeft(hint).dy, lessThanOrEqualTo(continueTop));
    });
  }
}
