import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_gap.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('reader quiz entry escapes actual ids and returns to its reader',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/study',
      routes: [
        GoRoute(
          path: '/study',
          builder: (_, __) => const Scaffold(
            body: ReaderGap(
              isRead: true,
              examId: 'exam/one',
              lessonId: 'lesson/two?#',
            ),
          ),
        ),
        GoRoute(
          path: '/quiz/inline/:examId/:lessonId',
          builder: (context, state) => Scaffold(
            body: Column(
              children: [
                Text(
                  'Lesson quiz ${state.pathParameters['examId']} '
                  '${state.pathParameters['lessonId']}',
                ),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpAppWithRouter(router);
    await tester.tap(find.text('Quiz yourself, 5 questions'));
    await tester.pumpAndSettle();
    expect(find.text('Lesson quiz exam/one lesson/two?#'), findsOneWidget);
    expect(router.canPop(), isTrue);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.byType(ReaderGap), findsOneWidget);
    expect(find.text('Read'), findsOneWidget);
  });

  testWidgets(
      'empty Study starts the active exam Quick Quiz and returns to Study',
      (tester) async {
    const exam = Exam(
      id: 'exam/one',
      code: 'CSE',
      name: 'Civil Service',
      shortName: 'CSE',
      language: 'en',
      isActive: true,
      subjects: [],
    );
    final router = GoRouter(
      initialLocation: '/study',
      routes: [
        GoRoute(path: '/study', builder: (_, __) => const StudyTabHome()),
        GoRoute(
          path: '/quiz',
          builder: (_, __) => const Text('Wrong Quiz root'),
        ),
        GoRoute(
          path: '/quiz/quick/:examId',
          builder: (context, state) => Scaffold(
            body: Column(
              children: [
                Text('Quick quiz ${state.pathParameters['examId']}'),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpAppWithRouter(
      router,
      overrides: [
        activeExamFocusProvider
            .overrideWith((_) async => const ActiveExamFocus.selected(exam)),
        studyMapProvider.overrideWith(
          (_) async => const StudyMap(
            examShortName: 'CSE',
            subjects: [],
            readCount: 0,
            totalCount: 0,
            minutesLeftToRead: 0,
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try a Quick Quiz'));
    await tester.pumpAndSettle();
    expect(find.text('Quick quiz exam/one'), findsOneWidget);
    expect(router.canPop(), isTrue);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing to study yet'), findsOneWidget);
  });
}
