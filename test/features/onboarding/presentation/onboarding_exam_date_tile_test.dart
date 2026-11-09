import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_exam_date_step.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';

/// D175: the calendar tile is sized so the month fits at 200% text, with
/// room on both sides.
void main() {
  setUpAll(loadDsFonts);

  for (final scale in [1.0, 2.0]) {
    testWidgets('the month keeps clear of the tile edges at $scale',
        (tester) async {
      final today = DateTime(2026, 10, 3);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await AppPreferencesRepository(db).setSelectedExamId('exam_cse_pro');
      final entry = ExamCatalogEntry(
        id: 'exam_cse_pro',
        name: 'Civil Service Exam',
        shortName: 'CSE Professional',
        priceTier: 'Civil Service',
        group: 'Civil service',
        comingSoon: false,
        hasContent: true,
        publishedSittings: [
          PublishedExamSitting(
            firstDay: DateTime(2027, 3, 14),
            lastDay: DateTime(2027, 3, 14),
            sourceUrl: 'https://csc.gov.ph',
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value([entry])),
        ],
      );
      addTearDown(container.dispose);
      await pumpAccessibilitySurface(
        tester,
        UncontrolledProviderScope(
          container: container,
          child: OnboardingExamDateStep(
            now: today,
            onCompleted: () {},
            onBack: () {},
          ),
        ),
        textScale: scale,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
      await tester.pumpAndSettle();
      final tile = tester.getRect(find.byKey(const ValueKey('exam-date-tile')));
      final month = tester.getRect(find.text('MAR'));
      expect(month.left - tile.left, greaterThanOrEqualTo(8));
      expect(tile.right - month.right, greaterThanOrEqualTo(8));
    });
  }
}
