import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/features/assessment/domain/models/assessment_progress.dart';
import 'package:pantas/features/assessment/domain/use_cases/resume_assessment.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late ContentDatabase contentDb;
  late ResumeAssessment resume;

  AssessmentProgress progress(List<String> ids, Map<String, String> picks) =>
      AssessmentProgress(
        examId: 'e1',
        attemptId: 'a1',
        startedAt: DateTime.utc(2026, 11, 26),
        questionIds: ids,
        picks: picks,
        responseMs: {for (final id in picks.keys) id: 500},
      );

  setUp(() async {
    contentDb = inMemoryContentDatabase();
    resume = ResumeAssessment(ContentRepository(contentDb));
    await seedContentExam(contentDb, examId: 'e1', code: 'CSE', name: 'CSE');
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Verbal',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
    );
    for (final id in ['q1', 'q2', 'q3']) {
      await seedContentQuestion(
        contentDb,
        questionId: id,
        topicId: 't1',
        examId: 'e1',
      );
    }
  });
  tearDown(() => contentDb.close());

  test('rebuilds the session in the saved order with the saved picks',
      () async {
    final result = await resume.call(
      progress(['q3', 'q1', 'q2'], {'q3': 'q3_a'}),
    );
    expect(result, isNotNull);
    final session = result!.session;
    expect(session.questions.map((q) => q.question.id), ['q3', 'q1', 'q2']);
    expect(session.attemptId, 'a1');
    expect(session.startedAt, DateTime.utc(2026, 11, 26));
    expect(session.answers['q3'], 'q3_a');
    expect(session.answers['q1'], isNull);
    expect(session.responseMs, {'q3': 500});
    expect(result.index, 1);
    expect(result.progress.questionIds, ['q3', 'q1', 'q2']);
  });

  test('drops ids no longer in the bank with their picks', () async {
    final result = await resume.call(
      progress(['q1', 'gone', 'q2'], {'q1': 'q1_a', 'gone': 'x'}),
    );
    expect(result!.session.questions.map((q) => q.question.id), ['q1', 'q2']);
    expect(result.session.answers.keys, ['q1', 'q2']);
    expect(result.progress.picks, {'q1': 'q1_a'});
    expect(result.index, 1);
  });

  test('returns null when no saved question remains', () async {
    expect(await resume.call(progress(['gone'], {'gone': 'x'})), isNull);
  });

  test('a fully answered list opens on the last question', () async {
    final result = await resume.call(
      progress(['q1', 'q2'], {'q1': 'q1_a', 'q2': 'q2_a'}),
    );
    expect(result!.index, 1);
  });
}
