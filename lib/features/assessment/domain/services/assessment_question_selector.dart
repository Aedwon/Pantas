import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/domain/assessment_question.dart';
import 'package:pantas/core/storage/domain/assessment_question_selector.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/features/first_run/domain/first_run_content.dart';

export 'package:pantas/core/storage/domain/assessment_question_selector.dart';

/// The assessment's questions for an exam. Always leaves out the exam's fixed
/// first run questions, so what the assessment asks does not depend on whether
/// the learner tried them (plan `2026-11-25-first-run-build.md`, ruling 13).
///
/// Every place that builds or counts the assessment goes through this.
class AssessmentSelection {
  const AssessmentSelection(this._selector);

  final AssessmentQuestionSelector _selector;

  Future<List<AssessmentQuestion>> select(
    ExamId examId, {
    List<Topic>? topics,
  }) =>
      _selector.select(
        examId,
        topics: topics,
        excludeQuestionIds: excludedFromAssessment(examId),
      );
}

/// The question ids the assessment never asks for [examId].
Set<QuestionId> excludedFromAssessment(ExamId examId) =>
    {...?firstRunContentFor(examId)?.questionIds};

/// A selector for the assessment: [AssessmentSelection] over the plain one.
AssessmentSelection assessmentQuestionSelector(
  ContentRepository content,
  ReviewStateRepository review,
) =>
    AssessmentSelection(AssessmentQuestionSelector(content, review));
