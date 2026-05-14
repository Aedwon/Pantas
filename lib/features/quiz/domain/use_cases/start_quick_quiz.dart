import 'dart:math';

import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:uuid/uuid.dart';

class StartQuickQuiz {
  StartQuickQuiz(this._content, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final ContentRepository _content;
  final Uuid _uuid;

  Future<QuizSession> call({
    required ExamId examId,
    required int count,
    required DateTime now,
    int? randomSeed,
  }) async {
    final exams = await _content.listExams();
    final exam = exams.firstWhere(
      (e) => e.id == examId,
      orElse: () => throw StateError('Exam not found: $examId'),
    );

    final allQuestions = <Question>[];
    for (final subject in exam.subjects) {
      final topics = await _content.topicsBySubject(subject.id);
      for (final topic in topics) {
        allQuestions.addAll(await _content.questionsByTopic(topic.id));
      }
    }
    if (allQuestions.isEmpty) {
      throw StateError('No questions available for exam $examId');
    }

    final rng = Random(randomSeed);
    final shuffled = [...allQuestions]..shuffle(rng);
    final picked = shuffled.take(count).toList(growable: false);

    return QuizSession.start(
      sessionId: _uuid.v4(),
      examId: examId,
      questions: picked,
      startedAt: now,
    );
  }
}
