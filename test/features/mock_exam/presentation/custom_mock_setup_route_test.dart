import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/mock_exam/application/mock_panel_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/presentation/pages/custom_mock_setup_page.dart';
import 'package:pantas/features/mock_exam/presentation/pages/custom_mock_setup_route.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_route.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

const _examId = 'exam_custom_6f1d0a52-3c1b-4c0e-8a52-0f6a3d2c9b11';

const _subjects = [
  Subject(id: 'math', examId: _examId, name: 'Mathematics', ordering: 0),
  Subject(id: 'sci', examId: _examId, name: 'Science', ordering: 1),
];

const _topics = {
  'math': [
    Topic(id: 'algebra', subjectId: 'math', name: 'Algebra', ordering: 0),
    Topic(id: 'geometry', subjectId: 'math', name: 'Geometry', ordering: 1),
  ],
  'sci': [Topic(id: 'chem', subjectId: 'sci', name: 'Chemistry', ordering: 0)],
};

void main() {
  group('what the setup page is told', () {
    test('each subject holds only its own scoped topics', () async {
      final db = inMemoryDatabase();
      final content = inMemoryContentDatabase();
      addTearDown(db.close);
      addTearDown(content.close);
      await seedContentExam(content, examId: _examId, isCustom: true);
      for (final subject in _subjects) {
        await seedContentSubject(
          content,
          subjectId: subject.id,
          examId: _examId,
        );
      }
      for (final topic in _topics.values.expand((t) => t)) {
        await seedContentTopic(
          content,
          topicId: topic.id,
          subjectId: topic.subjectId,
        );
      }
      var n = 0;
      Future<void> questions(String topic, int count) async {
        for (var i = 0; i < count; i++) {
          await seedContentQuestion(
            content,
            questionId: 'q${n++}',
            topicId: topic,
            examId: _examId,
          );
        }
      }

      await questions('algebra', 3);
      await questions('geometry', 2);
      await questions('chem', 4);

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
          activeExamFocusProvider.overrideWith(
            (_) async => const ActiveExamFocus.selected(
              Exam(
                id: _examId,
                code: 'MINE',
                name: 'My exam',
                shortName: 'My exam',
                language: 'en',
                isActive: true,
                subjects: _subjects,
                isCustom: true,
              ),
            ),
          ),
          scopedTopicsProvider(_examId).overrideWith(
            (_) async => _topics.values.expand((t) => t).toList(),
          ),
          scopedSubjectsProvider(_examId).overrideWith((_) async => _subjects),
        ],
      );
      addTearDown(container.dispose);

      final data = (await container.read(customMockSetupDataProvider.future))!;

      expect(data.availableBySubject, {'math': 5, 'sci': 4});
      expect(data.availableQuestions, 9);
    });
  });

  group('saving the paper', () {
    late Completer<void> settled;
    late int availabilityReads;
    late int countReads;
    late int dataReads;
    late int publishes;

    Future<ProviderContainer> open(
      WidgetTester tester, {
      required bool web,
    }) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      settled = Completer<void>();
      availabilityReads = 0;
      countReads = 0;
      dataReads = 0;
      publishes = 0;
      final router = GoRouter(
        initialLocation: '/quiz',
        routes: [
          GoRoute(
            path: '/quiz',
            builder: (_, __) => Consumer(
              builder: (context, ref, _) {
                ref
                  ..watch(serverMockAvailabilityProvider(_examId))
                  ..watch(mockSetupQuestionCountProvider(_examId));
                final summary = ref.watch(customMockSummaryProvider(_examId));
                return Scaffold(
                  body: Column(
                    children: [
                      const Text('Quiz tab'),
                      Text(
                        'summary ${summary.valueOrNull?.questions}',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          GoRoute(
            path: '/quiz/mock/custom-setup',
            builder: (_, __) => const CustomMockSetupRoute(),
          ),
        ],
      );
      await tester.pumpAppWithRouter(
        router,
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          mockUsesServerProvider.overrideWithValue(web),
          customMockSetupDataProvider.overrideWith((ref) async {
            dataReads++;
            return const CustomMockSetupData(
              examId: _examId,
              subjects: _subjects,
              topicsBySubject: _topics,
              availableQuestions: 240,
              availableBySubject: {'math': 120, 'sci': 120},
            );
          }),
          studySettingsCaptureProvider.overrideWith(
            (ref) => ({String? examId}) async => StudySettingsPublication(
                  () async => publishes++,
                  settled: settled.future,
                ),
          ),
          serverMockAvailabilityProvider(_examId).overrideWith((_) async {
            availabilityReads++;
            return <String, Object?>{};
          }),
          mockSetupQuestionCountProvider(_examId).overrideWith((_) async {
            countReads++;
            return 120;
          }),
        ],
      );
      unawaited(router.push('/quiz/mock/custom-setup'));
      await tester.pumpAndSettle();
      addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
      return ProviderScope.containerOf(
        tester.element(find.byType(CustomMockSetupPage)),
      );
    }

    testWidgets(
        'on the web Save waits for the server, then reads the exam again '
        'and leaves', (tester) async {
      final container = await open(tester, web: true);
      expect(availabilityReads, 1);
      expect(countReads, 1);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // The paper is on this device, the server has not answered, and the
      // student is still here with Save off.
      expect(publishes, 1);
      expect(find.text('Set up your mock'), findsOneWidget);
      expect(
        tester.widget<PantasButton>(find.byType(PantasButton)).onPressed,
        isNull,
        reason: 'Save is off while the server has not answered',
      );
      expect(availabilityReads, 1);

      settled.complete();
      await tester.pumpAndSettle();

      expect(find.text('Quiz tab'), findsOneWidget);
      expect(availabilityReads, 2);
      expect(countReads, 2);
      // Opening setup again reads the paper just saved, not the old one.
      expect(dataReads, 2);
      // The panel's summary was read again from the row just saved.
      expect(find.text('summary 120'), findsOneWidget);
      expect(
        (await container.read(customBlueprintRepositoryProvider).read(_examId))
            ?.totalQuestions,
        120,
      );
    });

    testWidgets(
        'on the web a failed publish keeps the page and the saved row, and '
        'reads nothing again', (tester) async {
      final container = await open(tester, web: true);

      await tester.tap(find.text('Save'));
      await tester.pump();
      settled.completeError(StateError('offline'));
      await tester.pumpAndSettle();

      expect(find.text('Set up your mock'), findsOneWidget);
      expect(find.text('Could not save. Please try again.'), findsOneWidget);
      expect(find.text('Quiz tab'), findsNothing);
      expect(availabilityReads, 1);
      expect(countReads, 1);
      // The paper stays on this device, and a later publish carries it.
      expect(
        await container.read(customBlueprintRepositoryProvider).exists(_examId),
        isTrue,
      );
    });

    testWidgets('on a phone the send is not waited for', (tester) async {
      await open(tester, web: false);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(publishes, 1);
      expect(settled.isCompleted, isFalse);
      expect(find.text('Quiz tab'), findsOneWidget);
      expect(availabilityReads, 1);
      expect(find.text('summary 120'), findsOneWidget);
    });
  });
}
