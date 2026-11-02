import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/picker/practice_selection.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';

/// A quiz controller that holds one [QuizRunning] state for the reviewer.
///
/// `QuizPage` asks the controller to start a session when it mounts. Every
/// start, resume and answer entry point here does nothing, so the page shows
/// exactly the state it was given and writes nothing to storage.
class FixedQuizController extends QuizController {
  FixedQuizController(super.ref, QuizRunning running) {
    state = running;
  }

  @override
  Future<void> start({
    required ExamId examId,
    TopicId? topicId,
    int count = 10,
    int? randomSeed,
  }) async {}

  @override
  Future<void> startToday({
    required ExamId examId,
    TopicId? topicId,
    TodaySessionPlan? plan,
    PreparedTodaySession? prepared,
  }) async {}

  @override
  Future<void> resumeToday({required ExamId examId}) async {}

  @override
  Future<void> startPractice({
    required ExamId examId,
    required List<PracticeUnit> units,
    required int perUnit,
    Map<String, int> countsByUnit = const {},
    Future<bool> Function()? canPersist,
  }) async {}

  @override
  Future<void> startPracticeFromQuestionIds({
    required ExamId examId,
    required List<QuestionId> questionIds,
    SessionOrigin origin = SessionOrigin.drill,
    Future<bool> Function()? canPersist,
  }) async {}

  @override
  Future<void> continueReviews(QuizSession completed) async {}

  @override
  Future<void> startDrill({
    required ExamId examId,
    required TopicId topicId,
    int requestedLength = 10,
  }) async {}

  @override
  Future<void> startRetake({required ExamId examId}) async {}

  @override
  Future<void> startInline({
    required ExamId examId,
    required LessonId lessonId,
  }) async {}

  @override
  void pick({required ChoiceId chosenChoiceId}) {}

  @override
  Future<void> answer({required ChoiceId chosenChoiceId}) async {}

  @override
  Future<void> check() async {}

  @override
  Future<void> next() async {}

  @override
  Future<void> goTo(int index) async {}

  @override
  void reset() {}
}

/// Overrides `quizControllerProvider` with a [FixedQuizController].
Override fixedQuizControllerOverride(QuizRunning running) =>
    quizControllerProvider.overrideWith(
      (ref) => FixedQuizController(ref, running),
    );
