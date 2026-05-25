import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/seeder.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_quick_quiz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('scopes questions by topic id while migration is in progress', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await Seeder(db, bundle: rootBundle).maybeSeed();

    final content = ContentRepository(db);
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
    addTearDown(db.close);
    await Seeder(db, bundle: rootBundle).maybeSeed();

    final content = ContentRepository(db);
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
