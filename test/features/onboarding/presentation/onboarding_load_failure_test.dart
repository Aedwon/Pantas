import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/core/ui/components/loading_shapes.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_exam_date_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_name_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_study_days_step.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/in_memory_database.dart';

/// Fails the first [failures] reads, then reads normally. Optionally fails
/// every write, so save errors can be reported too.
class _FlakySettings extends DriftSettingsRepository {
  _FlakySettings(super.db, {this.failWrites = false});
  int failures = 1;
  final bool failWrites;
  int reads = 0;

  @override
  Future<UserSettings> readUserSettings() async {
    reads++;
    if (failures > 0) {
      failures--;
      throw StateError('read failed');
    }
    return super.readUserSettings();
  }

  @override
  Future<void> updateName(String? name) async {
    if (failWrites) throw StateError('write failed');
    return super.updateName(name);
  }

  @override
  Future<void> updateStudyDays(StudyDays days) async {
    if (failWrites) throw StateError('write failed');
    return super.updateStudyDays(days);
  }
}

class _ErrorSink extends DisabledTelemetry {
  final errors = <Object>[];
  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    errors.add(error);
  }
}

void main() {
  late _ErrorSink sink;

  setUp(() => sink = _ErrorSink());

  Future<_FlakySettings> pump(
    WidgetTester tester,
    Widget step, {
    bool failWrites = false,
    Future<void> Function(DriftSettingsRepository repo)? seed,
  }) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    if (seed != null) await seed(DriftSettingsRepository(db));
    final settings = _FlakySettings(db, failWrites: failWrites);
    await pumpAccessibilitySurface(
      tester,
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          settingsRepositoryProvider.overrideWithValue(settings),
          telemetryProvider.overrideWithValue(sink),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value(const [])),
        ],
        child: step,
      ),
      disableAnimations: true,
      viewportSize: const Size(390, 844),
    );
    await tester.pumpAndSettle();
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    return settings;
  }

  testWidgets('date step load failure ends the spinner and retries the load',
      (tester) async {
    final settings = await pump(
      tester,
      OnboardingExamDateStep(now: DateTime(2026, 10, 3), onCompleted: () {}),
    );
    expect(find.byType(LoadingShapes), findsNothing);
    expect(find.text('Could not load your exam date.'), findsOneWidget);
    expect(sink.errors, hasLength(1));
    expect(find.text('Could not save your progress.'), findsNothing);

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(settings.reads, 2);
    expect(find.text('Could not load your exam date.'), findsNothing);
    expect(
      find.text('Pick the month. Add the day if you know it.'),
      findsOneWidget,
    );
  });

  testWidgets("I don't know cannot overwrite a stored date that never loaded",
      (tester) async {
    final today = DateTime(2026, 10, 3);
    final stored = ExamDate.onDay(DateTime(2026, 11, 11));
    late DriftSettingsRepository repo;
    await pump(
      tester,
      OnboardingExamDateStep(now: today, onCompleted: () {}),
      seed: (r) async {
        repo = r;
        await r.updateExamDate(stored, today: today);
      },
    );
    expect(find.text('Could not load your exam date.'), findsOneWidget);
    final skip = tester.widget<PantasButton>(
      find.widgetWithText(PantasButton, "I don't know"),
    );
    expect(skip.onPressed, isNull);
    await tester.tap(find.text("I don't know"), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect((await repo.readUserSettings()).examDate, stored);
  });

  testWidgets('days step load failure retries the load, not the save',
      (tester) async {
    final settings = await pump(
      tester,
      OnboardingStudyDaysStep(now: DateTime(2026, 10, 3), onCompleted: () {}),
    );
    expect(find.text('Could not load your study days.'), findsOneWidget);
    expect(sink.errors, hasLength(1));

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(settings.reads, 2);
    expect(find.text('Could not load your study days.'), findsNothing);
    expect(find.text('Pick at least one day to continue.'), findsOneWidget);
  });

  testWidgets('name step load failure retries the load, not the save',
      (tester) async {
    final settings = await pump(
      tester,
      OnboardingNameStep(onCompleted: () {}),
    );
    expect(find.text('Could not load your name.'), findsOneWidget);
    expect(sink.errors, hasLength(1));

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(settings.reads, 2);
    expect(find.text('Could not load your name.'), findsNothing);
    expect(find.text('What should we call you?'), findsOneWidget);
  });

  testWidgets('save failures are reported, not swallowed', (tester) async {
    await pump(
      tester,
      OnboardingNameStep(onCompleted: () {}),
      failWrites: true,
    );
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    sink.errors.clear();
    await tester.enterText(find.byType(TextField), 'Aedwon');
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(sink.errors, hasLength(1));
  });
}
