import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:pantas/features/assessment/domain/models/assessment_result.dart';
import 'package:pantas/features/assessment/domain/models/assessment_session.dart';
import 'package:pantas/features/assessment/domain/models/topic_mastery.dart';
import 'package:uuid/uuid.dart';

class CompleteAssessment {
  CompleteAssessment({
    required AssessmentRepository assessmentRepo,
    required ReviewStateRepository reviewRepo,
    required FsrsScheduler scheduler,
    required ContentRepository contentRepo,
    required AttemptsRepository attemptsRepo,
    Uuid? uuid,
  })  : _assessmentRepo = assessmentRepo,
        _reviewRepo = reviewRepo,
        _scheduler = scheduler,
        _contentRepo = contentRepo,
        _attemptsRepo = attemptsRepo,
        _uuid = uuid ?? const Uuid();

  final AssessmentRepository _assessmentRepo;
  final ReviewStateRepository _reviewRepo;
  final FsrsScheduler _scheduler;
  final ContentRepository _contentRepo;
  final AttemptsRepository _attemptsRepo;
  final Uuid _uuid;

  Future<AssessmentResult> call({
    required AssessmentSession session,
    required DateTime now,
  }) async {
    // Compute per-topic correct / total
    final counts = <String, ({int correct, int total})>{};
    for (final aq in session.questions) {
      final entry = counts[aq.topicId] ?? (correct: 0, total: 0);
      final chosen = session.answers[aq.question.id];
      final isCorrect = chosen != null &&
          aq.question.choices.any((c) => c.id == chosen && c.isCorrect);
      counts[aq.topicId] = (
        correct: entry.correct + (isCorrect ? 1 : 0),
        total: entry.total + 1,
      );
    }

    final scores = counts.entries
        .map(
          (e) => TopicScore(
            topicId: e.key,
            correct: e.value.correct,
            total: e.value.total,
          ),
        )
        .toList();

    await _assessmentRepo.saveResult(session.examId, now, scores);

    // Record the assessment where every other session records itself, so
    // the metrics layer and the Progress table can see these questions.
    // responseMs is 0 because the assessment captures no timing;
    // AttemptOrigins.untimed is what stops that being read as speed.
    final items = <AttemptItem>[];
    for (final aq in session.questions) {
      final chosen = session.answers[aq.question.id];
      if (chosen == null) continue; // a skip is not a wrong answer
      final correct = aq.question.choices.firstWhere((c) => c.isCorrect);
      items.add(
        AttemptItem(
          questionId: aq.question.id,
          questionVersion: aq.question.version,
          chosenChoiceId: chosen,
          correctChoiceId: correct.id,
          responseMs: 0,
        ),
      );
    }
    await _attemptsRepo.save(
      Attempt(
        id: _uuid.v4(),
        examId: session.examId,
        startedAt: now,
        completedAt: now,
        origin: 'assessment',
        items: items,
      ),
    );

    // Seed FSRS for every answered question
    for (final aq in session.questions) {
      final chosen = session.answers[aq.question.id];
      if (chosen == null) continue;
      final isCorrect =
          aq.question.choices.any((c) => c.id == chosen && c.isCorrect);
      final rating = isCorrect ? Rating.good : Rating.again;
      final existing = await _reviewRepo.byQuestionId(aq.question.id);
      final prev = existing ??
          ReviewState.seed(
            questionId: aq.question.id,
            questionVersion: aq.question.version,
            now: now,
          );
      await _reviewRepo.upsert(
        _scheduler.next(prev: prev, rating: rating, now: now),
      );
    }

    // Hydrate result with Topic models
    final topics = await _contentRepo.topicsByExam(session.examId);
    final topicById = {for (final t in topics) t.id: t};
    final masteries = scores
        .where((s) => topicById.containsKey(s.topicId))
        .map(
          (s) => TopicMastery(
            topic: topicById[s.topicId]!,
            correct: s.correct,
            total: s.total,
          ),
        )
        .toList()
      ..sort((a, b) => a.accuracy.compareTo(b.accuracy));

    return AssessmentResult(
      examId: session.examId,
      completedAt: now,
      topicMasteries: masteries,
    );
  }
}
