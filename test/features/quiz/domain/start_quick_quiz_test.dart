import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_quick_quiz.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('scopes questions by topic id while migration is in progress', () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      subjectId: 'subj_cse_verbal',
      topicId: 'topic_cse_vocab',
      topicName: 'Vocab',
      questionIds: List.generate(30, (i) => 'q$i'),
    );

    final content = ContentRepository(contentDb);
    final topics = await content.topicsBySubject('subj_cse_verbal');
    final topic = topics.first;

    final session = await StartQuickQuiz(content)(
      examId: 'exam_cse_pro',
      topicId: topic.id,
      count: 3,
      now: DateTime.utc(2026, 5, 18),
      randomSeed: 7,
    );

    expect(session.questions, isNotEmpty);
    expect(
      session.questions.every((question) => question.topicId == topic.id),
      isTrue,
    );
  });

  test('keeps deterministic random ordering when a seed is supplied', () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      subjectId: 'subj_cse_verbal',
      topicId: 'topic_cse_vocab',
      topicName: 'Vocab',
      questionIds: List.generate(30, (i) => 'q$i'),
    );

    final content = ContentRepository(contentDb);
    final useCase = StartQuickQuiz(content);

    final first = await useCase(
      examId: 'exam_cse_pro',
      count: 5,
      now: DateTime.utc(2026, 5, 18),
      randomSeed: 11,
    );
    final second = await useCase(
      examId: 'exam_cse_pro',
      count: 5,
      now: DateTime.utc(2026, 5, 18),
      randomSeed: 11,
    );

    expect(
      second.questions.map((question) => question.id),
      first.questions.map((question) => question.id),
    );
  });
}
