import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/features/assessment/domain/models/assessment_progress.dart';
import 'package:pantas/features/assessment/domain/models/assessment_question.dart';
import 'package:pantas/features/assessment/domain/models/assessment_session.dart';

/// A session rebuilt from saved progress, and where to open it.
class ResumedAssessment {
  const ResumedAssessment({
    required this.session,
    required this.index,
    required this.progress,
  });

  final AssessmentSession session;

  /// The first question with no pick, or the last one when all have a pick.
  final int index;

  /// The saved progress limited to the questions still in the bank.
  final AssessmentProgress progress;
}

/// Opens a saved assessment again from its stored question list. It never
/// selects again: the learner sees the same questions in the same order.
class ResumeAssessment {
  ResumeAssessment(this._content);

  final ContentRepository _content;

  /// Null when none of the saved questions is still in the bank.
  Future<ResumedAssessment?> call(AssessmentProgress saved) async {
    final active = await _content.activeQuestionIdsAmong(saved.questionIds);
    final progress = saved.keepOnly(active);
    if (progress == null) return null;
    final hydrated = await _content.hydrateSelectedQuestions(
      progress.questionIds,
    );
    final byId = {for (final question in hydrated) question.id: question};
    final questions = [
      for (final id in progress.questionIds)
        if (byId[id] case final question?)
          AssessmentQuestion(question: question, topicId: question.topicId),
    ];
    if (questions.isEmpty) return null;
    final kept = progress.keepOnly({
      for (final question in questions) question.question.id,
    })!;
    final session = AssessmentSession(
      examId: kept.examId,
      startedAt: kept.startedAt,
      attemptId: kept.attemptId,
      questions: questions,
      answers: {
        for (final question in questions)
          question.question.id: kept.picks[question.question.id],
      },
      responseMs: kept.responseMs,
    );
    return ResumedAssessment(
      session: session,
      index: kept.firstUnansweredIndex ?? kept.total - 1,
      progress: kept,
    );
  }
}
