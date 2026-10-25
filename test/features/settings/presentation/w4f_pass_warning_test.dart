import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/routes/settings_routes.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/application/carry_over_providers.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('CSE pass warning cancels without changing the selected exam',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final prefs = AppPreferencesRepository(db);
    await prefs.setSelectedExamId('exam_cse_pro');
    final exams = [
      buildExam(id: 'exam_cse_pro', shortName: 'CSE Professional'),
      buildExam(id: 'exam_cse_sub', shortName: 'CSE Subprofessional'),
    ];
    await tester.pumpAppWithProviders(
      const ChangeExamPage(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        examListProvider.overrideWith((ref) async => exams),
        examPickerCatalogProvider.overrideWith(
          (ref) => Stream.value([
            for (final exam in exams)
              ExamCatalogEntry(
                id: exam.id,
                name: exam.shortName,
                shortName: exam.shortName,
                priceTier: 'Civil Service',
                group: 'Civil service',
                comingSoon: false,
                publishedSittings: const [],
                hasContent: true,
              ),
          ]),
        ),
        entitlementProvider.overrideWith(
          (ref) => Stream.value(
            Entitlement(
              plan: EntitlementPlan.free,
              passes: {
                'exam_cse_pro': DateTime.now().add(const Duration(days: 90)),
              },
            ),
          ),
        ),
        carryableCountProvider.overrideWith((ref, id) async => 0),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('CSE Subprofessional'));
    await tester.pumpAndSettle();
    expect(find.text('Your pass stays with CSE Professional'), findsOneWidget);
    expect(await prefs.selectedExamId(), 'exam_cse_pro');
    await tester.tap(
      find.descendant(
        of: find.byType(CenteredDialog),
        matching: find.text('Cancel'),
      ),
    );
    await tester.pumpAndSettle();
    expect(await prefs.selectedExamId(), 'exam_cse_pro');
    expect(
      tester
          .widget<ListRow>(find.byKey(const ValueKey('exam-exam_cse_pro')))
          .selected,
      isTrue,
    );
    expect(find.text('Your pass stays with CSE Professional'), findsNothing);
  });
}
