import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_exam_date_step.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

class FakeSettingsRepository implements DriftSettingsRepository {
  ExamDate? savedExamDate;
  int updateExamDateCallCount = 0;

  @override
  Future<UserSettings> readUserSettings() async => UserSettings.defaults();

  @override
  Future<void> updateExamDate(ExamDate date, {required DateTime today}) async {
    updateExamDateCallCount++;
    // At month precision the comparison is against the month, not the 1st, so
    // the current month stays selectable while it still has days left in it.
    final earliest = DateTime(today.year, today.month, today.day)
        .add(const Duration(days: 1));
    final toCompare = date.day ?? DateTime(date.year, date.month + 1, 0);
    if (toCompare.isBefore(earliest)) {
      throw InvalidExamDateException(date);
    }
    savedExamDate = date;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrap(Widget child, [FakeSettingsRepository? settingsRepo]) {
  return ProviderScope(
    overrides: [
      if (settingsRepo != null)
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
    ],
    child: MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  testWidgets('the step offers a month-only option above day 1',
      (tester) async {
    await tester.pumpWidget(_wrap(OnboardingExamDateStep(onCompleted: () {})));

    expect(find.text('When is your exam?'), findsOneWidget);
    expect(
      find.text("We'll count down the days on your home screen."),
      findsOneWidget,
    );
    expect(find.text("I don't know yet"), findsOneWidget);
    // A word, not a dash. The identity bans the em dash by name and a wheel
    // is not the place to make a student decode a mark.
    expect(find.text('Any'), findsWidgets);
    expect(find.text('—'), findsNothing);
  });

  testWidgets('skipping writes no date', (tester) async {
    final fakeRepo = FakeSettingsRepository();
    var completed = false;

    await tester.pumpWidget(
      _wrap(
        OnboardingExamDateStep(onCompleted: () => completed = true),
        fakeRepo,
      ),
    );

    await tester.tap(find.text("I don't know yet"));
    await tester.pumpAndSettle();

    expect(fakeRepo.updateExamDateCallCount, 0);
    expect(completed, isTrue);
  });

  testWidgets('a day left on the dash stores month precision', (tester) async {
    final fakeRepo = FakeSettingsRepository();
    var completed = false;

    await tester.pumpWidget(
      _wrap(
        OnboardingExamDateStep(
          onCompleted: () => completed = true,
          now: DateTime(2026, 8, 11),
        ),
        fakeRepo,
      ),
    );

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(fakeRepo.savedExamDate, isNotNull);
    expect(fakeRepo.savedExamDate!.precision, ExamDatePrecision.month);
    expect(fakeRepo.savedExamDate!.day, isNull);
    expect(completed, isTrue);
  });

  testWidgets('all three wheels set stores day precision', (tester) async {
    final fakeRepo = FakeSettingsRepository();
    var completed = false;

    await tester.pumpWidget(
      _wrap(
        OnboardingExamDateStep(
          onCompleted: () => completed = true,
          now: DateTime(2026, 8, 11),
        ),
        fakeRepo,
      ),
    );

    // Scroll the day wheel off the dash to day 15
    final dayPicker = find.byKey(const ValueKey('day_picker'));
    await tester.drag(dayPicker, const Offset(0, -32.0 * 15));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(fakeRepo.savedExamDate, isNotNull);
    expect(fakeRepo.savedExamDate!.precision, ExamDatePrecision.day);
    expect(fakeRepo.savedExamDate!.day, isNotNull);
    expect(completed, isTrue);
  });
}
