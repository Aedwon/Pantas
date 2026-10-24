import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('Back from the date step then Continue keeps one custom track',
      (tester) async {
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
        onboardingProgressProvider.overrideWith(
          (ref) async =>
              OnboardingProgress(agePassed: true, policyAccepted: true),
        ),
        examPickerCatalogProvider.overrideWith((ref) => Stream.value(const [])),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text("My exam isn't listed"));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'My Exam');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mathematics'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('When is your exam?'), findsOneWidget);

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
}
