import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/features/settings/presentation/pages/exam_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  for (final wheel in ['Month', 'Year']) {
    testWidgets('$wheel change preserves a valid day instead of forcing day 1',
        (tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final now = DateTime.now();
      final repo = DriftSettingsRepository(db);
      await repo.updateExamDate(
        ExamDate.onDay(DateTime(now.year + 1, now.month, now.day)),
        today: now,
      );
      await tester.pumpAppWithProviders(
        const ExamPage(),
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exam date'));
      await tester.pumpAndSettle();
      final picker = tester.widget<ValueWheel>(
        find.byWidgetPredicate((w) => w is ValueWheel && w.label == wheel),
      );
      picker.onSelected(wheel == 'Month' ? now.month - 1 : 0);
      await tester.pumpAndSettle();
      final date = (await repo.readUserSettings()).examDate!.day!;
      expect(date.day, now.day);
      expect(date.month, now.month);
      expect(date.year, wheel == 'Year' ? now.year : now.year + 1);
      expect(find.text('Could not save. Please try again.'), findsNothing);
    });
  }
  testWidgets('exam date edits in place with study days, without a sheet',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        userSettingsProvider
            .overrideWith((ref) async => UserSettings.defaults()),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('Your exam'), findsOneWidget);
    expect(find.text('Study days'), findsOneWidget);
    await tester.tap(find.text('Exam date'));
    await tester.pumpAndSettle();
    expect(find.text('Exact day'), findsOneWidget);
    expect(find.text('Month only'), findsOneWidget);
    expect(find.text("I don't know"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
