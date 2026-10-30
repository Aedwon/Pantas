import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_consent_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_page.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_subjects_step.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

/// Each caught save failure is reported and the screen still shows its retry.
class _FailingPrefs extends AppPreferencesRepository {
  _FailingPrefs(super.db);

  @override
  Future<void> setPassedAgeGate({required bool value}) =>
      Future.error(StateError('age'));

  @override
  Future<void> setSelectedExamId(String examId) =>
      Future.error(StateError('exam'));

  @override
  Future<void> setCompletedOnboarding({required bool value}) =>
      Future.error(StateError('complete'));
}

class _FailingSettings extends DriftSettingsRepository {
  _FailingSettings(super.db);

  @override
  Future<void> recordPolicyAcceptance() => Future.error(StateError('policy'));
}

class _FailingTracks extends CustomTrackRepository {
  _FailingTracks(super.db, super.contentDb);

  @override
  Future<ExamId> create({
    required String name,
    required Set<TopicId> includedTopicIds,
  }) =>
      Future.error(StateError('create'));
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

  Future<void> pumpStep(
    WidgetTester tester,
    Widget step, {
    required List<Override> overrides,
  }) async {
    await pumpAccessibilitySurface(
      tester,
      ProviderScope(
        overrides: [telemetryProvider.overrideWithValue(sink), ...overrides],
        child: step,
      ),
      disableAnimations: true,
      viewportSize: const Size(390, 844),
    );
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
  }

  testWidgets('age gate reports a failed save', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await pumpStep(
      tester,
      OnboardingAgeGateStep(currentYear: 2026, onAgeGatePassed: () {}),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        appPreferencesRepositoryProvider.overrideWithValue(_FailingPrefs(db)),
      ],
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(sink.errors, hasLength(1));
  });

  testWidgets('consent reports a failed save', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await pumpStep(
      tester,
      OnboardingConsentStep(onCompleted: () {}),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        settingsRepositoryProvider.overrideWithValue(_FailingSettings(db)),
      ],
    );
    await tester.tap(find.byKey(const ValueKey('selection-mark')).last);
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(sink.errors, hasLength(1));
  });

  testWidgets('exam picker reports a failed save', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    const entry = ExamCatalogEntry(
      id: 'exam_upcat',
      name: 'UP College Admission Test',
      shortName: 'UPCAT',
      priceTier: 'Student',
      group: 'College entrance',
      comingSoon: false,
      publishedSittings: [],
      hasContent: true,
    );
    await pumpStep(
      tester,
      ExamPickerScreen(
        mode: ExamPickerMode.onboarding,
        onPicked: (_) async {},
      ),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        appPreferencesRepositoryProvider.overrideWithValue(_FailingPrefs(db)),
        examPickerCatalogProvider
            .overrideWith((ref) => Stream.value(const [entry])),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('UPCAT'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(sink.errors, hasLength(1));
  });

  testWidgets('custom Subjects reports a failed create', (tester) async {
    final db = inMemoryDatabase();
    final content = inMemoryContentDatabase();
    addTearDown(db.close);
    addTearDown(content.close);
    await seedContentExam(content, examId: 'e1', code: 'E', name: 'Exam');
    await seedContentSubject(
      content,
      subjectId: 's1',
      examId: 'e1',
      name: 'Mathematics',
    );
    await seedContentTopic(
      content,
      topicId: 't1',
      subjectId: 's1',
      name: 'Algebra',
    );
    await pumpStep(
      tester,
      const CustomTrackSubjectsStep(name: 'My exam'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        customTrackRepositoryProvider
            .overrideWithValue(_FailingTracks(db, content)),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mathematics'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(sink.errors, hasLength(1));
  });

  testWidgets('finishing onboarding reports a failed completion write',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('Home')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpAppWithRouter(
      router,
      overrides: [
        telemetryProvider.overrideWithValue(sink),
        appDatabaseProvider.overrideWithValue(db),
        appPreferencesRepositoryProvider.overrideWithValue(_FailingPrefs(db)),
        onboardingProgressProvider.overrideWith(
          (ref) async => OnboardingProgress(
            agePassed: true,
            policyAccepted: true,
            examPicked: true,
            dateAnswered: true,
            daysAnswered: true,
            nameAnswered: true,
          ),
        ),
      ],
    );
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(sink.errors, hasLength(1));
  });
}
