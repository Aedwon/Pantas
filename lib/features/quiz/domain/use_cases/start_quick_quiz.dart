import 'dart:math';

import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/passage_set_filler.dart';
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
    TopicId? topicId,
    int? randomSeed,
  }) async {
    final allQuestions = <Question>[];
    if (topicId != null) {
      allQuestions.addAll(await _content.questionsByTopic(topicId));
    } else {
      final exams = await _content.listExams();
      final exam = exams.firstWhere(
        (e) => e.id == examId,
        orElse: () => throw StateError('Exam not found: $examId'),
      );

      for (final subject in exam.subjects) {
        final topics = await _content.topicsBySubject(subject.id);
        for (final topic in topics) {
          allQuestions.addAll(await _content.questionsByTopic(topic.id));
        }
      }
    }
    if (allQuestions.isEmpty) {
      throw StateError('No questions available for exam $examId');
    }

    final rng = Random(randomSeed);
    final shuffled = [...allQuestions]..shuffle(rng);

    // Taking a slice of a shuffle splits passage sets and scatters them, so
    // the same passage came up three times in one session. Whole sets are
    // selected, then the list is ordered so a set is answered in one run.
    final setsByPassageId = <String, List<Question>>{};
    final freeStanding = <Question>[];
    for (final q in shuffled) {
      final passageId = q.passageId;
      if (passageId != null && passageId.isNotEmpty) {
        setsByPassageId.putIfAbsent(passageId, () => []).add(q);
      } else {
        freeStanding.add(q);
      }
    }

    final picked = groupPassageSets(
      PassageSetFiller.fill(
        size: count,
        freeStanding: freeStanding,
        setsByPassageId: setsByPassageId,
      ),
    ).toList(growable: false);

    return QuizSession.start(
      sessionId: _uuid.v4(),
      examId: examId,
      questions: picked,
      startedAt: now,
    );
  }
}
