import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/application/quiz_launch_coordinator.dart';
import 'package:pantas/features/quiz/application/quiz_performance_probe.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('Today prepare and launch expose only fixed performance phases',
      () async {
    final db = inMemoryDatabase();
    await AssessmentRepository(db)
        .saveResult('exam_cse_pro', DateTime(2026, 9, 10), const []);
    await DriftSettingsRepository(db).updateExamDate(
      ExamDate.onDay(DateTime(2026, 9, 11)),
      today: DateTime(2026, 9, 10),
    );
    final contentDb = inMemoryContentDatabase();
    addTearDown(db.close);
    addTearDown(contentDb.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      topicId: 'topic_a',
      topicName: 'A',
      questionIds: [for (var i = 0; i < 8; i++) 'q_$i'],
    );
    final samples = <QuizPerformanceSample>[];
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        nowProvider.overrideWithValue(() => DateTime(2026, 9, 10, 6)),
        quizPerformanceProbeProvider.overrideWithValue(
          QuizPerformanceProbe.recording(samples.add),
        ),
      ],
    );
    addTearDown(container.dispose);
    const request = QuizPreparationRequest(
      userId: quizLocalUserId,
      examId: 'exam_cse_pro',
    );

    final prepared =
        await container.read(todayQuizPreparerProvider).prepare(request);
    final launch = await container
        .read(quizLaunchCoordinatorProvider)
        .launchToday(request, prepared: prepared);

    expect(launch, isA<QuizLaunchStarted>());
    final phases = samples.map((sample) => sample.phase).toSet();
    expect(
      phases,
      containsAll({
        QuizPerformancePhase.scopeResolution,
        QuizPerformancePhase.metadataRead,
        QuizPerformancePhase.historyRead,
        QuizPerformancePhase.selection,
        QuizPerformancePhase.hydration,
        QuizPerformancePhase.sessionPersistence,
      }),
    );
    expect(
      samples.expand((sample) => sample.toJson().keys).toSet(),
      {'phase', 'elapsed_us'},
    );
  });
}
