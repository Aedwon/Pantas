import 'package:cse_cet_reviewer/core/fsrs/fsrs_scheduler.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/rating_heuristic.dart';

class SubmitAnswer {
  SubmitAnswer({
    required ReviewStateRepository reviewRepo,
    required FsrsScheduler scheduler,
  })  : _reviewRepo = reviewRepo,
        _scheduler = scheduler;

  final ReviewStateRepository _reviewRepo;
  final FsrsScheduler _scheduler;

  Future<AnswerOutcome> call({
    required Question question,
    required String chosenChoiceId,
    required int responseMs,
    required DateTime now,
  }) async {
    final correctId = question.correctChoice.id;
    final isCorrect = chosenChoiceId == correctId;

    final prev = await _reviewRepo.byQuestionId(question.id) ??
        ReviewState.seed(
          questionId: question.id,
          questionVersion: question.version,
          now: now,
        );

    final rating =
        RatingHeuristic.from(isCorrect: isCorrect, responseMs: responseMs);
    final next = _scheduler.next(prev: prev, rating: rating, now: now);
    await _reviewRepo.upsert(next);

    return AnswerOutcome(
      questionId: question.id,
      questionVersion: question.version,
      chosenChoiceId: chosenChoiceId,
      correctChoiceId: correctId,
      responseMs: responseMs,
    );
  }
}
