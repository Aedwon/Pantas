import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

Future<void> _pumpPage(
  WidgetTester tester,
  AppDatabase db,
  ContentDatabase content,
  OnboardingProgress progress, {
  StudyApi? api,
  Telemetry? telemetry,
}) async {
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
      appDatabaseProvider.overrideWithValue(db),
      contentDatabaseProvider.overrideWithValue(content),
      onboardingWebProvider.overrideWithValue(true),
      onboardingProgressProvider.overrideWith((ref) async {
        // The router already holds the active exam in the real app.
        await ref.watch(activeExamFocusProvider.future);
        return progress;
      }),
      examPickerCatalogProvider.overrideWith((ref) => Stream.value(const [])),
      if (telemetry != null) telemetryProvider.overrideWithValue(telemetry),
      if (api != null) ...[
        studyUsesServerProvider.overrideWithValue(true),
        studyApiProvider.overrideWithValue(api),
        authStateProvider.overrideWith(
          (ref) => Stream.value(const AuthState.anonymous(uid: 'u1')),
        ),
      ],
    ],
  );
  addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpAndSettle();
  if (api != null) {
    // The app holds the signed-in account by the time onboarding runs.
    await ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(authStateProvider.future);
  }
}

Future<(AppDatabase, ContentDatabase)> _pumpFlow(
  WidgetTester tester, {
  StudyApi? api,
  Telemetry? telemetry,
}) async {
  final db = inMemoryDatabase();
  final content = inMemoryContentDatabase();
  addTearDown(db.close);
  addTearDown(content.close);
  await seedContentExam(
    content,
    examId: 'exam_cse_pro',
    code: 'CSE',
    name: 'Civil Service',
  );
  await seedContentSubject(
    content,
    subjectId: 's1',
    examId: 'exam_cse_pro',
    name: 'Mathematics',
  );
  await seedContentTopic(
    content,
    topicId: 't1',
    subjectId: 's1',
    name: 'Algebra',
  );
  await seedContentSubject(
    content,
    subjectId: 's2',
    examId: 'exam_cse_pro',
    name: 'Science',
    ordering: 2,
  );
  await seedContentTopic(
    content,
    topicId: 't2',
    subjectId: 's2',
    name: 'Biology',
  );
  // Only a topic that holds a question is offered.
  for (final (id, topic) in [('q1', 't1'), ('q2', 't2')]) {
    await seedContentQuestion(
      content,
      questionId: id,
      topicId: topic,
      examId: 'exam_cse_pro',
    );
  }
  await _pumpPage(
    tester,
    db,
    content,
    OnboardingProgress(agePassed: true, policyAccepted: true),
    api: api,
    telemetry: telemetry,
  );
  return (db, content);
}

Future<void> _createTrackAndReachDate(
  WidgetTester tester, {
  String name = 'My Exam',
  String subject = 'Mathematics',
}) async {
  await tester.tap(find.text("My exam isn't listed"));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), name);
  await tester.pump();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(subject));
  await tester.pump();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  expect(find.text('When is your exam?'), findsOneWidget);
}

void main() {
  testWidgets('Back from the date step then Continue keeps one custom track',
      (tester) async {
    final (db, content) = await _pumpFlow(tester);
    await _createTrackAndReachDate(tester);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('What does it cover?'), findsOneWidget);
    expect(await db.select(db.customTrackMetaLocal).get(), hasLength(1));

    // The student ticks again and continues, as the board allows.
    await tester.tap(find.text('Science'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('When is your exam?'), findsOneWidget);

    final tracks = await db.select(db.customTrackMetaLocal).get();
    expect(tracks, hasLength(1));
    expect(
      (await content.select(content.contentExams).get())
          .where((exam) => exam.isCustom),
      hasLength(1),
    );
    expect(
      await AppPreferencesRepository(db).selectedExamId(),
      tracks.single.examId,
    );
    // The reused track now covers only what the student ticked last.
    expect(
      await CustomTrackRepository(db, content)
          .excludedTopicIds(tracks.single.examId),
      {'t1'},
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Back out of Subjects to the picker removes the track just made',
      (tester) async {
    final (db, content) = await _pumpFlow(tester);
    await _createTrackAndReachDate(tester);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text("My exam isn't listed"), findsOneWidget);
    expect(await db.select(db.customTrackMetaLocal).get(), isEmpty);
    expect(
      (await content.select(content.contentExams).get())
          .where((exam) => exam.isCustom),
      isEmpty,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    expect(
      (await container.read(examListProvider.future)).where((e) => e.isCustom),
      isEmpty,
    );

    // Going round again makes one fresh track, not two.
    await _createTrackAndReachDate(tester);
    expect(await db.select(db.customTrackMetaLocal).get(), hasLength(1));
  });

  testWidgets('a track that already has study data is kept', (tester) async {
    final (db, content) = await _pumpFlow(tester);
    await _createTrackAndReachDate(tester);
    final id = (await db.select(db.customTrackMetaLocal).get()).single.examId;
    await AssessmentRepository(db).saveResult(id, DateTime(2026), const []);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text("My exam isn't listed"), findsOneWidget);
    expect(await db.select(db.customTrackMetaLocal).get(), hasLength(1));
    expect(
      (await content.select(content.contentExams).get())
          .where((exam) => exam.isCustom),
      hasLength(1),
    );
  });

  testWidgets(
      'after the track is removed the stale selection falls back to '
      'the picker', (tester) async {
    final (db, content) = await _pumpFlow(tester);
    await _createTrackAndReachDate(tester);
    final id = (await db.select(db.customTrackMetaLocal).get()).single.examId;
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    // The preference still names the deleted track, and nothing breaks.
    expect(await AppPreferencesRepository(db).selectedExamId(), id);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    final focus = await container.read(activeExamFocusProvider.future);
    expect(focus.needsSelection, isTrue);
    expect(tester.takeException(), isNull);

    // Reopening onboarding with that selection lands on the picker.
    await tester.pumpWidget(const SizedBox.shrink());
    await _pumpPage(
      tester,
      db,
      content,
      OnboardingProgress(
        agePassed: true,
        policyAccepted: true,
        examPicked: true,
      ),
    );
    expect(find.text("My exam isn't listed"), findsOneWidget);
    expect(find.text('When is your exam?'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a track with an attempt but no assessment is kept',
      (tester) async {
    final (db, content) = await _pumpFlow(tester);
    await _createTrackAndReachDate(tester);
    final id = (await db.select(db.customTrackMetaLocal).get()).single.examId;
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'attempt-1',
            examId: id,
            startedAt: DateTime(2026),
            itemsJson: '[]',
          ),
        );
    expect(await AssessmentRepository(db).hasCompletedForExam(id), isFalse);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(await db.select(db.customTrackMetaLocal).get(), hasLength(1));
    expect(
      (await content.select(content.contentExams).get())
          .where((exam) => exam.isCustom),
      hasLength(1),
    );
  });

  group('on the server path', () {
    late List<(String, Map<String, Object?>)> calls;
    Exception? failure;

    StudyApi fakeApi() => StudyApi((name, data) async {
          calls.add((name, data));
          if (name == 'deleteCustomTrack' && failure != null) throw failure!;
          return <String, Object?>{};
        });

    List<Map<String, Object?>> deletes() => [
          for (final (name, data) in calls)
            if (name == 'deleteCustomTrack') data,
        ];

    setUp(() {
      calls = [];
      failure = null;
    });

    Future<void> backOutToPicker(WidgetTester tester) async {
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
    }

    testWidgets('backing out deletes the track on the server too',
        (tester) async {
      final (db, _) = await _pumpFlow(tester, api: fakeApi());
      await _createTrackAndReachDate(tester);
      final id = (await db.select(db.customTrackMetaLocal).get()).single.examId;
      await backOutToPicker(tester);

      expect(find.text("My exam isn't listed"), findsOneWidget);
      expect(await db.select(db.customTrackMetaLocal).get(), isEmpty);
      expect(deletes(), [
        {'examId': id, 'expectedUid': 'u1'},
      ]);
    });

    testWidgets('a track with study data is not deleted on the server',
        (tester) async {
      final (db, _) = await _pumpFlow(tester, api: fakeApi());
      await _createTrackAndReachDate(tester);
      final id = (await db.select(db.customTrackMetaLocal).get()).single.examId;
      await AssessmentRepository(db).saveResult(id, DateTime(2026), const []);
      await backOutToPicker(tester);

      expect(await db.select(db.customTrackMetaLocal).get(), hasLength(1));
      expect(deletes(), isEmpty);
    });

    testWidgets('a failed server delete changes nothing the student sees',
        (tester) async {
      failure = Exception('offline');
      final telemetry = _RecordingTelemetry();
      final (db, _) =
          await _pumpFlow(tester, api: fakeApi(), telemetry: telemetry);
      await _createTrackAndReachDate(tester);
      await backOutToPicker(tester);

      expect(deletes(), hasLength(1));
      expect(telemetry.errors, [failure]);
      expect(find.text("My exam isn't listed"), findsOneWidget);
      expect(await db.select(db.customTrackMetaLocal).get(), isEmpty);
      expect(tester.takeException(), isNull);

      // Going round again still makes one fresh track.
      failure = null;
      await _createTrackAndReachDate(tester);
      expect(await db.select(db.customTrackMetaLocal).get(), hasLength(1));
    });
  });

  testWidgets('a kept track is not renamed or rescoped by the next custom exam',
      (tester) async {
    final (db, _) = await _pumpFlow(tester);
    await _createTrackAndReachDate(tester);
    final first = (await db.select(db.customTrackMetaLocal).get()).single;
    await AssessmentRepository(db).saveResult(
      first.examId,
      DateTime(2026),
      const [],
    );
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    final scope = await CustomTrackRepository(
      db,
      ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
          .read(contentDatabaseProvider),
    ).excludedTopicIds(first.examId);

    await _createTrackAndReachDate(
      tester,
      name: 'Other Exam',
      subject: 'Science',
    );

    final tracks = await db.select(db.customTrackMetaLocal).get();
    expect(tracks, hasLength(2));
    final kept = tracks.singleWhere((t) => t.examId == first.examId);
    expect(kept.name, 'My Exam');
    expect(
      await CustomTrackRepository(
        db,
        ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
            .read(contentDatabaseProvider),
      ).excludedTopicIds(first.examId),
      scope,
    );
    expect(
      tracks.singleWhere((t) => t.examId != first.examId).name,
      'Other Exam',
    );
  });
}

class _RecordingTelemetry extends DisabledTelemetry {
  final errors = <Object>[];

  @override
  Future<void> recordError(Object error, StackTrace stack) async =>
      errors.add(error);
}
